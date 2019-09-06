#!/bin/bash
set -euo pipefail

cd tgui
source ~/.nvm/nvm.sh
npm ci
node node_modules/gulp/bin/gulp.js --min
