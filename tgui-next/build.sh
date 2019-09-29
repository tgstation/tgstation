#!/bin/bash
## Script for building tgui. Requires MSYS2 to run.
set -e
cd "$(dirname "${0}")"
base_dir="$(pwd)"

## Add locally installed node programs to path
PATH="${PATH}:node_modules/.bin"

yarn install

run-webpack() {
  cd "${base_dir}/packages/tgui"
  rm -rf public/bundles
  exec webpack "${@}"
}

## Run a development server
if [[ ${1} == "--dev" ]]; then
  cd "${base_dir}/packages/tgui-dev-server"
  exec node --experimental-modules server.js
fi

## Run a linter through all packages
if [[ ${1} == '--lint' ]]; then
  lint_paths=(
    './packages/byond/*.js'
    './packages/functional/*.js'
    './packages/logging/*.js'
    './packages/react-tools/*.js'
    './packages/string-tools/*.js'
    './packages/tgui/components/**/*.js'
    './packages/tgui/interfaces/**/*.js'
    './packages/tgui/*.js'
    './packages/tgui-dev-server/*.js'
  )
  shift
  exec eslint "${lint_paths[@]}" "${@}"
fi

## Analyze the bundle
if [[ ${1} == '--analyze' ]]; then
  run-webpack --mode=production --env.analyze=1
fi

## Make a production webpack build
if [[ -z ${1} ]]; then
  run-webpack --mode=production
fi

## Run webpack with custom flags
run-webpack "${@}"
