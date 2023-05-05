#!/usr/bin/env bash
set -euo pipefail

source dependencies.sh

mkdir -p ~/.byond/bin
wget -nv -O ~/.byond/bin/libauxcov.so "https://github.com/Cyberboss/auxtools/releases/download/CodeCoverageTest4/libauxcov.so"
chmod +x ~/.byond/bin/libauxcov.so
ldd ~/.byond/bin/libauxcov.so
