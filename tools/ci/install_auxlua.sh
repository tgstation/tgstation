#!/usr/bin/env bash
set -euo pipefail

source dependencies.sh

mkdir -p ~/.byond/bin
wget -nv -O ~/.byond/bin/libauxlua.so "https://github.com/$AUXLUA_REPO/releases/download/$AUXLUA_VERSION/libauxlua.so"
chmod +x ~/.byond/bin/libauxlua.so
ldd ~/.byond/bin/libauxlua.so
