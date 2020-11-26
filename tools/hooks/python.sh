#!/bin/sh
# `sh` must be used here instead of `bash` to support GitHub Desktop.
set -e

# Strip the "App Execution Aliases" from $PATH. Even if the user installed
# Python using the Windows Store on purpose, these aliases always generate
# "Permission denied" errors when sh.exe tries to invoke them.
PATH=$(echo "$PATH" | tr ":" "\n" | grep -v "AppData/Local/Microsoft/WindowsApps" | tr "\n" ":")

# Try to find a Python executable.
if command -v python3 >/dev/null 2>&1; then
	PY=python3
elif command -v python >/dev/null 2>&1; then
	PY=python
elif command -v py >/dev/null 2>&1; then
	PY="py -3"
else
	echo "Please install Python from https://www.python.org/downloads/"
	exit 1
fi

# Deduce the path separator and add the mapmerge package to the search path.
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
