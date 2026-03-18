#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

NAME="gp492_final"
DEST="/tmp/$NAME"
ZIP="$SCRIPT_DIR/$NAME.zip"

echo "=== Building submission zip ==="

# Clean previous build
rm -rf "$DEST" "$ZIP"
mkdir -p "$DEST"

# --- Copy demo_code.ipynb (already clean, no outputs) ---
echo "Copying demo_code.ipynb..."
cp demo_code.ipynb "$DEST/demo.ipynb"
echo "  demo.ipynb -> $(du -h "$DEST/demo.ipynb" | cut -f1)"

# --- Copy notebooks ---
cp train_colab.ipynb "$DEST/"

# --- Copy Python scripts ---
cp finetune.py preencode_latents.py "$DEST/"

# --- Copy model code ---
cp -r sonicmaster "$DEST/sonicmaster"

# --- Copy configs ---
cp -r configs "$DEST/configs"

# --- Copy report (PDF only) ---
cp report/main.pdf "$DEST/" 2>/dev/null || echo "  Warning: main.pdf not found (run 'make pdf' in report/)"

# --- Copy README ---
cp README.md "$DEST/"

# --- Build zip ---
echo "Creating zip..."
cd /tmp
rm -f "$ZIP"
zip -r "$ZIP" "$NAME" -x "*/__pycache__/*" "*.pyc" "*/.ipynb_checkpoints/*"
cd "$SCRIPT_DIR"

# --- Summary ---
echo ""
echo "=== Submission zip ready ==="
echo "  Location: $ZIP"
echo "  Size:     $(du -h "$ZIP" | cut -f1)"
echo ""
echo "Contents:"
unzip -l "$ZIP" | tail -1
echo ""
echo "Reviewer instructions:"
echo "  1. Unzip and open demo.ipynb in Google Colab (A100 GPU)"
echo "  2. Run all cells -- data & checkpoint download automatically via gdown"
echo "  3. Drive folder: https://drive.google.com/drive/folders/1eyxwTykveOsbY3XybfIVmWsd1kFF4AAJ?usp=sharing"

# Cleanup temp
rm -rf "$DEST"
