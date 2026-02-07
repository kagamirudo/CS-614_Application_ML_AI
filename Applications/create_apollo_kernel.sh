#!/bin/bash
# Create a dedicated conda env in /opt with ROCm PyTorch and register Jupyter kernel for Apollo (music restoration).
# Run: make apollo-kernel   or   bash Applications/create_apollo_kernel.sh
# Then in Cursor/Jupyter: Kernel → "Python (Apollo)" (runs on AMD GPU when available)
# Override install location: INSTALL_PREFIX=/other/path bash create_apollo_kernel.sh

set -e
INSTALL_PREFIX="${INSTALL_PREFIX:-/opt/apollo-env}"
KERNEL_NAME="${APOLLO_KERNEL_NAME:-apollo}"
DISPLAY_NAME="${APOLLO_KERNEL_DISPLAY_NAME:-Python (Apollo)}"

REPO="https://repo.radeon.com/rocm/manylinux/rocm-rel-5.7"
TORCH_WHEEL="torch-2.0.1+rocm5.7-cp311-cp311-linux_x86_64.whl"

echo "Install prefix: $INSTALL_PREFIX (override with: INSTALL_PREFIX=/other/path $0)"
if [[ ! -d "$INSTALL_PREFIX" ]]; then
  echo "Creating $INSTALL_PREFIX (may need sudo)..."
  sudo mkdir -p "$INSTALL_PREFIX"
  sudo chown "$USER:$USER" "$INSTALL_PREFIX"
fi

echo "Creating conda env at $INSTALL_PREFIX (Python 3.11)"
conda create --prefix "$INSTALL_PREFIX" python=3.11 -y

echo "Installing PyTorch ROCm (GPU) and Apollo notebook deps..."
conda run --prefix "$INSTALL_PREFIX" pip install --upgrade pip
conda run --prefix "$INSTALL_PREFIX" pip install "$REPO/$TORCH_WHEEL"
conda run --prefix "$INSTALL_PREFIX" pip install "numpy<2"
conda run --prefix "$INSTALL_PREFIX" pip install librosa soundfile huggingface_hub omegaconf pydub ipykernel

echo "Registering Jupyter kernel: $DISPLAY_NAME"
conda run --prefix "$INSTALL_PREFIX" python -m ipykernel install --user --name "$KERNEL_NAME" --display-name "$DISPLAY_NAME"

echo ""
echo "Checking GPU..."
conda run --prefix "$INSTALL_PREFIX" python -c "import torch; print('CUDA/ROCm:', torch.cuda.is_available()); print('Device:', torch.device('cuda') if torch.cuda.is_available() else 'cpu')"
echo ""
echo "Done. In Cursor/Jupyter select kernel: $DISPLAY_NAME (runs on AMD GPU)."
echo "Activate manually: conda activate $INSTALL_PREFIX"
echo "If kernel dies with 'rocBLAS ... gfx1032' (e.g. RX 6600 XT): add to ~/.bashrc and restart Cursor:"
echo "  export HSA_OVERRIDE_GFX_VERSION=10.3.0"
