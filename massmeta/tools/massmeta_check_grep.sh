#!/bin/bash

#ANSI Escape Codes for colors to increase contrast of errors
RED="\033[0;31m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
NC="\033[0m" # No Color

echo -e "${BLUE}Re-running grep checks, but looking in modular_meta/features/...${NC}"

# Run the linters again, but modular massmeta code.
sed 's|code/**/**.dm|massmeta/features/**/**.dm|g' tools/ci/check_grep.sh | bash

echo -e "${BLUE}Re-running grep checks, but looking in modular_meta/master_files/...${NC}"

# Run the linters again, but NOW IT MUST CHECK modular massmeta code.
sed 's|code/**/**.dm|massmeta/master_files/**/**.dm|g' tools/ci/check_grep.sh | bash
