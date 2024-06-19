#!/bin/bash

set -euo pipefail
tools/bootstrap/python -m dm_annotator "$@"
