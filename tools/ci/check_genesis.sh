#!/bin/bash
set -euo pipefail

#ANSI Escape Codes for colors to increase contrast of errors
RED="\033[0;31m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
NC="\033[0m" # No Color

if sha256sum -c tools/ci/genesis_call.dme.sha256sum ; then
    echo -e "${GREEN}code/genesis_call.dme is unchanged.${NC}"
else
    echo -e "${RED}code/genesis_call.dme has been changed!${NC}"
    echo -e "${BLUE}This is likely not intentional, please revert any changes made to it.${NC}"
    echo -e "${BLUE}On the unlikely occurance that you ARE intentionally modifying that file, replace the contents of tools/ci/genesis_call.dme.sha256sum with the following:${NC}"

    sha256sum tools/ci/genesis_call.dme.sha256sum

    exit 1
fi
