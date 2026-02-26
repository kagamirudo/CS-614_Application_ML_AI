#!/usr/bin/env python3
"""
Clean Jupyter notebook metadata that breaks GitHub rendering (e.g. after editing in Colab).

Removes:
- metadata.widgets (and optionally adds minimal state if needed)
- cell-level metadata.referenced_widgets / metadata.widgets

Run on paths, or from repo root with no args to find and clean all .ipynb files.
"""

import argparse
import json
import sys
from pathlib import Path


def has_colab_or_widgets_metadata(nb: dict) -> bool:
    """True if notebook has Colab/widgets metadata that can break GitHub."""
    meta = nb.get("metadata", {})
    if "widgets" in meta:
        return True
    if "colab" in meta:
        return True
    for cell in nb.get("cells", []):
        cm = cell.get("metadata", {})
        if "widgets" in cm or "referenced_widgets" in cm:
            return True
    return False


def clean_notebook(data: dict) -> bool:
    """Remove widgets/Colab metadata in-place. Returns True if any change was made."""
    changed = False
    meta = data.get("metadata", {})

    if "widgets" in meta:
        del meta["widgets"]
        changed = True

    # Optional: remove colab-specific metadata that can confuse renderers
    if "colab" in meta:
        del meta["colab"]
        changed = True

    for cell in data.get("cells", []):
        cm = cell.get("metadata", {})
        if "widgets" in cm:
            del cm["widgets"]
            changed = True
        if "referenced_widgets" in cm:
            del cm["referenced_widgets"]
            changed = True

    return changed


def clean_file(path: Path, dry_run: bool = False) -> bool:
    """Clean one notebook file. Returns True if file was modified (or would be in dry_run)."""
    try:
        text = path.read_text(encoding="utf-8")
    except Exception as e:
        print(f"  skip {path}: read error — {e}", file=sys.stderr)
        return False

    try:
        nb = json.loads(text)
    except json.JSONDecodeError as e:
        print(f"  skip {path}: invalid JSON — {e}", file=sys.stderr)
        return False

    if not has_colab_or_widgets_metadata(nb):
        return False

    if not clean_notebook(nb):
        return False

    if dry_run:
        print(f"  would clean: {path}")
        return True

    try:
        path.write_text(json.dumps(nb, indent=2), encoding="utf-8")
        print(f"  cleaned: {path}")
        return True
    except Exception as e:
        print(f"  skip {path}: write error — {e}", file=sys.stderr)
        return False


def find_notebooks(root: Path) -> list[Path]:
    """Recursively find .ipynb under root, excluding hidden and common cache dirs."""
    out = []
    for p in root.rglob("*.ipynb"):
        if any(part.startswith(".") for part in p.parts):
            continue
        if ".ipynb_checkpoints" in p.parts:
            continue
        out.append(p)
    return sorted(out)


def main():
    ap = argparse.ArgumentParser(
        description="Remove notebook metadata.widgets / Colab metadata for GitHub-friendly notebooks."
    )
    ap.add_argument(
        "paths",
        nargs="*",
        type=Path,
        help="Notebook paths; if none, discover all .ipynb under current directory",
    )
    ap.add_argument(
        "-n", "--dry-run",
        action="store_true",
        help="Only print what would be cleaned",
    )
    args = ap.parse_args()

    root = Path.cwd()
    if args.paths:
        paths = []
        for p in args.paths:
            p = p.resolve()
            if p.is_dir():
                paths.extend(find_notebooks(p))
            elif p.suffix == ".ipynb" and p.exists():
                paths.append(p)
            else:
                print(f"  skip (not found or not .ipynb): {p}", file=sys.stderr)
    else:
        paths = find_notebooks(root)

    if not paths:
        return 0

    n = 0
    for path in paths:
        if clean_file(path, dry_run=args.dry_run):
            n += 1

    if n:
        print(f"Cleaned {n} notebook(s).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
