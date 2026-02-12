.PHONY: push setup help check-tools cs614-kernel apollo-kernel apollo-clean apollo-clean-all audiofix-kernel audiofix-clean audiofix-clean-all

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

help:
	@echo "=========================================="
	@echo "CS 614 - Makefile Commands"
	@echo "=========================================="
	@echo ""
	@echo "Available targets:"
	@echo "  make setup              - Set up conda environment (auto-detects OS)"
	@echo "  make cs614-kernel       - Register Jupyter kernel 'Python (cs614)' for HW4 (torchvision detection)"
	@echo "  make push               - Commit and push changes (uses default message)"
	@echo "  make push MESSAGE=\"msg\" - Commit and push with custom message"
	@echo "  make check-gpu          - Check GPU availability"
	@echo "  make apollo-kernel      - Create Jupyter kernel for Apollo (Applications/apollo.ipynb)"
	@echo "  make apollo-clean       - Remove old Apollo env/kernel (after failed install)"
	@echo "  make apollo-clean-all  - Full Apollo cleanup including /opt/apollo-env"
	@echo "  make audiofix-kernel    - Create Jupyter kernel 'Python (audiofix)' for scratch/click pipeline in Applications/music.ipynb"
	@echo "  make audiofix-clean     - Remove old 'audiofix' env/kernel (after failed install)"
	@echo "  make audiofix-clean-all - Full audiofix cleanup including /opt/audiofix-env"
	@echo "  make help               - Show this help message"
	@echo ""

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

cs614-kernel:
	@bash scripts/install_cs614_kernel.sh

check-gpu:
	@echo "Checking GPU availability..."
	@conda run -n cs614 python scripts/check_gpu.py 2>/dev/null || \
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
