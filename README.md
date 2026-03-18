# CS 614 - Applications of Machine Learning

**Drexel University -- Gary Pham (gp492)**

This repository contains assignments and the final project for CS 614 - Applications of Machine Learning.

## Contents

- **Homework 1/**: Programming Assignment 1
- **Homework 2/**: Programming Assignment 2 - CNN for MNIST digit classification
- **Homework 3/**: Programming Assignment 3 - Transfer learning (ResNet18 on CIFAR-10), with technical document and saved figures
- **Homework 4/**: Object detection with Faster R-CNN (torchvision)
- **Homework 6/**: Transformer blocks (BERT-style encoder from scratch)
- **Applications/**: Apollo music restoration -- input a compressed track (e.g. MP3), output restored WAV. See [Applications/README.md](Applications/README.md)
- **Project/**: **AudioRestore** -- Text-controlled audio quality restoration via fine-tuned SonicMaster (0.9B params). See [Project/README.md](Project/README.md)

## Final Project: AudioRestore

Fine-tuned [SonicMaster](https://github.com/AMAAI-Lab/SonicMaster) on codec-degraded audio
(MP3/OGG at 24--128 kbps) for text-controlled restoration. Trained 522M parameters for 30
epochs on A100, achieving val loss 0.0996. Key finding: generative flow-matching models trade
sample-level fidelity for perceptual plausibility (~8 dB SDR output regardless of input quality).

- `Project/train_colab.ipynb` -- Full training pipeline (Colab or local)
- `Project/demo.ipynb` -- Inference demo with spectrograms and metrics
- `Project/report/` -- LaTeX report (`make pdf` to build)

## Quick Start

### Prerequisites

```bash
bash scripts/check_requirements.sh
```

Required tools:
- [Make](https://www.gnu.org/software/make/)
- [Miniconda](https://docs.conda.io/en/latest/miniconda.html) or [Anaconda](https://www.anaconda.com/products/distribution)
- Git

### Environment Setup

```bash
make setup
```

This will auto-detect your OS, create a `cs614` conda environment with Python 3.13,
and prompt for GPU support (CPU / NVIDIA CUDA / AMD ROCm).

**Manual alternative:**
- **Linux/Mac**: `bash scripts/setup_environment.sh`
- **Windows**: `powershell -ExecutionPolicy Bypass -File scripts/setup_environment.ps1`

### Activating the Environment

```bash
conda activate cs614
```

### GPU Support

```bash
make check-gpu    # or: python scripts/check_gpu.py
```

For AMD GPUs (ROCm):
```bash
bash scripts/setup_rocm_pytorch.sh   # Creates env at /opt/rocm-pytorch
bash scripts/install_rocm_kernel.sh  # Registers Jupyter kernel
```

### Running the Notebooks

```bash
conda activate cs614
jupyter notebook
```

| Notebook | Topic |
|----------|-------|
| `Homework 1/HW1.ipynb` | Assignment 1 |
| `Homework 2/HW2.ipynb` | CNN for MNIST |
| `Homework 3/HW3.ipynb` | ResNet18 fine-tuning on CIFAR-10 |
| `Homework 4/HW4.ipynb` | Faster R-CNN object detection |
| `Homework 6/Lecture.ipynb` | Transformer / BERT-style encoder |
| `Applications/music.ipynb` | Apollo music restoration |
| `Project/train_colab.ipynb` | AudioRestore fine-tuning |
| `Project/demo.ipynb` | AudioRestore demo + metrics |

## Repository Structure

```
CS614/
├── Makefile                   # Main Makefile for all commands
├── README.md                  # This file
├── .gitignore
├── Homework 1/                # Assignment 1
├── Homework 2/                # Assignment 2 (CNN/MNIST)
├── Homework 3/                # Assignment 3 (transfer learning)
├── Homework 4/                # Assignment 4 (object detection)
├── Homework 6/                # Transformer / BERT-style
├── Applications/              # Apollo music restoration
│   ├── README.md
│   ├── music.ipynb
│   └── Apollo/                # Apollo model (submodule)
├── Project/                   # Final Project: AudioRestore
│   ├── README.md              # Project-specific README
│   ├── train_colab.ipynb      # Training pipeline
│   ├── demo.ipynb             # Inference demo
│   ├── sonicmaster/           # SonicMaster source
│   ├── report/                # LaTeX report + figures
│   │   ├── main.tex
│   │   ├── references.bib
│   │   ├── figures/
│   │   └── Makefile           # make pdf / make clean
│   ├── configs/               # Training configs
│   ├── data/                  # Generated at runtime
│   ├── checkpoints/           # Model weights
│   └── outputs/               # Training outputs
├── scripts/                   # Setup and utility scripts
└── data/                      # Data directory (gitignored)
```

## Available Make Commands

```bash
make setup              # Set up conda environment (auto-detects OS)
make check-gpu          # Check GPU availability
make apollo-kernel      # Create Jupyter kernel for Apollo
make apollo-clean       # Remove old Apollo env/kernel
make push               # Commit and push to GitHub
make push MESSAGE="msg" # Commit and push with custom message
make help               # Show all available commands
```

## Notes

- The `data/` directory and model checkpoints are excluded from git
- Run `make setup` before working on assignments
- For the final project, see [Project/README.md](Project/README.md) for detailed instructions
