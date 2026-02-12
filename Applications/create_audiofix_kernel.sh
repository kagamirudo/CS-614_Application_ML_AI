#!/bin/bash
# Create a dedicated conda env in /opt for the scratch/click + AudioSR pipeline
# and register a Jupyter kernel for `Applications/music.ipynb`.
#
# Run from repo root:
#   make audiofix-kernel
# or directly:
#   bash Applications/create_audiofix_kernel.sh
#
# Then in Cursor/Jupyter: Kernel → "Python (audiofix)" for Applications/music.ipynb
#
# Override install location:
#   INSTALL_PREFIX=/opt/audiofix-env-alt bash Applications/create_audiofix_kernel.sh

set -e
INSTALL_PREFIX="${INSTALL_PREFIX:-/opt/audiofix-env}"
KERNEL_NAME="${AUDIOFIX_KERNEL_NAME:-audiofix}"
DISPLAY_NAME="${AUDIOFIX_KERNEL_DISPLAY_NAME:-Python (audiofix)}"

echo "Install prefix: $INSTALL_PREFIX (override with: INSTALL_PREFIX=/other/path $0)"
if [[ ! -d "$INSTALL_PREFIX" ]]; then
  echo "Creating $INSTALL_PREFIX (may need sudo)..."
  sudo mkdir -p "$INSTALL_PREFIX"
  sudo chown "$USER:$USER" "$INSTALL_PREFIX"
fi

echo "Creating conda env at $INSTALL_PREFIX (Python 3.11, CPU libs only)"
conda create --prefix "$INSTALL_PREFIX" python=3.11 -y

echo "Installing scratch/click restoration deps (NumPy/SciPy/librosa/soundfile/matplotlib + ipykernel)..."
conda run --prefix "$INSTALL_PREFIX" pip install --upgrade pip
conda run --prefix "$INSTALL_PREFIX" pip install numpy scipy soundfile librosa matplotlib ipykernel

echo "Registering Jupyter kernel: $DISPLAY_NAME"
conda run --prefix "$INSTALL_PREFIX" python -m ipykernel install --user --name "$KERNEL_NAME" --display-name "$DISPLAY_NAME"

echo ""
echo "Done. In Cursor/Jupyter select kernel: $DISPLAY_NAME for Applications/music.ipynb"
echo "Activate manually (if needed): conda activate $INSTALL_PREFIX"

