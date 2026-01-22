# CS 614 - Applications of Machine Learning

This repository contains assignments and projects for CS 614 - Applications of Machine Learning.

## Contents

- **HW1.ipynb**: Programming Assignment 1
- **HW2.ipynb**: Programming Assignment 2 - CNN for MNIST digit classification

## Setup Instructions

### Prerequisites

- [Miniconda](https://docs.conda.io/en/latest/miniconda.html) or [Anaconda](https://www.anaconda.com/products/distribution) installed
- Git installed

### Environment Setup

#### For Linux/Mac:

```bash
bash setup_environment.sh
```

#### For Windows (PowerShell):

```powershell
.\setup_environment.ps1
```

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
conda activate cs614
python check_gpu.py
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

For AMD GPUs, you may need to install PyTorch with ROCm manually:
```bash
# Visit https://pytorch.org/get-started/locally/ and select:
# - OS: Linux
# - Package: Pip
# - Compute Platform: ROCm (select your ROCm version)
```

### Running the Notebooks

1. Activate the conda environment
2. Start Jupyter:
   ```bash
   jupyter notebook
   ```
3. Open the desired notebook (HW1.ipynb or HW2.ipynb)

## Repository Structure

```
CS614/
├── .gitignore              # Git ignore file (excludes data files)
├── setup_environment.sh    # Environment setup script (Linux/Mac)
├── setup_environment.ps1   # Environment setup script (Windows)
├── check_gpu.py            # GPU detection script
├── README.md               # This file
├── HW1.ipynb               # Assignment 1
├── HW2.ipynb               # Assignment 2
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
   # Option 1: Using Makefile (recommended)
   make push                    # Uses default message
   make push MESSAGE="Your commit message here"
   
   # Option 2: Use the helper script
   ./push_to_github.sh <your-github-username>
   
   # Option 3: Manual commands
   git add -A
   git commit -m "Your message"
   git push origin main
   ```

## Notes

- The `data/` directory is excluded from git to avoid committing large data files
- Model checkpoints and temporary files are also excluded
- Make sure to run the setup script before working on assignments
