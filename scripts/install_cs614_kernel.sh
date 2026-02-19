#!/usr/bin/env bash
# Register the cs614 conda env as a Jupyter kernel so notebooks can use matching torch+torchvision.
# Run: make cs614-kernel   or   bash scripts/install_cs614_kernel.sh
# Then in Cursor/Jupyter: Kernel → Change Kernel → Python (cs614)
# Use this kernel for HW4 (object detection) so torchvision C++ ops load correctly.
#
# For AMD GPU: use kernel "Python (rocm-pytorch GPU)" instead (see scripts/setup_rocm_pytorch.sh and scripts/install_rocm_kernel.sh).

set -e
ENV_NAME="cs614"

# Ensure conda is available (e.g. when run via make without interactive shell)
if ! command -v conda &> /dev/null; then
  [[ -f /opt/miniconda3/etc/profile.d/conda.sh ]] && source /opt/miniconda3/etc/profile.d/conda.sh
fi
if ! conda env list | grep -q "^${ENV_NAME} "; then
  echo "Conda env '${ENV_NAME}' not found. Create it first:"
  echo "  make setup"
  exit 1
fi

echo "Registering Jupyter kernel: Python (cs614) from env '${ENV_NAME}'..."
conda run -n "${ENV_NAME}" python -m ipykernel install --user --name "${ENV_NAME}" --display-name "Python (cs614)"

echo ""
echo "Done. In Cursor: Kernel → Change Kernel → Python (cs614)"
echo "Then re-run your notebook. HW4 detection should work (matching torch + torchvision)."
jupyter kernelspec list 2>/dev/null || true
