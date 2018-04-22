#!/usr/bin/env bash

set -e

if [ "$BUILD_TOOLS" = false ]; then
    curl https://sh.rustup.rs -sSf | sh -s -- -y --default-host i686-unknown-linux-gnu
    source ~/.profile

    git clone --branch $RUST_G_VERSION https://github.com/tgstation/rust-g

    cd rust-g
    cargo build --release

    mkdir -p ~/.byond/bin
    ln -s $PWD/target/release/librust_g.so ~/.byond/bin/rust_g
fi
