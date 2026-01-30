#!/usr/bin/env bash
# Wrapper so the ROCm PyTorch kernel runs with HSA_OVERRIDE_GFX_VERSION=10.3.0 (fixes gfx1032 / RX 6600 XT)
export HSA_OVERRIDE_GFX_VERSION=10.3.0
exec /opt/rocm-pytorch/bin/python -m ipykernel_launcher "$@"
