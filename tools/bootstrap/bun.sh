#!/bin/sh
# bootstrap/bun
#
# Bun-finding script for all `sh` environments, including Linux, MSYS2,
# Git for Windows, and GitHub Desktop. Invokable from CLI or automation.
#
# If a bun executable installed by a bootstrapper is present, it will be used.
# Otherwise, this script requires a system `bun` to be provided.
set -e

# Convenience variables
Bootstrap="$(dirname "$0")"
Cache="$Bootstrap/.cache"
if [ "$TG_BOOTSTRAP_CACHE" ]; then
	Cache="$TG_BOOTSTRAP_CACHE"
fi
OldPWD="$PWD"
cd "$Bootstrap/../.."
. ./dependencies.sh  # sets BUN_VERSION (define this in dependencies.sh)
cd "$OldPWD"
BunVersion="$BUN_VERSION"
BunFullVersion="bun-v$BunVersion"
BunDir="$Cache/$BunFullVersion"
BunExe="$BunDir/bun"
is_vendored="1"

# If a bootstrapped Bun is not present, search on $PATH.
if [ "$(uname)" = "Linux" ] || [ ! -f "$BunExe" ]; then
	if [ "$TG_BOOTSTRAP_BUN_LINUX" ]; then
		BunFullVersion="bun-v$BunVersion"
		BunDir="$Cache/$BunFullVersion/bin"
		BunExe="$BunDir/bun"

		if [ ! -f "$BunExe" ]; then
			mkdir -p "$Cache"
			Archive="$(realpath "$Cache/bun-v$BunVersion.zip")"
			curl -L "https://github.com/oven-sh/bun/releases/download/bun-v$BunVersion/bun-linux-x64.zip" -o "$Archive"
			(cd "$Cache" && unzip -o "$Archive")
		fi
	elif command -v bun >/dev/null 2>&1; then
		BunExe="bun"
		is_vendored="0"
	else
		echo
		if command -v apt-get >/dev/null 2>&1; then
			echo "Please install Bun using the official installer:"
			echo "    curl -fsSL https://bun.sh/install | bash"
		elif uname | grep -q MSYS; then
			echo "Please run bootstrap/bun.bat instead of bootstrap/bun once"
			echo "to install Bun automatically, or install it from https://bun.sh/"
		elif command -v pacman >/dev/null 2>&1; then
			echo "Please install Bun using the official installer:"
			echo "    curl -fsSL https://bun.sh/install | bash"
		else
			echo "Please install Bun from https://bun.sh/ or using the official installer."
		fi
		echo
		exit 1
	fi
fi

# Invoke Bun with all command-line arguments
if [ "$is_vendored" = "1" ]; then
	PATH="$(readlink -f "$BunDir"):$PATH"
	echo "Using vendored Bun $($BunExe --version)"
else
	echo "Using system-wide Bun $($BunExe --version)"
fi
exec "$BunExe" "$@"
