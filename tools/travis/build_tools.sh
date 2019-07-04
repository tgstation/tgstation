#!/bin/bash
set -euo pipefail

md5sum -c - <<< "49bc6b1b9ed56c83cceb6674bd97cb34 *html/changelogs/example.yml"
python3 tools/ss13_genchangelog.py html/changelog.html html/changelogs

find . -name "*.php" -print0 | xargs -0 -n1 php -l

find . -name "*.json" -not -path "./tgui/node_modules/*" | xargs -0 python3 ./tools/json_verifier.py

(cd tgui && source ~/.nvm/nvm.sh && npm ci && node node_modules/gulp/bin/gulp.js --min)
