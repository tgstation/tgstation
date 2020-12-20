#!/bin/sh
set -e

PY="$(dirname "$0")/../bootstrap/python"

# Deduce the path separator and add the mapmerge package to the search path.
PATHSEP=$("$PY" - <<'EOF'
import sys, os
if sys.version_info.major != 3 or sys.version_info.minor < 6:
	sys.stderr.write("Python 3.6 or later is required, but you have:\n" + sys.version + "\n")
	exit(1)
print(os.pathsep)
EOF
)
export PYTHONPATH="tools/mapmerge2/${PATHSEP}${PYTHONPATH}"
exec "$PY" "$@"
