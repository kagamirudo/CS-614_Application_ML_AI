#!/usr/bin/env python3
"""
GPU Check Script for CS 614
Checks if PyTorch can detect and use GPU (CUDA or ROCm)
"""

import sys

try:
    import torch
    print("=" * 60)
    print("PyTorch GPU Detection")
    print("=" * 60)
    print(f"PyTorch version: {torch.__version__}")
    print()
    
    # Check CUDA (NVIDIA)
    cuda_available = torch.cuda.is_available()
    if cuda_available:
        print("✓ CUDA (NVIDIA GPU) is available!")
        print(f"  CUDA version: {torch.version.cuda}")
        print(f"  Number of GPUs: {torch.cuda.device_count()}")
        for i in range(torch.cuda.device_count()):
            print(f"  GPU {i}: {torch.cuda.get_device_name(i)}")
            print(f"    Memory: {torch.cuda.get_device_properties(i).total_memory / 1024**3:.2f} GB")
    else:
        print("✗ CUDA (NVIDIA GPU) is not available")
    
    print()
    
    # Check ROCm (AMD) - if available
    try:
        # ROCm detection (may not be available in all PyTorch builds)
        if hasattr(torch.version, 'hip') and torch.version.hip is not None:
            print("✓ ROCm (AMD GPU) support detected!")
            print(f"  ROCm version: {torch.version.hip}")
            # Check if we can actually use it
            try:
                x = torch.randn(1).to('cuda')
                print("  ROCm device is functional")
            except Exception as e:
                print(f"  Warning: ROCm device detected but may not be functional: {e}")
        else:
            print("✗ ROCm (AMD GPU) support not detected in this PyTorch build")
    except Exception as e:
        print(f"✗ Could not check ROCm support: {e}")
    
    print()
    print("=" * 60)
    
    if cuda_available:
        print("Status: GPU acceleration is available! ✓")
        print("You can use: device = torch.device('cuda')")
    else:
        print("Status: Running on CPU only")
        print("To use GPU, install PyTorch with CUDA or ROCm support")
        print("See: https://pytorch.org/get-started/locally/")
    
    print("=" * 60)
    
except ImportError:
    print("Error: PyTorch is not installed!")
    print("Please run the setup script first:")
    print("  bash setup_environment.sh")
    sys.exit(1)
