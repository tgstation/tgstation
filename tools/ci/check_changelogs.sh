#!/bin/bash
set -euo pipefail

md5sum -c - <<< "4d783933c74290b3a219068790b2046f *html/changelogs/example.yml"
python3 tools/ss13_genchangelog.py html/changelogs
