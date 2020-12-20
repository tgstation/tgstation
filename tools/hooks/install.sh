#!/bin/sh
exec "$(dirname "$0")/../bootstrap/python" -m hooks.install "$@"
