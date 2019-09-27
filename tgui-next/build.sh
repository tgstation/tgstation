#!/bin/bash
## Script for building tgui. Requires MSYS2 to run.

set -e
cd "$(dirname "${0}")"
base_dir="$(pwd)"

## Add locally installed node programs to path
PATH="${PATH}:node_modules/.bin"

yarn install

if [[ ${1} == "--dev" ]]; then
  cd "${base_dir}/packages/tgui-dev-server"
  exec node --experimental-modules server.js
fi

cd "${base_dir}/packages/tgui"
rm -rf public/bundles
exec webpack "${@}"
