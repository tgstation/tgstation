#!/bin/bash

#find out what we have (+e is important for this)
set +e
has_git="$(command -v git)"
has_curl="$(command -v curl)"
has_cargo="$(command -v ~/.cargo/bin/cargo)"
has_sudo="$(command -v sudo)"
has_ytdlp="$(command -v yt-dlp)"
has_pip3="$(command -v pip3)"
set -e
set -x

# apt packages, libssl needed by rust-g but not included in TGS barebones install
if ! ( [ -x "$has_git" ] && [ -x "$has_curl" ] && [ -x "$has_pip3" ] && [ -f "/usr/lib/i386-linux-gnu/libssl.so" ] ); then
	echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	echo "!!! HEY YOU THERE, READING THE TGS LOGS READ THIS!!!"
	echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	echo "We are about to try installing native dependencies, we will use 'sudo' if possible for this, but it may fail because the tgstation-server user doesn't have passwordless sudo."
	echo "WE DO NOT RECOMMEND GRANTING PASSWORDLESS SUDO!!! Instead, install all the dependencies yourself with the following command:"
	echo "............................................................................................................................................"
	echo "sudo apt-get install -y lib32z1 git pkg-config libssl-dev:i386 libssl-dev zlib1g-dev:i386 curl libclang-dev g++-multilib python3 python3-pip"
	echo "............................................................................................................................................"
	echo "Attempting to install apt dependencies..."
	if ! [ -x "$has_sudo" ]; then
		dpkg --add-architecture i386
		apt-get update
		apt-get install -y lib32z1 git pkg-config libssl-dev:i386 libssl-dev zlib1g-dev:i386 curl libclang-dev g++-multilib python3 python3-pip
	else
		sudo dpkg --add-architecture i386
		sudo apt-get update
		sudo apt-get install -y lib32z1 git pkg-config libssl-dev:i386 libssl-dev zlib1g-dev:i386 curl libclang-dev g++-multilib python3 python3-pip
	fi
fi

# install cargo if needed
if ! [ -x "$has_cargo" ]; then
	echo "Installing rust..."
	curl https://sh.rustup.rs -sSf | sh -s -- -y
	. ~/.profile
fi

# install or update yt-dlp when not present, or if it is present with pip3,
# which we assume was used to install it
if ! [ -x "$has_ytdlp" ]; then
	echo "Installing yt-dlp with pip3..."
	pip3 install yt-dlp --break-system-packages
else
	echo "Ensuring yt-dlp is up-to-date with pip3..."
	pip3 install yt-dlp -U --break-system-packages
fi
