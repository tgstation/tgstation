#!/usr/bin/env bash
set -euo pipefail

source dependencies.sh

wget -O ~/.byond/bin/rust_g "https://github.com/tgstation/rust-g/releases/download/$RUST_G_VERSION/librust_g.so"
chmod +x ~/.byond/bin/rust_g
