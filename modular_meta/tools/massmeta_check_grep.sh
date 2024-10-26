#!/bin/bash

#ANSI Escape Codes for colors to increase contrast of errors
RED="\033[0;31m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
NC="\033[0m" # No Color

echo -e "${BLUE}Re-running grep checks, but looking in modular_meta/...${NC}"

# Run the linters again, but modular massmeta code (features).
sed 's/code\/\*\*\/\*\*.dm/modular_meta\/features\/\*\*\/\*\*.dm/g' <tools/ci/check_grep.sh | bash

echo -e "${BLUE}Re-running grep checks, but looking in modular_meta/master_files/...${NC}"

# Run the linters again, but modular massmeta code (perevody = translations).
sed 's/code\/\*\*\/\*\*.dm/modular_meta\/perevody\/\*\*\/\*\*.dm/g' <tools/ci/check_grep.sh | bash

# Run the linters again, but modular massmeta code (reverts).
sed 's/code\/\*\*\/\*\*.dm/modular_meta\/reverts\/\*\*\/\*\*.dm/g' <tools/ci/check_grep.sh | bash
