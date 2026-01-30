#!/usr/bin/env bash
# Register a Jupyter kernel for /opt/rocm-pytorch that sets HSA_OVERRIDE_GFX_VERSION (fixes gfx1032 crash)
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WRAPPER="$SCRIPT_DIR/rocm_kernel_wrapper.sh"
KERNEL_DIR="${HOME}/.local/share/jupyter/kernels/rocm-pytorch"

chmod +x "$WRAPPER"
mkdir -p "$KERNEL_DIR"
cat > "$KERNEL_DIR/kernel.json" << EOF
{
  "argv": ["$WRAPPER", "-f", "{connection_file}"],
  "display_name": "Python (rocm-pytorch GPU)",
  "language": "python"
}
EOF
echo "Kernel installed. In Cursor: select kernel 'Python (rocm-pytorch GPU)' for your notebook."
jupyter kernelspec list
