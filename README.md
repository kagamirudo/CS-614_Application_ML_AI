# CS 614 - Applications of Machine Learning

This repository contains assignments and projects for CS 614 - Applications of Machine Learning.

## Contents

- **Homework 1/**: Programming Assignment 1
- **Homework 2/**: Programming Assignment 2 - CNN for MNIST digit classification
- **Homework 3/**: Programming Assignment 3 - Transfer learning (ResNet18 on CIFAR-10), with technical document and saved figures

## Quick Start

### Prerequisites

Check if you have all requirements:

```bash
bash scripts/check_requirements.sh
```

Required tools:
- [Make](https://www.gnu.org/software/make/) installed
  - **Linux/Mac**: Usually pre-installed. If not: `sudo apt-get install make` (Linux) or `xcode-select --install` (Mac)
  - **Windows**: Install via [Chocolatey](https://chocolatey.org/) (`choco install make`) or [GnuWin32](http://gnuwin32.sourceforge.net/packages/make.htm)
- [Miniconda](https://docs.conda.io/en/latest/miniconda.html) or [Anaconda](https://www.anaconda.com/products/distribution) installed
- Git installed

**Note**: If you don't have `make` installed, you can still run the setup scripts directly:
- Linux/Mac: `bash scripts/setup_environment.sh`
- Windows: `powershell -ExecutionPolicy Bypass -File scripts/setup_environment.ps1`

### Environment Setup

**Easy way (auto-detects OS):**

```bash
make setup
```

This will:
- Auto-detect your operating system (Linux/Mac/Windows)
- Run the appropriate setup script
- Check for required tools (conda, Python)
- Guide you through GPU selection if needed

**Manual way:**

- **Linux/Mac**: `bash scripts/setup_environment.sh`
- **Windows**: `powershell -ExecutionPolicy Bypass -File scripts/setup_environment.ps1`

This will:
1. Create a conda environment named `cs614` with Python 3.13
2. Ask you to select GPU support:
   - **CPU only** (default, works everywhere)
   - **NVIDIA GPU** (CUDA)
   - **AMD GPU** (ROCm)
3. Install all required packages:
   - PyTorch (with appropriate GPU support if selected)
   - torchvision
   - matplotlib
   - numpy
   - seaborn
   - scikit-learn

### Activating the Environment

After setup, activate the environment:

```bash
conda activate cs614
```

### GPU Support

#### Checking GPU Availability

After setup, check if your GPU is detected:

```bash
# Using Makefile (recommended)
make check-gpu

# Or manually
conda activate cs614
python scripts/check_gpu.py
```

This script will show:
- PyTorch version
- CUDA (NVIDIA) availability and GPU info
- ROCm (AMD) availability and GPU info
- Device recommendations

#### Using GPU in Your Code

If GPU is available, you can use it in your notebooks:

```python
import torch

# Check if CUDA is available
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
print(f'Using device: {device}')

# Move tensors/models to GPU
model = model.to(device)
images = images.to(device)
```

#### AMD GPU (ROCm) Notes

- **Linux**: ROCm support is available. Check [PyTorch ROCm compatibility](https://pytorch.org/get-started/locally/) for your GPU model.
- **Windows**: ROCm is not officially supported on Windows. Options:
  - Use CPU version (slower but works)
  - Use WSL2 with ROCm support
  - Check for community builds or alternative solutions

For AMD GPUs (e.g. RX 6600 XT), you may need to install PyTorch with ROCm manually or use the project scripts:
```bash
# Option 1: Use project scripts (ROCm 5.7, Python 3.11)
bash scripts/setup_rocm_pytorch.sh   # Creates env at /opt/rocm-pytorch
bash scripts/install_rocm_kernel.sh  # Registers "Python (rocm-pytorch GPU)" Jupyter kernel
# Then select that kernel in Jupyter for HW3 (uses gfx1032 workaround via rocm_kernel_wrapper.sh).

# Option 2: Visit https://pytorch.org/get-started/locally/ and select:
# - OS: Linux, Package: Pip, Compute Platform: ROCm (your version)
```

### Running the Notebooks

1. Activate the conda environment
2. Start Jupyter:
   ```bash
   jupyter notebook
   ```
3. Navigate to and open the desired notebook:
   - `Homework 1/HW1.ipynb` - Assignment 1
   - `Homework 2/HW2.ipynb` - Assignment 2
   - `Homework 3/HW3.ipynb` - Assignment 3 (ResNet18 fine-tuning on CIFAR-10)

## Repository Structure

```
CS614/
├── Makefile                # Main Makefile for all commands
├── LICENSE                 # MIT License
├── README.md               # This file
├── .gitignore              # Git ignore file (excludes data files)
├── Homework 1/             # Assignment 1
│   └── HW1.ipynb
├── Homework 2/             # Assignment 2
│   └── HW2.ipynb
├── Homework 3/             # Assignment 3 (transfer learning)
│   ├── HW3.ipynb           # ResNet18 fine-tuning on CIFAR-10
│   └── HW3_Technical_Document.md
├── scripts/                # Setup and utility scripts
│   ├── setup_environment.sh      # Environment setup (Linux/Mac)
│   ├── setup_environment.ps1    # Environment setup (Windows)
│   ├── check_gpu.py              # GPU detection script
│   ├── check_requirements.sh    # Requirements checker
│   ├── setup_rocm_pytorch.sh     # ROCm PyTorch env (AMD GPU)
│   ├── rocm_kernel_wrapper.sh   # Jupyter kernel wrapper (gfx1032 workaround)
│   └── install_rocm_kernel.sh   # Register ROCm Jupyter kernel
└── data/                   # Data directory (gitignored)
```

## Pushing to GitHub

1. **Create the repository on GitHub:**
   - Go to https://github.com/new
   - Repository name: `CS-614_Application_ML_AI`
   - Choose private or public
   - **DO NOT** initialize with README, .gitignore, or license (we already have these)
   - Click "Create repository"

2. **Set up the remote (first time only):**
   ```bash
   git remote add origin https://github.com/kagamirudo/CS-614_Application_ML_AI.git
   ```

3. **Push your code:**
   ```bash
   # Using Makefile (recommended)
   make push                    # Uses default message
   make push MESSAGE="Your commit message here"
   
   # Or manually
   git add -A
   git commit -m "Your message"
   git push origin main
   ```

## Available Make Commands

```bash
make setup              # Set up conda environment (auto-detects OS)
make check-gpu          # Check GPU availability
make push               # Commit and push to GitHub (default message)
make push MESSAGE="msg" # Commit and push with custom message
make help               # Show all available commands
```

## Notes

- The `data/` directory is excluded from git to avoid committing large data files
- Model checkpoints and temporary files are also excluded
- Run `make setup` before working on assignments
- All scripts are organized in the `scripts/` folder for a clean root directory
