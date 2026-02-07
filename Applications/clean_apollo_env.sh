#!/bin/bash
# Remove previous Apollo installs: old named env "apollo", Jupyter kernel, and optionally /opt/apollo-env.
# Run: make -C Applications apollo-clean   or   bash Applications/clean_apollo_env.sh
# To also remove the env in /opt: bash Applications/clean_apollo_env.sh --all

set -e
REMOVE_OPT="${1:-}"

echo "Cleaning previous Apollo installs..."

# 1. Remove old named conda env "apollo" (from when we used conda create --name apollo)
if conda env list | grep -q "^apollo "; then
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

# 3. Optionally remove /opt/apollo-env (prefix install)
if [[ "$REMOVE_OPT" == "--all" ]]; then
  if [[ -d /opt/apollo-env ]]; then
    echo "Removing /opt/apollo-env (run kernel uninstall above first if you use it)..."
    sudo rm -rf /opt/apollo-env
    echo "  Done."
  else
    echo "/opt/apollo-env not found."
  fi
else
  echo ""
  echo "To also remove the env in /opt (free more space), run:"
  echo "  bash Applications/clean_apollo_env.sh --all"
fi

echo ""
echo "Cleanup finished."
