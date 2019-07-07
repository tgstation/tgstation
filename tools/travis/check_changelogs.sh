#!/bin/bash
set -euo pipefail

md5sum -c - <<< "49bc6b1b9ed56c83cceb6674bd97cb34 *html/changelogs/example.yml"
python3 tools/ss13_genchangelog.py html/changelog.html html/changelogs
