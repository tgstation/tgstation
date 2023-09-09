#!/bin/bash

set -euo pipefail
tools/bootstrap/python tools/ci/annotate_dm.py "$@"
