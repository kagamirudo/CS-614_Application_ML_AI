.PHONY: push setup help check-tools cs614 rocm-env rocm-kernel apollo-kernel apollo-clean apollo-clean-all audiofix-kernel audiofix-clean audiofix-clean-all clean-all-kernels TAR

# Default commit message if not provided
MESSAGE ?= "Update repository"

# Detect OS
UNAME_S := $(shell uname -s 2>/dev/null || echo "Unknown")
ifeq ($(UNAME_S),Linux)
    OS := linux
    SETUP_SCRIPT := scripts/setup_environment.sh
endif
ifeq ($(UNAME_S),Darwin)
    OS := macos
    SETUP_SCRIPT := scripts/setup_environment.sh
endif
ifeq ($(OS),Windows_NT)
    OS := windows
    SETUP_SCRIPT := scripts/setup_environment.ps1
endif
# Fallback detection for Windows (PowerShell/CMD)
ifeq ($(UNAME_S),Unknown)
    ifeq ($(shell echo $$OS),Windows_NT)
        OS := windows
        SETUP_SCRIPT := scripts/setup_environment.ps1
    endif
endif

# Default target - if TAR is set, build PDF; otherwise show help
.DEFAULT_GOAL := help

help:
	@if [ -n "$(TAR)" ]; then \
		$(MAKE) TAR; \
	else \
		echo "CS 614 — make targets"; \
		echo ""; \
		echo "  setup              setup conda env"; \
		echo "  cs614              setup + one kernel (rocm-pytorch GPU for all homework)"; \
		echo "  push               commit & push (MESSAGE=\"...\" for custom)"; \
		echo "  check-gpu          check GPU"; \
		echo "  apollo-kernel      Apollo notebook kernel"; \
		echo "  apollo-clean       remove Apollo env"; \
		echo "  apollo-clean-all   full Apollo cleanup"; \
		echo "  audiofix-kernel    audiofix notebook kernel"; \
		echo "  audiofix-clean     remove audiofix env"; \
		echo "  audiofix-clean-all full audiofix cleanup"; \
		echo "  clean-all-kernels  uninstall all CS614 Jupyter kernels"; \
		echo "  TAR=n              build PDF for Homework n (e.g., make TAR=4)"; \
		echo "  help               this message"; \
		echo ""; \
	fi

check-tools:
	@echo "Checking required tools..."
	@command -v conda >/dev/null 2>&1 || { \
		echo "❌ Error: conda is not installed or not in PATH"; \
		echo "   Please install Miniconda or Anaconda:"; \
		echo "   https://docs.conda.io/en/latest/miniconda.html"; \
		exit 1; \
	}
	@echo "✓ conda found: $$(conda --version)"
	@command -v python3 >/dev/null 2>&1 || command -v python >/dev/null 2>&1 || { \
		echo "❌ Error: Python is not installed"; \
		exit 1; \
	}
	@echo "✓ Python found"
	@echo ""

setup: check-tools
	@echo "=========================================="
	@echo "CS 614 Environment Setup"
	@echo "=========================================="
	@echo ""
	@if [ "$(OS)" = "windows" ]; then \
		echo "Detected OS: Windows"; \
		echo "Running PowerShell setup script..."; \
		echo ""; \
		powershell -ExecutionPolicy Bypass -File $(SETUP_SCRIPT); \
	else \
		echo "Detected OS: $(OS)"; \
		echo "Running bash setup script..."; \
		echo ""; \
		bash $(SETUP_SCRIPT); \
	fi

# One target: setup env + unified kernel (rocm-pytorch GPU)
cs614: check-tools setup rocm-env rocm-kernel
	@echo ""
	@echo "Done. Use kernel 'Python (rocm-pytorch GPU)' for all homework."

rocm-env:
	@bash scripts/setup_rocm_pytorch.sh

rocm-kernel: rocm-env
	@bash scripts/install_rocm_kernel.sh

check-gpu:
	@echo "Checking GPU availability..."
	@conda run -n rocm-pytorch python scripts/check_gpu.py 2>/dev/null || \
	conda run -n cs614 python scripts/check_gpu.py 2>/dev/null || \
	python3 scripts/check_gpu.py 2>/dev/null || \
	python scripts/check_gpu.py || \
	(echo "Error: Could not run check_gpu.py. Make sure:"; \
	 echo "  1. Python is installed"; \
	 echo "  2. PyTorch is installed (run 'make setup' first)"; \
	 exit 1)

apollo-kernel:
	@$(MAKE) -C Applications apollo-kernel

apollo-clean:
	@$(MAKE) -C Applications apollo-clean

apollo-clean-all:
	@$(MAKE) -C Applications apollo-clean-all

audiofix-kernel:
	@$(MAKE) -C Applications audiofix-kernel

audiofix-clean:
	@$(MAKE) -C Applications audiofix-clean

audiofix-clean-all:
	@$(MAKE) -C Applications audiofix-clean-all

clean-all-kernels:
	@bash scripts/clean_all_kernels.sh

push:
	@echo "Staging all changes..."
	@git add -A
	@echo "Committing with message: $(MESSAGE)"
	@git commit -m $(MESSAGE) || echo "No changes to commit"
	@echo "Pushing to GitHub..."
	@git push origin main || (echo "Error: Could not push. Make sure you have:"; \
		echo "  1. Created the repository on GitHub"; \
		echo "  2. Set up the remote: git remote add origin <your-repo-url>"; \
		exit 1)
	@echo "Successfully pushed to GitHub!"

# Build PDF for Homework n: make TAR=n
# Usage: make TAR=4 (or make TAR TAR=4)
TAR:
	@if [ -z "$(TAR)" ]; then \
		echo "Error: TAR parameter is required"; \
		echo "Usage: make TAR=n (e.g., make TAR=4)"; \
		echo "   or: make TAR TAR=4"; \
		exit 1; \
	fi
	@bash -c 'HW_DIR="Homework $(TAR)"; \
	TEX_FILE="$$HW_DIR/HW$(TAR)_Technical_Report.tex"; \
	if [ ! -f "$$TEX_FILE" ]; then \
		echo "Error: LaTeX file not found: $$TEX_FILE"; \
		echo "Expected file: $$TEX_FILE"; \
		exit 1; \
	fi; \
	echo "Building PDF for Homework $(TAR)..."; \
	bash scripts/build_pdf.sh "$$TEX_FILE"'
