#!/bin/bash
## Script for building tgui. Requires MSYS2 to run.

set -e
cd "$(dirname "${0}")"
base_dir="$(pwd)"

## Add locally installed node programs to path
PATH="${PATH}:node_modules/.bin"

yarn install

cd "${base_dir}/packages/tgui"
webpack --mode=development

cd "${base_dir}"
./reload.bat

cd "${base_dir}/packages/tgui-dev-server"
node --experimental-modules server.js
