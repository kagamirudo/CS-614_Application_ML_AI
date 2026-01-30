#!/usr/bin/env python3
"""
Check whether this process (e.g. a Jupyter kernel) is using GPU or CPU on Linux.
Supports NVIDIA (CUDA) and AMD (ROCm). Run from terminal or import in a notebook.
"""

import sys
import subprocess


def has_nvidia_gpu() -> bool:
    """Check if the system has an NVIDIA GPU (nvidia-smi available)."""
    try:
        subprocess.run(
            ["nvidia-smi"],
            capture_output=True,
            check=True,
            timeout=5,
        )
        return True
    except (FileNotFoundError, subprocess.CalledProcessError, subprocess.TimeoutExpired):
        return False


def has_amd_gpu() -> bool:
    """Check if the system has an AMD GPU with ROCm (rocm-smi available)."""
    try:
        subprocess.run(
            ["rocm-smi"],
            capture_output=True,
            check=True,
            timeout=5,
        )
        return True
    except (FileNotFoundError, subprocess.CalledProcessError, subprocess.TimeoutExpired):
        return False


def amd_gpu_info() -> str | None:
    """Return a short line about AMD GPU(s) from rocm-smi, or None."""
    if not has_amd_gpu():
        return None
    try:
        out = subprocess.run(
            ["rocm-smi", "--showproductname"],
            capture_output=True,
            text=True,
            timeout=5,
        )
        if out.returncode == 0 and out.stdout.strip():
            return out.stdout.strip().split("\n")[0].strip()
        return "AMD GPU (ROCm)"
    except Exception:
        return "AMD GPU (ROCm)"


def pytorch_device() -> str:
    """Return the device PyTorch would use: 'cuda', 'mps', or 'cpu'."""
    try:
        import torch
        if torch.cuda.is_available():
            return f"cuda (GPU: {torch.cuda.get_device_name(0)})"
        if hasattr(torch.backends, "mps") and torch.backends.mps.is_available():
            return "mps (Apple GPU)"
        return "cpu"
    except ImportError:
        return "unknown (PyTorch not installed)"


def check_gpu_usage():
    """
    One-liner for notebooks: run main() and return whether GPU is in use.
    In a cell: from gpu_usage import check_gpu_usage; check_gpu_usage()
    """
    main()
    try:
        import torch
        return "cuda" in pytorch_device().lower()
    except ImportError:
        return False


def main():
    print("=== GPU / CPU usage check ===\n")

    # 1. System GPU (NVIDIA or AMD)
    if has_nvidia_gpu():
        print("System: NVIDIA GPU detected.")
        try:
            out = subprocess.run(
                ["nvidia-smi", "--query-gpu=name,memory.used,memory.total", "--format=csv,noheader"],
                capture_output=True,
                text=True,
                timeout=5,
            )
            if out.returncode == 0 and out.stdout.strip():
                for line in out.stdout.strip().split("\n"):
                    print(f"  {line.strip()}")
        except Exception as e:
            print(f"  (nvidia-smi details skipped: {e})")
    elif has_amd_gpu():
        info = amd_gpu_info()
        print(f"System: AMD GPU detected.  {info or 'ROCm available.'}")
    else:
        print("System: No NVIDIA (nvidia-smi) or AMD ROCm (rocm-smi) GPU detected.\n")

    # 2. What PyTorch sees (CUDA = NVIDIA or AMD ROCm build)
    device = pytorch_device()
    print(f"\nPyTorch (this process): using {device}")

    if "cuda" in device.lower():
        print("  -> Notebook/training will use GPU (NVIDIA or AMD ROCm).")
    else:
        print("  -> Notebook/training will use CPU.")
        print("     (Install PyTorch with CUDA for NVIDIA, or ROCm build for AMD.)")

    print()
    return 0


if __name__ == "__main__":
    sys.exit(main())
