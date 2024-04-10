#!/usr/bin/env bash
set -euo pipefail

source dependencies.sh

mkdir -p ~/.byond/bin
wget -nv -O ~/.byond/bin/librust_g.so "https://github.com/tgstation/rust-g/releases/download/$RUST_G_VERSION/librust_g.so"
chmod +x ~/.byond/bin/librust_g.so
ldd ~/.byond/bin/librust_g.so

wget -nv -O ~/.byond/bin/librust_g_ss220.so "https://github.com/ss220club/rust-g-tg/releases/download/$RUST_G_VERSION_SS220/librust_g.so"
chmod +x ~/.byond/bin/librust_g_ss220.so
ldd ~/.byond/bin/librust_g_ss220.so
