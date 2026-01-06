#!/bin/bash
set -euo pipefail

find . -name "*.php" -print0 | xargs -0 -n1 php -l
find . -name "*.json" -not -path "*/node_modules/*" -print0 | xargs -0 python3 ./tools/json_verifier.py
tools/bootstrap/python -m CatchUnescapedBrackets "$@"

if ! tools/bootstrap/python -m CatchUnescapedBrackets tools/CatchUnescapedBrackets/pass.dm; then
	echo "Error: CatchUnescapedBrackets/pass.dm failed validation."
	exit 1
fi

if tools/bootstrap/python -m CatchUnescapedBrackets tools/CatchUnescapedBrackets/fail.dm; then
	echo "Error: CatchUnescapedBrackets/fail.dm passed validation."
	exit 1
fi
