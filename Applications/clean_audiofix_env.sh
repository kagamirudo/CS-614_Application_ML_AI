#!/bin/bash
# Clean up "audiofix" conda env and Jupyter kernel. Optionally remove legacy /opt/audiofix-env (--all).
#
# Run from repo root:
#   make audiofix-clean        # remove env + kernel
#   make audiofix-clean-all    # same + remove legacy /opt/audiofix-env

set -e
REMOVE_OPT="${1:-}"

# Ensure conda is available
if ! command -v conda &> /dev/null; then
  [[ -f /opt/miniconda3/etc/profile.d/conda.sh ]] && source /opt/miniconda3/etc/profile.d/conda.sh
fi

echo "Cleaning audiofix env/kernel..."

# 1. Remove conda env "audiofix"
if conda env list 2>/dev/null | grep -q "^audiofix[[:space:]]"; then
  echo "Removing conda env 'audiofix'..."
  conda env remove -n audiofix -y || true
  echo "  Done."
else
  echo "No conda env named 'audiofix' found."
fi

# 2. Unregister Jupyter kernel "audiofix"
if jupyter kernelspec list 2>/dev/null | grep -q "[[:space:]]audiofix[[:space:]]"; then
  echo "Unregistering Jupyter kernel 'audiofix'..."
  jupyter kernelspec uninstall audiofix -y || true
  echo "  Done."
else
  echo "No Jupyter kernel 'audiofix' found."
fi

# 3. Optionally remove legacy /opt/audiofix-env (old prefix install)
if [[ "$REMOVE_OPT" == "--all" ]]; then
  if [[ -d /opt/audiofix-env ]]; then
    echo "Removing legacy /opt/audiofix-env (requires sudo)..."
    sudo rm -rf /opt/audiofix-env
    echo "  Done."
  else
    echo "/opt/audiofix-env not found."
  fi
else
  echo ""
  echo "To also remove legacy /opt/audiofix-env (if present), run:"
  echo "  make audiofix-clean-all   # or: bash Applications/clean_audiofix_env.sh --all"
fi

echo ""
echo "audiofix cleanup finished."

