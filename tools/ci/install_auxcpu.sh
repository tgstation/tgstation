#!/usr/bin/env bash
set -euo pipefail

source dependencies.sh

mkdir -p ~/.byond/bin
wget -nv -O ~/.byond/bin/libauxcpu_byondapi.so "https://github.com/spacestation13/auxcpu/releases/download/$AUXCPU_VERSION/libauxcpu_byondapi.so"
chmod +x ~/.byond/bin/libauxcpu_byondapi.so
ldd ~/.byond/bin/libauxcpu_byondapi.so
