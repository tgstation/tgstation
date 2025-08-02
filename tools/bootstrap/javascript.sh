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

# If Bun is not present, install using the official installer.
if ! command -v bun >/dev/null 2>&1; then
    echo "Bun not found, installing with official installer..."
    curl -fsSL https://bun.sh/install | bash -s $BunFullVersion
    if [ -d "$HOME/.bun/bin" ]; then
        export PATH="$HOME/.bun/bin:$PATH"
    else
        echo "Bun installation directory not found. Please check the installation."
        exit 1
    fi
fi

echo "Using Bun $(bun --version)"
exec bun "$@"
