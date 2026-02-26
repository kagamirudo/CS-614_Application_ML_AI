#!/bin/sh
# Install git hooks that clean notebook metadata on push/pull (Colab → GitHub).
# Run once from repo root: ./scripts/install-notebook-hooks.sh
set -e
ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"
HOOKS_SRC="$ROOT/scripts/git-hooks"
HOOKS_DEST="$ROOT/.git/hooks"
for hook in post-merge pre-push; do
  if [ -f "$HOOKS_SRC/$hook" ]; then
    cp "$HOOKS_SRC/$hook" "$HOOKS_DEST/$hook"
    chmod +x "$HOOKS_DEST/$hook"
    echo "Installed .git/hooks/$hook"
  fi
done
echo "Done. Notebooks will be cleaned when you push or after you pull."
