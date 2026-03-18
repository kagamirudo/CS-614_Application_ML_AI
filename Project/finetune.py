"""
Fine-tune SonicMaster for codec-specific audio restoration.

Adapted from SonicMaster's train_ptload_inference.py with:
  - File-based logging (CSV + JSONL) instead of mandatory wandb
  - Pretrained checkpoint loading via --load_from_checkpoint
  - Single-GPU friendly (use with accelerate + configs/accelerator_single_gpu.yaml)
  - Resume support for Colab disconnections

Usage:
    accelerate launch --config_file configs/accelerator_single_gpu.yaml \
        finetune.py \
        --config configs/finetune.yaml \
        --load_from_checkpoint checkpoints/model.safetensors
"""

import argparse
import csv
import json
import logging
import math
import os
import random
import sys
import time
from pathlib import Path

import datasets
import diffusers
import numpy as np
import torch
import transformers
from accelerate import Accelerator
from accelerate.logging import get_logger
from accelerate.utils import set_seed
from datasets import load_dataset
from torch.utils.data import DataLoader
from tqdm.auto import tqdm
from transformers import SchedulerType, get_scheduler

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "sonicmaster"))
from model import TangoFlux
from utils import Text2AudioDataset

logger = get_logger(__name__)


def parse_args():
    p = argparse.ArgumentParser(description="Fine-tune SonicMaster for codec restoration.")
    p.add_argument("--config", type=str, default="configs/finetune.yaml")
    p.add_argument("--load_from_checkpoint", type=str, default=None,
                   help="Path to pretrained model.safetensors")
    p.add_argument("--seed", type=int, default=42)
    p.add_argument("--lr_scheduler_type", type=SchedulerType, default="cosine")
    p.add_argument("--save_every", type=int, default=5)
    p.add_argument("--text_column", type=str, default="prompt")
    p.add_argument("--alt_text_column", type=str, default="alt_prompt")
    p.add_argument("--audio_column", type=str, default="original_location")
    p.add_argument("--deg_audio_column", type=str, default="location")
    p.add_argument("--num_examples", type=int, default=-1)
    p.add_argument("--prefix", type=str, default="")
    p.add_argument("--use_wandb", action="store_true", help="Enable wandb logging")
    return p.parse_args()


def load_config(path):
    import yaml
    with open(path) as f:
        return yaml.safe_load(f)


