#!/bin/bash

./InstallDeps.sh

set -e
set -x

# 1. Detect Host Architecture (e.g., aarch64)
ARCH=$(uname -m)
RUST_TARGET="$ARCH-unknown-linux-gnu"

# Load dep exports
original_dir=$PWD
cd "$1"
. dependencies.sh
cd "$original_dir"

# Bun Setup - Bun v1.3.10+ supports ARM64 natively
if [ -x "$HOME/.bun/bin/bun" ]; then
	export PATH="$HOME/.bun/bin:$PATH"
fi

if ! command -v bun >/dev/null 2>&1; then
	echo "Installing Bun for $ARCH..."
	curl -fsSL https://bun.sh/install | bash
	export PATH="$HOME/.bun/bin:$PATH"
fi

# 2. Build rust-g for ARM64
if [ ! -d "rust-g" ]; then
	git clone https://github.com/tgstation/rust-g
	cd rust-g
else
	cd rust-g
	git fetch
fi

/home/ubuntu/.cargo/bin/rustup target add "$RUST_TARGET"
git checkout "$RUST_G_VERSION"
# Removed PKG_CONFIG_ALLOW_CROSS because we are building NATIVELY
/home/ubuntu/.cargo/bin/cargo build --ignore-rust-version --release --target="$RUST_TARGET"
cp -f "target/$RUST_TARGET/release/librust_g.so" "$1/librust_g.so"
cd ..

# 3. Build dreamluau for ARM64
cd "$original_dir"
if [ ! -d "dreamluau" ]; then
	git clone https://github.com/tgstation/dreamluau
	cd dreamluau
else
	cd dreamluau
	git fetch
fi

/home/ubuntu/.cargo/bin/rustup target add "$RUST_TARGET"
git checkout "$DREAMLUAU_VERSION"
/home/ubuntu/.cargo/bin/cargo build --ignore-rust-version --release --target="$RUST_TARGET"
cp -f "target/$RUST_TARGET/release/libdreamluau.so" "$1/libdreamluau.so"
cd ..

# 4. Compile TGUI (Standard JS build)
echo "Compiling tgui..."
cd "$1"
env TG_BOOTSTRAP_CACHE="$original_dir" CBT_BUILD_MODE="TGS" tools/bootstrap/javascript.sh tools/build/build.ts
