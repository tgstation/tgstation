#!/bin/sh
# `sh` must be used here instead of `bash` to support GitHub Desktop.
set -e
if command -v python3 >/dev/null 2>&1; then
	PY=python3
elif command -v python >/dev/null 2>&1; then
	PY=python
elif command -v py >/dev/null 2>&1; then
	PY=py
else
	echo "Please install Python 3.6 or later."
fi
PATHSEP=$($PY - <<'EOF'
import sys, os
if sys.version_info.major != 3 or sys.version_info.minor < 6:
	sys.stderr.write("Python 3.6 or later is required, but you have:\n" + sys.version + "\n")
	exit(1)
print(os.pathsep)
EOF
)
export PYTHONPATH=tools/mapmerge2/${PATHSEP}${PYTHONPATH}
exec $PY "$@"
