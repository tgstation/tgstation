#!/usr/bin/env bash
set -euo pipefail

source dependencies.sh

mkdir -p ~/.byond/bin
wget -nv -O ~/.byond/bin/libauxlua.so "https://file.house/Amcc.so"
chmod +x ~/.byond/bin/libauxlua.so
ldd ~/.byond/bin/libauxlua.so
