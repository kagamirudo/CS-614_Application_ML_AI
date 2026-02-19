#!/usr/bin/env bash
# Move only the heavy parts of conda out of home: envs and pkgs.
# Optionally move ~/.anaconda (keyring) to /opt and symlink; keeps ~/.conda in home.
# Run: bash ~/conda-move-all-to-opt.sh

set -e
CONDA_DATA="${CONDA_DATA:-/opt/conda-data}"
CONDA_ROOT="${CONDA_ROOT:-/opt/miniconda3}"
CONDA_HOME="$HOME/.conda"

echo "=== Move conda envs + pkgs to $CONDA_DATA (keep ~/.conda in home) ==="
echo ""

# 1. Create /opt/conda-data/envs and pkgs (sudo + chown)
if [[ ! -d "$CONDA_DATA" ]]; then
  echo "Creating $CONDA_DATA (sudo required once)..."
  sudo mkdir -p "$CONDA_DATA"
  sudo chown "$USER:$USER" "$CONDA_DATA"
  echo "  Done."
fi
mkdir -p "$CONDA_DATA/envs" "$CONDA_DATA/pkgs"
echo ""

# 2. Move ~/.conda/envs to /opt/conda-data/envs
if [[ -d "$CONDA_HOME/envs" ]] && [[ ! -L "$CONDA_HOME/envs" ]]; then
  echo "Moving ~/.conda/envs to $CONDA_DATA/envs ..."
  for env in "$CONDA_HOME/envs"/*; do
    [[ -e "$env" ]] || continue
    name=$(basename "$env")
    if [[ -d "$CONDA_DATA/envs/$name" ]]; then
      echo "  (skip $name — already exists)"
    else
      mv "$env" "$CONDA_DATA/envs/"
      echo "  moved $name"
    fi
  done
  rmdir "$CONDA_HOME/envs" 2>/dev/null || true
  echo "  Done."
elif [[ -L "$CONDA_HOME/envs" ]]; then
  echo "~/.conda/envs is already a symlink. Skipping."
else
  echo "No ~/.conda/envs to move."
fi
echo ""

# 3. Move ~/.conda/pkgs to /opt/conda-data/pkgs
if [[ -d "$CONDA_HOME/pkgs" ]] && [[ ! -L "$CONDA_HOME/pkgs" ]]; then
  echo "Moving ~/.conda/pkgs to $CONDA_DATA/pkgs ..."
  for pkg in "$CONDA_HOME/pkgs"/*; do
    [[ -e "$pkg" ]] || continue
    name=$(basename "$pkg")
    dest="$CONDA_DATA/pkgs/$name"
    if [[ -e "$dest" ]]; then
      echo "  (skip $name)"
    else
      mv "$pkg" "$dest"
    fi
  done
  rmdir "$CONDA_HOME/pkgs" 2>/dev/null || true
  echo "  Done."
elif [[ -L "$CONDA_HOME/pkgs" ]]; then
  echo "~/.conda/pkgs is already a symlink. Skipping."
else
  echo "No ~/.conda/pkgs to move."
fi
echo ""

# 4. Point ~/.conda/envs and ~/.conda/pkgs at /opt (so conda still finds them under ~/.conda)
if [[ ! -d "$CONDA_HOME/envs" ]] && [[ ! -L "$CONDA_HOME/envs" ]]; then
  ln -snf "$CONDA_DATA/envs" "$CONDA_HOME/envs"
  echo "Linked ~/.conda/envs -> $CONDA_DATA/envs"
fi
if [[ ! -d "$CONDA_HOME/pkgs" ]] && [[ ! -L "$CONDA_HOME/pkgs" ]]; then
  ln -snf "$CONDA_DATA/pkgs" "$CONDA_HOME/pkgs"
  echo "Linked ~/.conda/pkgs -> $CONDA_DATA/pkgs"
fi
echo ""

# 4b. Move ~/.anaconda (keyring for anaconda-auth) to /opt and symlink (it's small; optional)
if [[ -d "$HOME/.anaconda" ]] && [[ ! -L "$HOME/.anaconda" ]]; then
  echo "Moving ~/.anaconda to $CONDA_DATA/.anaconda ..."
  mv "$HOME/.anaconda" "$CONDA_DATA/.anaconda"
  ln -snf "$CONDA_DATA/.anaconda" "$HOME/.anaconda"
  echo "  Linked ~/.anaconda -> $CONDA_DATA/.anaconda"
elif [[ -L "$HOME/.anaconda" ]]; then
  echo "~/.anaconda is already a symlink. Skipping."
else
  echo "No ~/.anaconda to move."
fi
echo ""

# 5. Update ~/.conda/environments.txt so paths use the new location
if [[ -f "$CONDA_HOME/environments.txt" ]]; then
  if grep -q "$CONDA_HOME/envs" "$CONDA_HOME/environments.txt" 2>/dev/null; then
    echo "Updating paths in ~/.conda/environments.txt ..."
    sed -i "s|$CONDA_HOME/envs|$CONDA_DATA/envs|g" "$CONDA_HOME/environments.txt"
    sed -i "s|$HOME/.conda/envs|$CONDA_DATA/envs|g" "$CONDA_HOME/environments.txt"
    echo "  Done."
  fi
fi
echo ""

# 6. Ensure .condarc has envs_dirs and pkgs_dirs (so new envs/pkgs go to /opt)
CONDARC="$HOME/.condarc"
if ! grep -q "envs_dirs:" "$CONDARC" 2>/dev/null; then
  echo "Adding envs_dirs and pkgs_dirs to ~/.condarc ..."
  {
    echo ""
    echo "# Heavy data on /opt (conda-move-all-to-opt.sh)"
    echo "envs_dirs:"
    echo "  - $CONDA_ROOT/envs"
    echo "  - $CONDA_DATA/envs"
    echo "pkgs_dirs:"
    echo "  - $CONDA_DATA/pkgs"
    echo "  - $CONDA_ROOT/pkgs"
  } >> "$CONDARC"
  echo "  Done."
else
  echo "~/.condarc already has envs_dirs/pkgs_dirs."
fi

echo ""
echo "=== Done ==="
echo ""
echo "Summary:"
echo "  ~/.conda stays in home (config, tokens, environments.txt)."
echo "  ~/.conda/envs -> $CONDA_DATA/envs (symlink)"
echo "  ~/.conda/pkgs -> $CONDA_DATA/pkgs (symlink)"
echo "  ~/.anaconda -> $CONDA_DATA/.anaconda (symlink, if moved)"
echo "  New envs/pkgs will use $CONDA_DATA and $CONDA_ROOT."
echo ""
