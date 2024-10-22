#!/usr/bin/env bash
set -euo pipefail

source dependencies.sh

mkdir -p ~/.byond/bin
wget -nv -O ~/.byond/bin/libdreamluau.so "https://github.com/$DREAMLUAU_REPO/releases/download/$DREAMLUAU_VERSION/libdreamluau.so"
chmod +x ~/.byond/bin/libdreamluau.so
ldd ~/.byond/bin/libdreamluau.so
