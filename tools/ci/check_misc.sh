#!/bin/bash
set -euo pipefail

find . -name "*.php" -print0 | xargs -0 -n1 php -l
find . -name "*.json" -not -path "*/node_modules/*" -print0 | xargs -0 python3 ./tools/json_verifier.py
tools/bootstrap/python -m CatchUnescapedBrackets -i "tools/" "$@"

set +e
tools/bootstrap/python -m CatchUnescapedBrackets tools/CatchUnescapedBrackets/pass.dm >/dev/null 2>&1
status=$?
set -e

if [ $status -eq 1 ]; then
    echo "Error: CatchUnescapedBrackets/pass.dm failed validation."
    exit 1
fi

set +e
tools/bootstrap/python -m CatchUnescapedBrackets tools/CatchUnescapedBrackets/fail.dm >/dev/null 2>&1
status=$?
set -e

if [ $status -eq 0 ]; then
    echo "Error: CatchUnescapedBrackets/fail.dm passed validation."
    exit 1
fi
