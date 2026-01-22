# Setup script for CS 614 - Applications of Machine Learning
# This script creates a conda environment and installs all required packages
# PowerShell script for Windows

$ErrorActionPreference = "Stop"

$ENV_NAME = "cs614"
$PYTHON_VERSION = "3.13"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "CS 614 Environment Setup" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Check if conda is installed
try {
    $condaVersion = conda --version
    Write-Host "Conda found: $condaVersion" -ForegroundColor Green
} catch {
    Write-Host "Error: conda is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Please install Miniconda or Anaconda first:" -ForegroundColor Yellow
    Write-Host "  https://docs.conda.io/en/latest/miniconda.html" -ForegroundColor Yellow
    exit 1
}

Write-Host ""

# Check if environment already exists
$envExists = conda env list | Select-String -Pattern "^${ENV_NAME}\s"
if ($envExists) {
    Write-Host "Environment '$ENV_NAME' already exists." -ForegroundColor Yellow
    $response = Read-Host "Do you want to remove and recreate it? (y/n)"
    if ($response -eq "y" -or $response -eq "Y") {
        Write-Host "Removing existing environment..." -ForegroundColor Yellow
        conda env remove -n $ENV_NAME -y
    } else {
        Write-Host "Using existing environment. Activating..." -ForegroundColor Green
        conda activate $ENV_NAME
        Write-Host "Installing/updating packages..." -ForegroundColor Green
        pip install torch torchvision matplotlib numpy seaborn scikit-learn
        Write-Host ""
        Write-Host "Setup complete! To activate the environment, run:" -ForegroundColor Green
        Write-Host "  conda activate $ENV_NAME" -ForegroundColor Cyan
        exit 0
    }
}

# Create new conda environment
Write-Host "Creating conda environment '$ENV_NAME' with Python $PYTHON_VERSION..." -ForegroundColor Green
conda create -n $ENV_NAME python=$PYTHON_VERSION -y

Write-Host ""
Write-Host "Activating environment..." -ForegroundColor Green
conda activate $ENV_NAME

Write-Host ""
Write-Host "GPU Support Selection:" -ForegroundColor Cyan
Write-Host "  1) CPU only (default, works everywhere)" -ForegroundColor White
Write-Host "  2) NVIDIA GPU (CUDA)" -ForegroundColor White
Write-Host "  3) AMD GPU (ROCm)" -ForegroundColor White
$gpuChoice = Read-Host "Select option [1-3] (default: 1)"
if ([string]::IsNullOrWhiteSpace($gpuChoice)) { $gpuChoice = "1" }

Write-Host ""
Write-Host "Installing required packages via pip..." -ForegroundColor Green

switch ($gpuChoice) {
    "2" {
        Write-Host "Installing PyTorch with CUDA support for NVIDIA GPUs..." -ForegroundColor Yellow
        Write-Host "Note: Make sure you have CUDA-compatible drivers installed" -ForegroundColor Yellow
        pip install torch torchvision --index-url https://download.pytorch.org/whl/cu121
        pip install matplotlib numpy seaborn scikit-learn
    }
    "3" {
        Write-Host "Installing PyTorch with ROCm support for AMD GPUs..." -ForegroundColor Yellow
        Write-Host "Note: ROCm on Windows is not officially supported. Use CPU or WSL2 with ROCm." -ForegroundColor Red
        $continueChoice = Read-Host "Continue with CPU fallback? (y/n)"
        if ($continueChoice -eq "y" -or $continueChoice -eq "Y") {
            pip install torch torchvision matplotlib numpy seaborn scikit-learn
            Write-Host "Warning: Installed CPU version. For AMD GPU, you may need to install ROCm separately." -ForegroundColor Yellow
        } else {
            Write-Host "Please install PyTorch with ROCm manually from: https://pytorch.org/get-started/locally/" -ForegroundColor Yellow
            pip install matplotlib numpy seaborn scikit-learn
        }
    }
    default {
        Write-Host "Installing CPU-only version (works everywhere)..." -ForegroundColor Green
        pip install torch torchvision matplotlib numpy seaborn scikit-learn
    }
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Setup complete!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "To activate the environment, run:" -ForegroundColor Green
Write-Host "  conda activate $ENV_NAME" -ForegroundColor Cyan
Write-Host ""
Write-Host "To deactivate, run:" -ForegroundColor Green
Write-Host "  conda deactivate" -ForegroundColor Cyan
Write-Host ""
