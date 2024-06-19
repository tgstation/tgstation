#!/bin/bash

set -euo pipefail
tools/bootstrap/python -m od_annotator "$@"
