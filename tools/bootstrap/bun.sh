#!/bin/sh
# bootstrap/bun
#
# Bun-finding script for all `sh` environments, including Linux, MSYS2,
# Git for Windows, and GitHub Desktop. Invokable from CLI or automation.
#
# If a bun executable installed by a bootstrapper is present, it will be used.
# Otherwise, this script requires a system `bun` to be provided.
set -e

# Load Bun version from dependencies.sh
OldPWD="$PWD"
cd "$(dirname "$0")/../.."
. ./dependencies.sh  # sets BUN_VERSION (define this in dependencies.sh)
cd "$OldPWD"
BunVersion="$BUN_VERSION"
BunFullVersion="bun-v$BunVersion"
BunExe="$HOME/.bun/bin/bun"

# If Bun is not present, install using the official installer.
if [ ! -f "$BunExe" ]; then
    echo "Bun not found, installing with official installer..."
    # Ensure unzip is installed
    if ! command -v unzip >/dev/null 2>&1; then
        echo "'unzip' not found. Attempting to install..."
        if command -v apt-get >/dev/null 2>&1; then
            sudo apt-get update && sudo apt-get install -y unzip
        elif command -v yum >/dev/null 2>&1; then
            sudo yum install -y unzip
        elif command -v pacman >/dev/null 2>&1; then
            sudo pacman -Sy unzip
        else
            echo "Please install 'unzip' manually."
            exit 1
        fi
    fi
    curl -fsSL https://bun.sh/install | bash -s $BunFullVersion
    if [ ! -f "$BunExe" ]; then
        echo "Bun installation failed or not found at $BunExe."
        exit 1
    fi
fi

echo "Using Bun $($BunExe --version)"
exec "$BunExe" "$@"
