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
2. Install all required packages:
   - PyTorch
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
