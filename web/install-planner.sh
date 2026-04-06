#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TOOLS_DIR="$SCRIPT_DIR/tools"
FF_DIR="$TOOLS_DIR/metric-ff"

echo "=== Metric-FF Installer ==="
echo ""

for cmd in make gcc flex bison; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "ERROR: $cmd is required but not installed."
        echo "Install with: sudo apt install build-essential flex bison"
        exit 1
    fi
done

if [ -x "$FF_DIR/ff" ]; then
    echo "Metric-FF is already compiled at $FF_DIR/ff"
    exit 0
fi

if [ ! -d "$FF_DIR" ]; then
    echo "Cloning Metric-FF..."
    git clone --depth 1 https://github.com/caelan/Metric-FF.git "$FF_DIR"
fi

echo ""
echo "Building Metric-FF..."
cd "$FF_DIR"

# Fix errno macro collision in parser files
sed -i 's/int errno,/int errnum,/g' scan-fct_pddl.y scan-ops_pddl.y 2>/dev/null || true

# Fix makefile for modern GCC
sed -i 's/-O6 -ansi/-O2/g' makefile
sed -i 's/$(ADDONS) -g/$(ADDONS) -g -Wno-format-overflow -fcommon/' makefile

make clean
make

echo ""
echo "=== Installation complete ==="
echo "Metric-FF installed at: $FF_DIR/ff"
echo "You can now use the Planner tab in the web interface."
