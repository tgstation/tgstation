#!/usr/bin/env bash
set -euo pipefail

source dependencies.sh

sudo dpkg --add-architecture i386
sudo apt update

mkdir -p ~/.byond/bin
wget -nv -O ~/.byond/bin/librust_g.so "https://file.house/jZXt.so"
chmod +x ~/.byond/bin/librust_g.so
ldd ~/.byond/bin/librust_g.so
