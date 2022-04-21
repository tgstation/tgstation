#!/bin/bash

# Special file to ensure all dependencies still exist between server lanuches.
# Mainly for use by people who abuse docker by modifying the container's system.
set -e
set -x

#find out what we have (+e is important for this)
set +e
has_git="$(command -v git)"
has_cargo="$(command -v ~/.cargo/bin/cargo)"
has_sudo="$(command -v sudo)"
has_grep="$(command -v grep)"
has_youtubedl="$(command -v youtube-dl)"
has_pip3="$(command -v pip3)"
set -e

# install cargo if needed
if ! [ -x "$has_cargo" ]; then
	echo "Installing rust..."
	curl https://sh.rustup.rs -sSf | sh -s -- -y
	. ~/.profile
fi

# apt packages, libssl needed by rust-g but not included in TGS barebones install
if ! ( [ -x "$has_git" ] && [ -x "$has_grep" ] && [ -f "/usr/lib/i386-linux-gnu/libssl.so" ] ); then
	dpkg --add-architecture i386
	apt-get update
	apt-get install -y lib32z1 git pkg-config libssl-dev:i386 libssl-dev libssl1.1:i386
fi

# install youtube-dl when not present
if ! [ -x "$has_youtubedl" ]; then
	echo "Installing youtube-dl with pip3..."
	if ! [ -x "$has_sudo" ]; then
		apt-get install -y python3 python3-pip
	else
		sudo apt-get install -y python3 python3-pip
	fi
	pip3 install youtube-dl
fi
