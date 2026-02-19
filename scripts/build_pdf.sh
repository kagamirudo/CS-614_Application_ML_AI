#!/usr/bin/env bash
# Generic LaTeX to PDF compiler script
# Usage: build_pdf.sh <path_to_tex_file>
# Example: build_pdf.sh Homework\ 4/HW4_Technical_Report.tex
#
# Requires: pdflatex (install with: sudo apt install texlive-latex-base texlive-latex-extra)

set -e

if [ $# -eq 0 ]; then
    echo "Error: No LaTeX file specified"
    echo "Usage: $0 <path_to_tex_file>"
    exit 1
fi

TEX_FILE="$1"

if [ ! -f "$TEX_FILE" ]; then
    echo "Error: LaTeX file not found: $TEX_FILE"
    exit 1
fi

# Get directory and filename
TEX_DIR="$(dirname "$TEX_FILE")"
TEX_BASENAME="$(basename "$TEX_FILE" .tex)"

# Change to the directory containing the .tex file
cd "$TEX_DIR"

# Check if pdflatex is available
if ! command -v pdflatex &> /dev/null; then
    echo "Error: pdflatex is not installed"
    echo "Install with: sudo apt install texlive-latex-base texlive-latex-extra"
    exit 1
fi

echo "Compiling $TEX_BASENAME.tex..."
pdflatex -interaction=nonstopmode "$TEX_BASENAME.tex" > /dev/null
pdflatex -interaction=nonstopmode "$TEX_BASENAME.tex" > /dev/null

if [ -f "$TEX_BASENAME.pdf" ]; then
    echo "✓ Done. Output: $TEX_DIR/$TEX_BASENAME.pdf"
else
    echo "Error: PDF was not generated"
    exit 1
fi
