#!/bin/bash
set -euo pipefail

source tools/ci/ci_dependencies.sh

cargo install ripgrep --features pcre2 --version $RIPGREP_VERSION
