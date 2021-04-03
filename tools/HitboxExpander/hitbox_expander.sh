#!/bin/sh
set -e
exec "$(dirname "$0")/../bootstrap/python" -m HitboxExpander "$@"
