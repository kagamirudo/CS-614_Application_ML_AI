#!/bin/bash
# Clean up previous "audiofix" installs:
# - Named conda env "audiofix" (in Anaconda/miniconda envs)
# - Jupyter kernel "audiofix"
# - Optionally: prefix env at /opt/audiofix-env
#
# Run from repo root:
#   make audiofix-clean        # remove named env + kernel
#   make audiofix-clean-all    # same + remove /opt/audiofix-env

set -e
REMOVE_OPT="${1:-}"

echo "Cleaning audiofix env/kernel..."

# 1. Remove named conda env "audiofix" if it exists
if conda env list 2>/dev/null | grep -q "^audiofix[[:space:]]"; then
  echo "Removing conda env 'audiofix'..."
  conda env remove -n audiofix -y || true
  echo "  Done."
else
  echo "No conda env named 'audiofix' found."
fi

# 2. Unregister Jupyter kernel "audiofix" if it exists
if jupyter kernelspec list 2>/dev/null | grep -q "[[:space:]]audiofix[[:space:]]"; then
  echo "Unregistering Jupyter kernel 'audiofix'..."
  jupyter kernelspec uninstall audiofix -y || true
  echo "  Done."
else
  echo "No Jupyter kernel 'audiofix' found."
fi

# 3. Optionally remove /opt/audiofix-env (prefix env)
if [[ "$REMOVE_OPT" == "--all" ]]; then
  if [[ -d /opt/audiofix-env ]]; then
    echo "Removing /opt/audiofix-env (requires sudo)..."
    sudo rm -rf /opt/audiofix-env
    echo "  Done."
  else
    echo "/opt/audiofix-env not found."
  fi
else
  echo ""
  echo "To also remove the prefix env in /opt (free more space), run:"
  echo "  make audiofix-clean-all   # or: bash Applications/clean_audiofix_env.sh --all"
fi

echo ""
echo "audiofix cleanup finished."