def main():
    args = parse_args()
    config = load_config(args.config)

    lr = float(config["training"]["learning_rate"])
    num_epochs = int(config["training"]["num_train_epochs"])
    warmup_steps = int(config["training"]["num_warmup_steps"])
    batch_size = int(config["training"]["per_device_batch_size"])
    grad_accum = int(config["training"]["gradient_accumulation_steps"])
    output_dir = config["paths"]["output_dir"]

    accelerator = Accelerator(gradient_accumulation_steps=grad_accum)

    logging.basicConfig(
        format="%(asctime)s - %(levelname)s - %(name)s - %(message)s",
        datefmt="%m/%d/%Y %H:%M:%S",
        level=logging.INFO,
    )
    logger.info(accelerator.state, main_process_only=False)
    datasets.utils.logging.set_verbosity_error()
    diffusers.utils.logging.set_verbosity_error()
    transformers.utils.logging.set_verbosity_error()

    if args.seed is not None:
        set_seed(args.seed)

    if accelerator.is_main_process:
        os.makedirs(output_dir, exist_ok=True)
        os.makedirs(f"{output_dir}/outputs", exist_ok=True)

        with open(f"{output_dir}/summary.jsonl", "a") as f:
            f.write(json.dumps(dict(vars(args))) + "\n\n")

        if args.use_wandb:
            import wandb
            wandb.init(project="AudioRestore-Finetune",
                       settings=wandb.Settings(_disable_stats=True))

    accelerator.wait_for_everyone()

    # --- Load dataset ---
    data_files = {
        "train": config["paths"]["train_file"],
        "validation": config["paths"]["val_file"],
    }
    raw = load_dataset("json", data_files=data_files)

    train_dataset = Text2AudioDataset(
        raw["train"], args.prefix,
        args.text_column, args.alt_text_column,
        args.audio_column, args.deg_audio_column,
        "duration", args.num_examples,
    )
    val_dataset = Text2AudioDataset(
        raw["validation"], args.prefix,
        args.text_column, args.alt_text_column,
        args.audio_column, args.deg_audio_column,
        "duration", args.num_examples,
    )
    accelerator.print(f"Train: {train_dataset.get_num_instances()}, Val: {val_dataset.get_num_instances()}")

    train_loader = DataLoader(train_dataset, shuffle=True, batch_size=batch_size,
                              collate_fn=train_dataset.collate_fn)
    val_loader = DataLoader(val_dataset, shuffle=False, batch_size=batch_size,
                            collate_fn=val_dataset.collate_fn)

    # --- Build model ---
    model = TangoFlux(config=config["model"])

    for param in model.text_encoder.parameters():
        param.requires_grad = False
    model.text_encoder.eval()

    if args.load_from_checkpoint:
        from safetensors.torch import load_file
        weights = load_file(args.load_from_checkpoint)
        model.load_state_dict(weights, strict=False)
        logger.info(f"Loaded pretrained weights from {args.load_from_checkpoint}")

    trainable_params = (
        list(model.transformer.parameters())
        + list(model.fc_text.parameters())
        + list(model.fc_text_audio.parameters())
        + list(model.audio_cond.parameters())
    )
    n_trainable = sum(p.numel() for p in trainable_params)
    accelerator.print(f"Trainable parameters: {n_trainable:,}")

    optimizer = torch.optim.AdamW(trainable_params, lr=lr, betas=(0.9, 0.95),
                                  weight_decay=1e-2, eps=1e-8)

    steps_per_epoch = math.ceil(len(train_loader) / grad_accum)
    max_steps = num_epochs * steps_per_epoch

    scheduler = get_scheduler(
        name=args.lr_scheduler_type, optimizer=optimizer,
        num_warmup_steps=warmup_steps * grad_accum * accelerator.num_processes,
        num_training_steps=max_steps * grad_accum,
    )

    model, optimizer, scheduler = accelerator.prepare(model, optimizer, scheduler)
    train_loader, val_loader = accelerator.prepare(train_loader, val_loader)

    steps_per_epoch = math.ceil(len(train_loader) / grad_accum)
    max_steps = num_epochs * steps_per_epoch

    # --- Resume ---
    resume_path = config["paths"].get("resume_from_checkpoint", "")
    if resume_path:
        accelerator.load_state(resume_path)
        accelerator.print(f"Resumed from {resume_path}")

    # --- CSV logger ---
    csv_path = os.path.join(output_dir, "training_log.csv")
    csv_file = None
    csv_writer = None
    if accelerator.is_main_process:
        csv_file = open(csv_path, "a", newline="")
        csv_writer = csv.writer(csv_file)
        if os.path.getsize(csv_path) == 0:
            csv_writer.writerow(["epoch", "step", "train_loss", "val_loss", "lr"])

    # --- Training loop ---
    length = config["training"]["max_audio_duration"]
    best_val_loss = float("inf")
    completed_steps = 0
    progress = tqdm(range(max_steps), disable=not accelerator.is_local_main_process)

    generic_prompts = [
        "Make it sound better!",
        "Can you improve the sound of this song?",
        "Improve this!",
        "Master this track for me, please.",
    ]

    for epoch in range(num_epochs):
        model.train()
        total_train_loss = 0.0

        for step, batch in enumerate(train_loader):
            with accelerator.accumulate(model):
                optimizer.zero_grad()
                device = accelerator.device
                text, alt_text, audios, deg_audios, duration, _ = batch

                # Text augmentation (same as original SonicMaster)
                for ti, t in enumerate(text):
                    dice = random.random()
                    if dice < 0.1:
                        text[ti] = ""
                    elif dice > 0.9:
                        text[ti] = random.choice(generic_prompts)
                    elif dice < 0.5:
                        text[ti] = alt_text[ti]

                with torch.no_grad():
                    audio_list = [torch.load(p) for p in audios]
                    deg_list = [torch.load(p) for p in deg_audios]
                    audio_latent = torch.stack(audio_list).to(device)
                    deg_latent = torch.stack(deg_list).to(device)
                    dur_tensor = torch.tensor(duration, device=device).clamp(max=length)

                loss, _, _, _ = model(audio_latent, deg_latent, text, duration=dur_tensor)
                total_train_loss += loss.detach().float()
                accelerator.backward(loss)

                if accelerator.sync_gradients:
                    progress.update(1)
                    completed_steps += 1

                optimizer.step()
                scheduler.step()

            if completed_steps % 20 == 0 and accelerator.is_main_process:
                current_lr = scheduler.get_last_lr()[0]
                logger.info(f"Step {completed_steps}, Loss: {loss.item():.4f}, LR: {current_lr:.2e}")
                if args.use_wandb:
                    import wandb
                    wandb.log({"train_loss": loss.item(), "lr": current_lr}, step=completed_steps)

        if completed_steps >= max_steps:
            break

        # --- Validation ---
        model.eval()
        total_val_loss = 0.0
        for batch in val_loader:
            with torch.no_grad():
                device = accelerator.device
                text, alt_text, audios, deg_audios, duration, _ = batch
                audio_list = [torch.load(p) for p in audios]
                deg_list = [torch.load(p) for p in deg_audios]
                audio_latent = torch.stack(audio_list).to(device)
                deg_latent = torch.stack(deg_list).to(device)
                dur_tensor = torch.tensor(duration, device=device)
                val_loss, _, _, _ = model(audio_latent, deg_latent, text, duration=dur_tensor)
                total_val_loss += val_loss.detach().float()

        if accelerator.is_main_process:
            avg_train = total_train_loss.item() / max(len(train_loader), 1)
            avg_val = total_val_loss.item() / max(len(val_loader), 1)
            current_lr = scheduler.get_last_lr()[0]

            result_str = f"Epoch {epoch+1}/{num_epochs} | Train: {avg_train:.4f} | Val: {avg_val:.4f} | LR: {current_lr:.2e}"
            accelerator.print(result_str)

            csv_writer.writerow([epoch + 1, completed_steps, f"{avg_train:.4f}", f"{avg_val:.4f}", f"{current_lr:.2e}"])
            csv_file.flush()

            with open(f"{output_dir}/summary.jsonl", "a") as f:
                f.write(json.dumps({"epoch": epoch + 1, "train_loss": avg_train,
                                    "val_loss": avg_val, "lr": current_lr}) + "\n")

            if args.use_wandb:
                import wandb
                wandb.log({"epoch/train_loss": avg_train, "epoch/val_loss": avg_val}, step=completed_steps)

            save_ckpt = avg_val < best_val_loss
            if save_ckpt:
                best_val_loss = avg_val

        accelerator.wait_for_everyone()

        if accelerator.is_main_process:
            if save_ckpt:
                accelerator.save_state(f"{output_dir}/best")
            if (epoch + 1) % args.save_every == 0:
                accelerator.save_state(f"{output_dir}/epoch_{epoch+1}")

    if accelerator.is_main_process:
        if csv_file:
            csv_file.close()
        accelerator.print(f"\nTraining complete. Best val loss: {best_val_loss:.4f}")
        accelerator.print(f"Checkpoints saved to: {output_dir}/")
        if args.use_wandb:
            import wandb
            wandb.finish()


if __name__ == "__main__":
    main()
