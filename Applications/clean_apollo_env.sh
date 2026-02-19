#!/bin/bash
# Remove Apollo conda env "apollo" and Jupyter kernel. Optionally remove legacy /opt/apollo-env (--all).
# Run: make apollo-clean   or   bash Applications/clean_apollo_env.sh
# To also remove legacy prefix env in /opt: bash Applications/clean_apollo_env.sh --all

set -e
REMOVE_OPT="${1:-}"

# Ensure conda is available
if ! command -v conda &> /dev/null; then
  [[ -f /opt/miniconda3/etc/profile.d/conda.sh ]] && source /opt/miniconda3/etc/profile.d/conda.sh
fi

echo "Cleaning previous Apollo installs..."

# 1. Remove conda env "apollo"
if conda env list 2>/dev/null | grep -q "^apollo "; then
  echo "Removing conda env 'apollo'..."
  conda env remove -n apollo -y
  echo "  Done."
else
  echo "No conda env named 'apollo' found."
fi

# 2. Unregister Jupyter kernel "apollo"
if jupyter kernelspec list 2>/dev/null | grep -q " apollo "; then
  echo "Unregistering Jupyter kernel 'apollo'..."
  jupyter kernelspec uninstall apollo -y
  echo "  Done."
else
  echo "No Jupyter kernel 'apollo' found."
fi

# 3. Optionally remove legacy /opt/apollo-env (old prefix install)
if [[ "$REMOVE_OPT" == "--all" ]]; then
  if [[ -d /opt/apollo-env ]]; then
    echo "Removing legacy /opt/apollo-env..."
    sudo rm -rf /opt/apollo-env
    echo "  Done."
  else
    echo "/opt/apollo-env not found."
  fi
else
  echo ""
  echo "To also remove legacy /opt/apollo-env (if present), run:"
  echo "  bash Applications/clean_apollo_env.sh --all"
fi

echo ""
echo "Cleanup finished."
