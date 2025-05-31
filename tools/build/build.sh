#!/bin/sh
set -e
cd "$(dirname "$0")"
exec ../bootstrap/bun.sh build.js "$@"
