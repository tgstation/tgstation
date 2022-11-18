#!/bin/bash
set -euo pipefail

apt update
apt install build-essential -y

# ensure cargo is installed
if ! command -v cargo; then
	curl https://sh.rustup.rs -sSf | sh -s -- -y
	source ~/.cargo/env
fi

# clone if needed and update
if [ ! -d "$HOME/ripgrep" ]; then
	pushd "$HOME"
	git clone https://github.com/BurntSushi/ripgrep
	cd ripgrep
else
	pushd "$HOME/ripgrep"
	git fetch
	git pull
fi

# compile with PCRE2 support
export PCRE2_SYS_STATIC=1
cargo build --release --features pcre2

# make a link to the binary
ln -s "$HOME/ripgrep/target/release/rg" "$HOME/rg"

popd
