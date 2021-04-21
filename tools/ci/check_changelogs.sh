#!/bin/bash
set -euo pipefail

md5sum -c - <<< "e70dd40dccdf2d694aea3f56a7a0c4f1 *html/changelogs/example.yml"
python3 tools/ss13_genchangelog.py html/changelog.json html/changelogs
