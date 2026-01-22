#!/bin/bash
# Check if required tools are installed
# This can be run without make: bash scripts/check_requirements.sh

echo "=========================================="
echo "Checking Requirements"
echo "=========================================="
echo ""

# Check for make
if command -v make >/dev/null 2>&1; then
    echo "✓ make found: $(make --version | head -n1)"
else
    echo "❌ make is NOT installed"
    echo ""
    echo "Installation instructions:"
    echo "  Linux (Debian/Ubuntu): sudo apt-get install make"
    echo "  Linux (RedHat/CentOS): sudo yum install make"
    echo "  Mac: xcode-select --install"
    echo "  Windows:"
    echo "    - Chocolatey: choco install make"
    echo "    - Or download from: http://gnuwin32.sourceforge.net/packages/make.htm"
    echo ""
fi

# Check for conda
if command -v conda >/dev/null 2>&1; then
    echo "✓ conda found: $(conda --version)"
else
    echo "❌ conda is NOT installed"
    echo "   Install from: https://docs.conda.io/en/latest/miniconda.html"
    echo ""
fi

# Check for Python
if command -v python3 >/dev/null 2>&1; then
    echo "✓ python3 found: $(python3 --version)"
elif command -v python >/dev/null 2>&1; then
    echo "✓ python found: $(python --version)"
else
    echo "❌ Python is NOT installed"
    echo ""
fi

# Check for git
if command -v git >/dev/null 2>&1; then
    echo "✓ git found: $(git --version)"
else
    echo "❌ git is NOT installed"
    echo "   Install from: https://git-scm.com/downloads"
    echo ""
fi

echo "=========================================="
if command -v make >/dev/null 2>&1 && command -v conda >/dev/null 2>&1; then
    echo "✓ All requirements met! You can run 'make setup'"
else
    echo "⚠️  Some requirements are missing. Please install them first."
fi
echo "=========================================="
