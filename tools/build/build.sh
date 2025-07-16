#!/bin/sh
set -e
cd "$(dirname "$0")"
exec ../bootstrap/javascript.sh build.ts "$@"
