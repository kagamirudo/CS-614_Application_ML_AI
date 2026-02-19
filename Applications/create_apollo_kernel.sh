#!/bin/bash
# Create a dedicated conda env (named "apollo") with ROCm PyTorch and register Jupyter kernel for Apollo (music restoration).
# Uses system conda (e.g. /opt/miniconda3). Run: make apollo-kernel   or   bash Applications/create_apollo_kernel.sh
# Then in Cursor/Jupyter: Kernel → "Python (Apollo)" (runs on AMD GPU when available)

set -e
ENV_NAME="${APOLLO_ENV_NAME:-apollo}"
KERNEL_NAME="${APOLLO_KERNEL_NAME:-apollo}"
DISPLAY_NAME="${APOLLO_KERNEL_DISPLAY_NAME:-Python (Apollo)}"

REPO="https://repo.radeon.com/rocm/manylinux/rocm-rel-5.7"
TORCH_WHEEL="torch-2.0.1+rocm5.7-cp311-cp311-linux_x86_64.whl"

# Ensure conda is available
if ! command -v conda &> /dev/null; then
  [[ -f /opt/miniconda3/etc/profile.d/conda.sh ]] && source /opt/miniconda3/etc/profile.d/conda.sh
fi
command -v conda &> /dev/null || { echo "Error: conda not found. Install Miniconda (e.g. /opt/miniconda3) and ensure it is in PATH."; exit 1; }

echo "Creating conda env '$ENV_NAME' (Python 3.11) under system conda..."
conda create -n "$ENV_NAME" python=3.11 -y

echo "Installing PyTorch ROCm (GPU) and Apollo notebook deps..."
conda run -n "$ENV_NAME" pip install --upgrade pip
conda run -n "$ENV_NAME" pip install "$REPO/$TORCH_WHEEL"
conda run -n "$ENV_NAME" pip install "numpy<2"
conda run -n "$ENV_NAME" pip install librosa soundfile huggingface_hub omegaconf pydub ipykernel

echo "Registering Jupyter kernel: $DISPLAY_NAME"
conda run -n "$ENV_NAME" python -m ipykernel install --user --name "$KERNEL_NAME" --display-name "$DISPLAY_NAME"

echo ""
echo "Checking GPU..."
conda run -n "$ENV_NAME" python -c "import torch; print('CUDA/ROCm:', torch.cuda.is_available()); print('Device:', torch.device('cuda') if torch.cuda.is_available() else 'cpu')"
echo ""
echo "Done. In Cursor/Jupyter select kernel: $DISPLAY_NAME (runs on AMD GPU)."
echo "Activate manually: conda activate $ENV_NAME"
echo "If kernel dies with 'rocBLAS ... gfx1032' (e.g. RX 6600 XT): add to ~/.bashrc and restart Cursor:"
echo "  export HSA_OVERRIDE_GFX_VERSION=10.3.0"
