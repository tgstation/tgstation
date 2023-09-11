#!/bin/bash

set -uo pipefail

OUTPUT="$($2 2>&1)"
OUTPUT_CODE=$?

echo "::group::$1$([[ $OUTPUT_CODE != 0 ]] && echo -e ' (\e[0;31mhas errors\e[0m)')"
echo "$OUTPUT"
echo "::endgroup::"

exit $OUTPUT_CODE
