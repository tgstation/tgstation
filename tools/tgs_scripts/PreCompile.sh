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
