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
Write-Host "Installing required packages via pip..." -ForegroundColor Green
Write-Host "Note: Using pip because PyTorch for Python 3.13 is available via pip" -ForegroundColor Yellow
pip install torch torchvision matplotlib numpy seaborn scikit-learn

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
