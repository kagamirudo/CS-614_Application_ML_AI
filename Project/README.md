# AudioRestore: AI-Powered Audio Quality Restoration

**CS 614 -- Applications of Machine Learning -- Final Project**

Fine-tuning [SonicMaster](https://github.com/AMAAI-Lab/SonicMaster) (ICLR 2026)
for codec-specific audio restoration controlled by natural language prompts.

## Quick Start (Colab)

Open `train_colab.ipynb` in Google Colab (A100 GPU recommended) and run all cells.
The notebook handles installation, data preparation, fine-tuning, and evaluation.

## Project Structure

```
Project/
├── sonicmaster/            # SonicMaster source (cloned from AMAAI-Lab/SonicMaster)
├── configs/
│   ├── finetune.yaml       # Fine-tuning hyperparameters
│   └── accelerator_single_gpu.yaml
├── data/
│   ├── prepare_codec_dataset.py   # Generate codec-degraded pairs
│   └── (generated JSONL + .pt files)
├── checkpoints/            # Pretrained + fine-tuned weights
├── finetune.py             # Fine-tuning script (adapted from SonicMaster)
├── train_colab.ipynb       # Colab fine-tuning notebook
├── demo.ipynb              # Demo: text-controlled restoration + metrics
├── report/                 # LaTeX report
└── README.md
```

## Approach

1. **Existing tech**: SonicMaster -- 0.9B-parameter unified generative model for
   music restoration using flow-matching + text-prompt conditioning.
2. **Modification**: Fine-tune on codec-degraded audio (MP3/OGG at 24--128 kbps)
   with custom text prompts for bitrate enhancement.
3. **Demo**: Text-controlled restoration with before/after spectrograms and metrics.

## Requirements

```
torch>=2.4.0  torchaudio  diffusers>=0.30.0  transformers>=4.44.0
accelerate>=0.34.2  safetensors  librosa  soundfile  tqdm  pandas
```
