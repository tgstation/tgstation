#!/bin/bash
set -euo pipefail

source tools/ci/dependencies.sh

cargo install ripgrep --features pcre2 --version $RIPGREP_VERSION
