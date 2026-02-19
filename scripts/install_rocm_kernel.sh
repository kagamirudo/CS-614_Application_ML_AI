#!/usr/bin/env bash
# Register a Jupyter kernel for the "rocm-pytorch" conda env that sets HSA_OVERRIDE_GFX_VERSION (fixes gfx1032 crash).
# Requires conda env "rocm-pytorch" (create with: bash scripts/setup_rocm_pytorch.sh).
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Use absolute path so Jupyter/Cursor can spawn the wrapper (they do not expand ~)
WRAPPER="$(cd "$SCRIPT_DIR" && pwd)/rocm_kernel_wrapper.sh"
KERNEL_DIR="$HOME/.local/share/jupyter/kernels/rocm-pytorch"
ENV_NAME="${ROCM_ENV_NAME:-rocm-pytorch}"

# Ensure conda is available
if ! command -v conda &> /dev/null; then
  [[ -f /opt/miniconda3/etc/profile.d/conda.sh ]] && source /opt/miniconda3/etc/profile.d/conda.sh
fi
# Resolve env path (env may be in CONDA_BASE/envs or in envs_dirs like ~/.conda/envs or /opt/conda-data/envs)
ENV_PATH=$(conda info --envs 2>/dev/null | awk -v n="$ENV_NAME" '$1==n {print $NF; exit}')
if [[ -z "$ENV_PATH" ]] || [[ ! -d "$ENV_PATH" ]]; then
  CONDA_BASE="$(conda info --base 2>/dev/null)" || CONDA_BASE="/opt/miniconda3"
  if [[ -d "$CONDA_BASE/envs/$ENV_NAME" ]]; then
    ENV_PATH="$CONDA_BASE/envs/$ENV_NAME"
  else
    echo "Error: conda env '$ENV_NAME' not found. Create it first: bash scripts/setup_rocm_pytorch.sh"
    exit 1
  fi
fi
PYTHON_PATH="$ENV_PATH/bin/python"
if [[ ! -x "$PYTHON_PATH" ]]; then
  echo "Error: $PYTHON_PATH not found or not executable."
  exit 1
fi

chmod +x "$WRAPPER"
mkdir -p "$KERNEL_DIR"
# Pass the resolved env path so wrapper works regardless of envs_dirs
cat > "$KERNEL_DIR/kernel.json" << EOF
{
  "argv": ["$WRAPPER", "-f", "{connection_file}"],
  "display_name": "Python (rocm-pytorch GPU)",
  "language": "python",
  "env": {"ROCM_PYTHON": "$PYTHON_PATH"}
}
EOF
echo "Kernel installed. In Cursor: select kernel 'Python (rocm-pytorch GPU)' for your notebook."
jupyter kernelspec list
