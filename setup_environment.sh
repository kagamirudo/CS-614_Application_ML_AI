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
echo "Installing required packages via pip..."
echo "Note: Using pip because PyTorch for Python 3.13 is available via pip"
pip install torch torchvision matplotlib numpy seaborn scikit-learn

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
