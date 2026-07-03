#!/bin/bash

./InstallDeps.sh

set -e
set -x

#load dep exports
#need to switch to game dir for Dockerfile weirdness
original_dir=$PWD
cd "$1"
. dependencies.sh
cd "$original_dir"

NEED_BUN_INSTALL=0
if [ -x "$HOME/.bun/bin/bun" ]; then
	export PATH="$HOME/.bun/bin:$PATH"
fi

# If Bun is not present or older than BUN_VERSION, install using the official installer.
if ! command -v bun >/dev/null 2>&1; then
	NEED_BUN_INSTALL=1
else
	INSTALLED_BUN_VERSION=$(bun --version)
	if [ "$(printf '%s\n' "$BUN_VERSION" "$INSTALLED_BUN_VERSION" | sort -V | head -n1)" != "$BUN_VERSION" ]; then
		NEED_BUN_INSTALL=1
	fi
fi

if [ "$NEED_BUN_INSTALL" = "1" ]; then
	echo "Installing Bun $BUN_VERSION..."
	curl -fsSL https://bun.sh/install | bash

	if [ -x "$HOME/.bun/bin/bun" ]; then
		export PATH="$HOME/.bun/bin:$PATH"
	else
		echo "ERROR: Bun installation failed; $HOME/.bun/bin/bun not found"
		exit 1
	fi
fi

INSTALLED_BUN_VERSION=$(bun --version)

echo "Using bun $INSTALLED_BUN_VERSION (minimum required: $BUN_VERSION)"

# update rust-g
if [ ! -d "rust-g" ]; then
	echo "Cloning rust-g..."
	git clone https://github.com/tgstation/rust-g
	cd rust-g
	~/.cargo/bin/rustup target add i686-unknown-linux-gnu
else
	echo "Fetching rust-g..."
	cd rust-g
	git fetch
	~/.cargo/bin/rustup target add i686-unknown-linux-gnu
fi

echo "Deploying rust-g..."
git checkout "$RUST_G_VERSION"
env PKG_CONFIG_ALLOW_CROSS=1 ~/.cargo/bin/cargo build --ignore-rust-version --release --target=i686-unknown-linux-gnu
cp -f target/i686-unknown-linux-gnu/release/librust_g.so "$1/librust_g.so"
cd ..

# update rust-utils
if [ ! -d "rust-utils" ]; then
	echo "Cloning rust-utils..."
	git clone https://github.com/ss220club/rust-utils
	cd rust-utils
	~/.cargo/bin/rustup target add i686-unknown-linux-gnu
else
	echo "Fetching rust-utils..."
	cd rust-utils
	git fetch
	~/.cargo/bin/rustup target add i686-unknown-linux-gnu
fi

echo "Deploying rust utils..."
git checkout "$RUST_UTILS_VERSION"
env PKG_CONFIG_ALLOW_CROSS=1 ~/.cargo/bin/cargo build --ignore-rust-version --release --target=i686-unknown-linux-gnu
mv target/i686-unknown-linux-gnu/release/librust_utils.so "$1/librust_utils.so"
cd ..
#
cd "$original_dir"
# update dreamluau
if [ ! -d "dreamluau" ]; then
	echo "Cloning dreamluau..."
	git clone https://github.com/tgstation/dreamluau
	cd dreamluau
	~/.cargo/bin/rustup target add i686-unknown-linux-gnu
else
	echo "Fetching dreamlaua..."
	cd dreamluau
	git fetch
	~/.cargo/bin/rustup target add i686-unknown-linux-gnu
fi

echo "Deploying Dreamlaua..."
git checkout "$DREAMLUAU_VERSION"
env PKG_CONFIG_ALLOW_CROSS=1 ~/.cargo/bin/cargo build --ignore-rust-version --release --target=i686-unknown-linux-gnu
cp -f target/i686-unknown-linux-gnu/release/libdreamluau.so "$1/libdreamluau.so"
cd ..

# compile tgui
echo "Compiling tgui..."
cd "$1"
env TG_BOOTSTRAP_CACHE="$original_dir" CBT_BUILD_MODE="TGS" tools/bootstrap/javascript.sh tools/build/build.ts
