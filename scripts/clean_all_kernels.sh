#!/usr/bin/env bash
# Uninstall all CS614-related Jupyter kernels (cs614, apollo, audiofix, rocm-pytorch).
# Run: make clean-all-kernels   or   bash scripts/clean_all_kernels.sh

set -e
KERNELS="cs614 apollo audiofix rocm-pytorch"

echo "Uninstalling CS614 Jupyter kernels..."
for name in $KERNELS; do
  if jupyter kernelspec list 2>/dev/null | grep -q "[[:space:]]${name}[[:space:]]"; then
    echo "  Uninstalling kernel: $name"
    jupyter kernelspec uninstall "$name" -y || true
  else
    echo "  (no kernel: $name)"
  fi
done
echo "Done."
jupyter kernelspec list 2>/dev/null || true
