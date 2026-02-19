#!/usr/bin/env bash
# Wrapper so the ROCm PyTorch kernel runs with HSA_OVERRIDE_GFX_VERSION=10.3.0 (fixes gfx1032 / RX 6600 XT).
# Python path is set by install_rocm_kernel.sh via ROCM_PYTHON in kernel.json (works with any envs_dirs).
export HSA_OVERRIDE_GFX_VERSION=10.3.0
if [[ -n "$ROCM_PYTHON" ]] && [[ -x "$ROCM_PYTHON" ]]; then
  exec "$ROCM_PYTHON" -m ipykernel_launcher "$@"
fi
CONDA_BASE="${CONDA_BASE:-/opt/miniconda3}"
ENV_NAME="${ROCM_ENV_NAME:-rocm-pytorch}"
exec "$CONDA_BASE/envs/$ENV_NAME/bin/python" -m ipykernel_launcher "$@"
