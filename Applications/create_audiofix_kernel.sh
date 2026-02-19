#!/bin/bash
# Create a dedicated conda env (named "audiofix") for the scratch/click + AudioSR pipeline
# and register a Jupyter kernel for `Applications/music.ipynb`.
# Uses system conda (e.g. /opt/miniconda3).
#
# Run from repo root:
#   make audiofix-kernel
# or directly:
#   bash Applications/create_audiofix_kernel.sh
#
# Then in Cursor/Jupyter: Kernel → "Python (audiofix)" for Applications/music.ipynb

set -e
ENV_NAME="${AUDIOFIX_ENV_NAME:-audiofix}"
KERNEL_NAME="${AUDIOFIX_KERNEL_NAME:-audiofix}"
DISPLAY_NAME="${AUDIOFIX_KERNEL_DISPLAY_NAME:-Python (audiofix)}"

# Ensure conda is available
if ! command -v conda &> /dev/null; then
  [[ -f /opt/miniconda3/etc/profile.d/conda.sh ]] && source /opt/miniconda3/etc/profile.d/conda.sh
fi
command -v conda &> /dev/null || { echo "Error: conda not found. Install Miniconda (e.g. /opt/miniconda3) and ensure it is in PATH."; exit 1; }

echo "Creating conda env '$ENV_NAME' (Python 3.11, CPU libs only) under system conda..."
conda create -n "$ENV_NAME" python=3.11 -y

echo "Installing scratch/click restoration deps (NumPy/SciPy/librosa/soundfile/matplotlib + ipykernel)..."
conda run -n "$ENV_NAME" pip install --upgrade pip
conda run -n "$ENV_NAME" pip install numpy scipy soundfile librosa matplotlib ipykernel

echo "Registering Jupyter kernel: $DISPLAY_NAME"
conda run -n "$ENV_NAME" python -m ipykernel install --user --name "$KERNEL_NAME" --display-name "$DISPLAY_NAME"

echo ""
echo "Done. In Cursor/Jupyter select kernel: $DISPLAY_NAME for Applications/music.ipynb"
echo "Activate manually (if needed): conda activate $ENV_NAME"

