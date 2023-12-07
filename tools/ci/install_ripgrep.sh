#!/bin/bash
set -euo pipefail

# we do not need to source dependencies.sh because rust is not required to run or compile the project - this is for CI only as of right now
RIPGREP_VERSION=14.0.3

cargo install ripgrep --features pcre2 --version $RIPGREP_VERSION
