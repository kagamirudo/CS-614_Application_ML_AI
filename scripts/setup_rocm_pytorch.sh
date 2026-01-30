#!/bin/bash
# Install PyTorch with ROCm 5.7 for AMD GPU (Python 3.11).
# Uses /opt to avoid filling /home (set INSTALL_PREFIX to change).
set -e
INSTALL_PREFIX="${INSTALL_PREFIX:-/opt/rocm-pytorch}"
REPO="https://repo.radeon.com/rocm/manylinux/rocm-rel-5.7"
TORCH_WHEEL="torch-2.0.1+rocm5.7-cp311-cp311-linux_x86_64.whl"
VISION_WHEEL="torchvision-0.15.2+rocm5.7-cp311-cp311-linux_x86_64.whl"

echo "Install prefix: $INSTALL_PREFIX (override with: INSTALL_PREFIX=/other/path $0)"
if [[ ! -d "$INSTALL_PREFIX" ]]; then
  echo "Creating $INSTALL_PREFIX (may need sudo)..."
  sudo mkdir -p "$INSTALL_PREFIX"
  sudo chown "$USER:$USER" "$INSTALL_PREFIX"
fi

echo "Creating conda env at $INSTALL_PREFIX with Python 3.11..."
conda create --prefix "$INSTALL_PREFIX" python=3.11 -y

echo "Installing PyTorch ROCm wheels..."
conda run --prefix "$INSTALL_PREFIX" pip install "$REPO/$TORCH_WHEEL" "$REPO/$VISION_WHEEL"
# PyTorch 2.0.1 was built for NumPy 1.x; pin to avoid NumPy 2.x compatibility errors
conda run --prefix "$INSTALL_PREFIX" pip install "numpy<2"
# Notebook deps (HW3 needs these)
conda run --prefix "$INSTALL_PREFIX" pip install ipykernel matplotlib seaborn scikit-learn

echo "Checking GPU..."
conda run --prefix "$INSTALL_PREFIX" python -c "import torch; print('CUDA/ROCm:', torch.cuda.is_available()); print('Device:', torch.device('cuda') if torch.cuda.is_available() else 'cpu')"
echo ""
echo "Done. Use: conda activate $INSTALL_PREFIX   then run your notebook (select this env as kernel)."
echo ""
echo "If kernel dies with 'rocBLAS ... gfx1032' (RX 6600 XT): add to ~/.bashrc and restart Cursor:"
echo "  export HSA_OVERRIDE_GFX_VERSION=10.3.0"
