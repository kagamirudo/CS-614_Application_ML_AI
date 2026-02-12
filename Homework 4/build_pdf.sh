#!/usr/bin/env bash
# Compile HW4_Technical_Report.tex to PDF. Run from Homework 4 directory.
# Requires: pdflatex (install with: sudo apt install texlive-latex-base texlive-latex-extra)
set -e
cd "$(dirname "$0")"
pdflatex -interaction=nonstopmode HW4_Technical_Report.tex
pdflatex -interaction=nonstopmode HW4_Technical_Report.tex
echo "Done. Output: HW4_Technical_Report.pdf"
