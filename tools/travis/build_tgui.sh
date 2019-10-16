#!/bin/bash
set -euo pipefail

## Change to project root relative to the script
cd "$(dirname "${0}")/../.."
base_dir="$(pwd)"

## Setup NVM
[[ -e ~/.nvm/nvm.sh ]] && source ~/.nvm/nvm.sh

echo "Building 'tgui'"
cd "${base_dir}/tgui"
npm ci
node node_modules/gulp/bin/gulp.js --min

echo "Building 'tgui-next'"
cd "${base_dir}/tgui-next"
bin/tgui --clean
bin/tgui
