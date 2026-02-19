#!/bin/bash
# Install PyTorch with ROCm 5.7 for AMD GPU (Python 3.11).
# Creates named conda env "rocm-pytorch" under system conda (e.g. /opt/miniconda3).
set -e
ENV_NAME="${ROCM_ENV_NAME:-rocm-pytorch}"
REPO="https://repo.radeon.com/rocm/manylinux/rocm-rel-5.7"
TORCH_WHEEL="torch-2.0.1+rocm5.7-cp311-cp311-linux_x86_64.whl"
VISION_WHEEL="torchvision-0.15.2+rocm5.7-cp311-cp311-linux_x86_64.whl"

# Ensure conda is available
if ! command -v conda &> /dev/null; then
  [[ -f /opt/miniconda3/etc/profile.d/conda.sh ]] && source /opt/miniconda3/etc/profile.d/conda.sh
fi
command -v conda &> /dev/null || { echo "Error: conda not found. Install Miniconda (e.g. /opt/miniconda3) and ensure it is in PATH."; exit 1; }

echo "Creating conda env '$ENV_NAME' with Python 3.11..."
conda create -n "$ENV_NAME" python=3.11 -y

echo "Installing PyTorch ROCm wheels..."
conda run -n "$ENV_NAME" pip install "$REPO/$TORCH_WHEEL" "$REPO/$VISION_WHEEL"
# PyTorch 2.0.1 was built for NumPy 1.x; pin to avoid NumPy 2.x compatibility errors
conda run -n "$ENV_NAME" pip install "numpy<2"
# Notebook deps (HW3 needs these)
conda run -n "$ENV_NAME" pip install ipykernel matplotlib seaborn scikit-learn

echo "Checking GPU..."
conda run -n "$ENV_NAME" python -c "import torch; print('CUDA/ROCm:', torch.cuda.is_available()); print('Device:', torch.device('cuda') if torch.cuda.is_available() else 'cpu')"
echo ""
echo "Done. Use: conda activate $ENV_NAME   then run your notebook (select this env as kernel)."
echo "To register the Jupyter kernel with HSA fix: bash scripts/install_rocm_kernel.sh"
echo ""
echo "If kernel dies with 'rocBLAS ... gfx1032' (RX 6600 XT): add to ~/.bashrc and restart Cursor:"
echo "  export HSA_OVERRIDE_GFX_VERSION=10.3.0"
