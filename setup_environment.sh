#!/bin/bash
# Setup script for CS 614 - Applications of Machine Learning
# This script creates a conda environment and installs all required packages

set -e  # Exit on error

ENV_NAME="cs614"
PYTHON_VERSION="3.13"

echo "=========================================="
echo "CS 614 Environment Setup"
echo "=========================================="
echo ""

# Check if conda is installed
if ! command -v conda &> /dev/null; then
    echo "Error: conda is not installed or not in PATH"
    echo "Please install Miniconda or Anaconda first:"
    echo "  https://docs.conda.io/en/latest/miniconda.html"
    exit 1
fi

echo "Conda found: $(conda --version)"
echo ""

# Check if environment already exists
if conda env list | grep -q "^${ENV_NAME} "; then
    echo "Environment '${ENV_NAME}' already exists."
    read -p "Do you want to remove and recreate it? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Removing existing environment..."
        conda env remove -n ${ENV_NAME} -y
    else
        echo "Using existing environment. Activating..."
        conda activate ${ENV_NAME}
        echo "Installing/updating packages..."
        echo "Note: Reinstalling CPU version. For GPU, re-run setup script."
        pip install torch torchvision matplotlib numpy seaborn scikit-learn
        echo ""
        echo "Setup complete! To activate the environment, run:"
        echo "  conda activate ${ENV_NAME}"
        exit 0
    fi
fi

# Create new conda environment
echo "Creating conda environment '${ENV_NAME}' with Python ${PYTHON_VERSION}..."
conda create -n ${ENV_NAME} python=${PYTHON_VERSION} -y

echo ""
echo "Activating environment..."
source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate ${ENV_NAME}

echo ""
echo "GPU Support Selection:"
echo "  1) CPU only (default, works everywhere)"
echo "  2) NVIDIA GPU (CUDA)"
echo "  3) AMD GPU (ROCm)"
read -p "Select option [1-3] (default: 1): " gpu_choice
gpu_choice=${gpu_choice:-1}

echo ""
echo "Installing required packages via pip..."

case $gpu_choice in
    2)
        echo "Installing PyTorch with CUDA support for NVIDIA GPUs..."
        echo "Note: Make sure you have CUDA-compatible drivers installed"
        pip install torch torchvision --index-url https://download.pytorch.org/whl/cu121
        pip install matplotlib numpy seaborn scikit-learn
        ;;
    3)
        echo "Installing PyTorch with ROCm support for AMD GPUs..."
        echo "Note: ROCm support varies by GPU model and OS. Check PyTorch ROCm compatibility."
        echo "For Linux: Visit https://pytorch.org/get-started/locally/ and select ROCm"
        echo "For Windows: ROCm is not officially supported. Use CPU or WSL2 with ROCm."
        read -p "Continue with CPU fallback? (y/n) " continue_choice
        if [[ $continue_choice =~ ^[Yy]$ ]]; then
            pip install torch torchvision matplotlib numpy seaborn scikit-learn
            echo "Warning: Installed CPU version. For AMD GPU, you may need to install ROCm separately."
        else
            echo "Please install PyTorch with ROCm manually from: https://pytorch.org/get-started/locally/"
            pip install matplotlib numpy seaborn scikit-learn
        fi
        ;;
    *)
        echo "Installing CPU-only version (works everywhere)..."
        pip install torch torchvision matplotlib numpy seaborn scikit-learn
        ;;
esac

echo ""
echo "=========================================="
echo "Setup complete!"
echo "=========================================="
echo ""
echo "To activate the environment, run:"
echo "  conda activate ${ENV_NAME}"
echo ""
echo "To deactivate, run:"
echo "  conda deactivate"
echo ""
