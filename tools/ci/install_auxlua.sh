#!/usr/bin/env bash
set -euo pipefail

source dependencies.sh

mkdir -p ~/.byond/bin
wget -nv -O ~/.byond/bin/libauxlua.so "https://github.com/$AUXLUA_REPO/releases/download/$AUXLUA_VERSION/libauxlua-coverage.so"
chmod +x ~/.byond/bin/libauxcov.so
ldd ~/.byond/bin/libauxcov.so
