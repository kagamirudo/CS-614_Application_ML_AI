# AudioRestore: Text-Controlled Audio Quality Restoration via Fine-Tuned SonicMaster

**CS 614 -- Applications of Machine Learning -- Final Project**
**Author: Gary Pham (gp492) -- Drexel University -- March 2026**

Fine-tuning [SonicMaster](https://github.com/AMAAI-Lab/SonicMaster) (0.9B params, ICLR 2026)
for codec-specific audio restoration controlled by natural language prompts.

## Results

| Bitrate | SDR Degraded | SDR Restored | SI-SNR Degraded | SI-SNR Restored |
|---------|-------------|-------------|----------------|----------------|
| 32 kbps | 13.71 dB | 7.71 dB | 13.68 dB | 7.44 dB |
| 64 kbps | 16.24 dB | 8.47 dB | 16.48 dB | 8.04 dB |
| 128 kbps | 20.13 dB | 8.96 dB | 21.12 dB | 8.38 dB |

The generative flow-matching model produces consistent ~8 dB SDR output regardless of input
degradation severity, trading sample-level fidelity for perceptual plausibility. Spectrograms
confirm the model synthesizes high-frequency content absent in the degraded input.

- **Training**: 30 epochs on A100 GPU (~2.5 hrs), best val loss 0.0996 at epoch 28
- **Dataset**: 1,000 clips (900 train / 100 val) from 114 MUSDB18-HQ source files
- **Trainable params**: 522M (T5 encoder + VAE frozen)

## Data & Checkpoints (Google Drive)

The dataset and model weights are hosted on Google Drive (not included in the zip):

**[Google Drive Folder](https://drive.google.com/drive/folders/1eyxwTykveOsbY3XybfIVmWsd1kFF4AAJ?usp=sharing)**

Contents:
- `data/` -- 1,000 codec-degraded audio clips + pre-encoded VAE latents
- `checkpoints/` -- pretrained SonicMaster + fine-tuned weights (~3.6 GB)
- `outputs/finetune_codec/best/` -- best checkpoint from training

Both notebooks automatically mount Google Drive at `/content/drive/MyDrive/CS614_Project`
when run in Colab. No manual download is needed -- just open in Colab and run.

## Quick Start (Colab)

1. Open `train_colab.ipynb` in Google Colab (A100 GPU recommended)
2. Run all cells -- handles installation, data prep, fine-tuning, and loss curves
3. Open `demo.ipynb` for inference, spectrograms, metrics, and prompt experiments

## Project Structure

```
Project/
├── train_colab.ipynb          # Full pipeline: data prep -> fine-tune -> loss curves
├── demo.ipynb                 # Inference demo: restoration + spectrograms + metrics
├── sonicmaster/               # SonicMaster source (cloned from AMAAI-Lab/SonicMaster)
│   ├── model.py               # TangoFlux model definition
│   ├── train_ptload_inference.py  # Training script (patched with grad clipping)
│   └── utils.py
├── report/
│   ├── main.tex               # LaTeX report (IEEE format)
│   ├── references.bib         # 18 references
│   ├── figures/               # Loss curves, spectrograms, architecture diagram
│   └── Makefile               # make pdf / make clean
├── configs/
│   ├── finetune_codec.yaml    # Fine-tuning hyperparameters
│   └── accelerator_single_gpu.yaml
├── data/                      # Generated at runtime
│   ├── clean/ & clean_clips/  # Source audio & 30s clips
│   ├── degraded_clips/        # Codec-degraded clips
│   ├── clean_pt/ & degraded_pt/  # Pre-encoded VAE latents
│   └── trainset_pt.jsonl / valset_pt.jsonl
├── checkpoints/               # Pretrained + fine-tuned weights
├── outputs/finetune_codec/    # Training outputs, best checkpoint, loss summary
└── README.md
```

## Approach

1. **Base model**: SonicMaster -- 0.9B-parameter generative model for music
   restoration using flow matching + text-prompt conditioning
2. **Dataset**: Codec-degraded pairs from MUSDB18-HQ (MP3 at 24--128 kbps,
   OGG Vorbis at quality -1 to 5), with natural language prompt annotations
3. **Fine-tuning**: 522M trainable params (TangoFlux transformer + projection
   layers), AdamW lr=1e-5, BF16, gradient clipping max norm 1.0
4. **Demo**: Text-controlled restoration with before/after spectrograms,
   SDR/SI-SNR metrics, prompt variation experiments, and full-song processing

## Key Finding

The generative flow-matching approach synthesizes perceptually plausible audio but
reduces sample-level fidelity (SDR) compared to the degraded input. This is a property
of generative restoration -- the model creates new high-frequency content rather than
reconstructing the exact original signal. Perceptual metrics (PESQ, FAD) would better
evaluate this type of system.

## Requirements

```
torch>=2.4.0  torchaudio  diffusers>=0.30.0  transformers>=4.44.0
accelerate>=0.34.2  safetensors  librosa  soundfile  tqdm  pandas
pyyaml  huggingface_hub  matplotlib
```

## Report

```bash
cd report
make pdf    # Downloads IEEEtran.cls/bst, compiles main.pdf
make clean  # Removes aux files (keeps PDF)
```
