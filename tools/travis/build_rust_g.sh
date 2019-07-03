#!/usr/bin/env bash
set -euo pipefail

source dependencies.sh

mkdir -p rust-g
cd rust-g
git init
git remote add origin https://github.com/tgstation/rust-g
git fetch --depth 1 origin $RUST_G_VERSION
git checkout FETCH_HEAD

cargo build --release

cmp target/rust_g.dm ../code/__DEFINES/rust_g.dm

mkdir -p ~/.byond/bin
ln -s $PWD/target/release/librust_g.so ~/.byond/bin/rust_g
