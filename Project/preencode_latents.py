"""
Pre-encode audio clips into VAE latent .pt files for SonicMaster fine-tuning.

Reads JSONL metadata, encodes both clean (original_location) and degraded
(location) audio through the Stable Audio VAE, and saves as .pt files.
Updates the JSONL paths to point to the .pt files.

Usage:
    python preencode_latents.py \
        --jsonl data/trainset.jsonl data/valset.jsonl \
        --output_dir data/ \
        --batch_size 4
"""

import argparse
import json
import os

import torch
import torchaudio
from diffusers import AutoencoderOobleck
from tqdm import tqdm


def pad_wav(waveform, target_length):
    if waveform.shape[0] >= target_length:
        return waveform[:target_length]
    return torch.cat([waveform, torch.zeros(target_length - waveform.shape[0])])


def load_audio(path, duration_sec=30, sr=44100):
    wav, orig_sr = torchaudio.load(path)
    if orig_sr != sr:
        wav = torchaudio.functional.resample(wav, orig_sr, sr)
    if wav.shape[0] == 1:
        wav = wav.repeat(2, 1)
    elif wav.shape[0] > 2:
        wav = wav[:2]
    target = int(sr * duration_sec)
    left = pad_wav(wav[0], target)
    right = pad_wav(wav[1], target)
    return torch.stack([left, right])


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--jsonl", nargs="+", required=True, help="JSONL metadata files")
    parser.add_argument("--output_dir", default="data/", help="Base directory for .pt output")
    parser.add_argument("--batch_size", type=int, default=4)
    parser.add_argument("--duration", type=int, default=30)
    args = parser.parse_args()

    device = "cuda" if torch.cuda.is_available() else "cpu"

    hf_token = os.environ.get("HF_TOKEN") or os.environ.get("HUGGINGFACE_TOKEN")
    vae = AutoencoderOobleck.from_pretrained(
        "stabilityai/stable-audio-open-1.0", subfolder="vae",
        use_auth_token=hf_token,
    ).to(device)
    vae.eval()
    vae.requires_grad_(False)

    clean_pt_dir = os.path.join(args.output_dir, "clean_pt")
    deg_pt_dir = os.path.join(args.output_dir, "degraded_pt")
    os.makedirs(clean_pt_dir, exist_ok=True)
    os.makedirs(deg_pt_dir, exist_ok=True)

    for jsonl_path in args.jsonl:
        print(f"\nProcessing {jsonl_path}...")
        with open(jsonl_path) as f:
            records = [json.loads(line) for line in f if line.strip()]

        updated_records = []
        batch_wavs = []
        batch_meta = []

        def flush_batch(wavs, meta, is_clean):
            if not wavs:
                return
            tensor = torch.stack(wavs).to(device)
            with torch.no_grad():
                latents = vae.encode(tensor).latent_dist.mode()
                latents = latents.transpose(1, 2)  # [B, T, C]
            for lat, m in zip(latents.cpu(), meta):
                out_dir = clean_pt_dir if is_clean else deg_pt_dir
                pt_name = os.path.basename(m["path"]).rsplit(".", 1)[0] + ".pt"
                pt_path = os.path.join(out_dir, pt_name)
                torch.save(lat, pt_path)
                m["pt_path"] = pt_path

        clean_batch_wavs, clean_batch_meta = [], []
        deg_batch_wavs, deg_batch_meta = [], []

        for rec in tqdm(records, desc="Loading & encoding"):
            try:
                clean_wav = load_audio(rec["original_location"], args.duration)
                deg_wav = load_audio(rec["location"], args.duration)
            except Exception as e:
                print(f"  Skipping: {e}")
                continue

            clean_meta = {"path": rec["original_location"]}
            deg_meta = {"path": rec["location"]}

            clean_batch_wavs.append(clean_wav)
            clean_batch_meta.append(clean_meta)
            deg_batch_wavs.append(deg_wav)
            deg_batch_meta.append(deg_meta)

            if len(clean_batch_wavs) >= args.batch_size:
                flush_batch(clean_batch_wavs, clean_batch_meta, is_clean=True)
                flush_batch(deg_batch_wavs, deg_batch_meta, is_clean=False)

                for cm, dm, r in zip(clean_batch_meta, deg_batch_meta, records):
                    updated_records.append({
                        **r,
                        "original_location": cm["pt_path"],
                        "location": dm["pt_path"],
                    })
                clean_batch_wavs, clean_batch_meta = [], []
                deg_batch_wavs, deg_batch_meta = [], []

        # Flush remaining
        if clean_batch_wavs:
            flush_batch(clean_batch_wavs, clean_batch_meta, is_clean=True)
            flush_batch(deg_batch_wavs, deg_batch_meta, is_clean=False)
            remaining_records = records[len(updated_records) : len(updated_records) + len(clean_batch_meta)]
            for cm, dm, r in zip(clean_batch_meta, deg_batch_meta, remaining_records):
                updated_records.append({
                    **r,
                    "original_location": cm["pt_path"],
                    "location": dm["pt_path"],
                })

        # Write updated JSONL with .pt paths
        pt_jsonl = jsonl_path.replace(".jsonl", "_pt.jsonl")
        with open(pt_jsonl, "w") as f:
            for r in updated_records:
                f.write(json.dumps(r) + "\n")
        print(f"  Wrote {len(updated_records)} records to {pt_jsonl}")


if __name__ == "__main__":
    main()
