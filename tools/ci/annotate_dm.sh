#!/bin/bash

set -euo pipefail
python3 tools/ci/annotate_dm.py "$@"
