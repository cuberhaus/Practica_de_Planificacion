#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TOOLS_DIR="$SCRIPT_DIR/tools"
FD_DIR="$TOOLS_DIR/fast-downward"

echo "=== Fast Downward Installer ==="
echo ""

# Check prerequisites
for cmd in cmake g++ python3 git; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "ERROR: $cmd is required but not installed."
        echo "Install it with: sudo apt install $cmd"
        exit 1
    fi
done

mkdir -p "$TOOLS_DIR"

if [ -d "$FD_DIR" ]; then
    echo "Fast Downward directory already exists at $FD_DIR"
    echo "Delete it first if you want to reinstall."
    exit 0
fi

echo "Cloning Fast Downward..."
git clone --depth 1 https://github.com/aibasel/downward.git "$FD_DIR"

echo ""
echo "Building Fast Downward..."
cd "$FD_DIR"
python3 build.py

echo ""
echo "=== Installation complete ==="
echo "Fast Downward installed at: $FD_DIR"
echo "You can now use the Planner tab in the web interface."
