#!/bin/bash

#ANSI Escape Codes for colors to increase contrast of errors
RED="\033[0;31m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
NC="\033[0m" # No Color

echo -e "${BLUE}Re-running grep checks, but looking in modular_bandastation...${NC}"

# Run the linters again, but modular bandastation code.
sed "s|code/\*\*/\*\.dm|modular_bandastation/\*\*/\*\.dm|g" <tools/ci/check_grep.sh | bash
