## Copyright (c) 2020 Aleksej Komarov
## SPDX-License-Identifier: MIT

## Initial set-up
## --------------------------------------------------------

## Normalize current directory
$basedir = Split-Path $MyInvocation.MyCommand.Path
$basedir = Resolve-Path "$($basedir)\.."
Set-Location $basedir
[Environment]::CurrentDirectory = $basedir


## Functions
## --------------------------------------------------------

function yarn {
  node.exe ".yarn\releases\yarn-berry.js" @Args
}

function Remove-Quiet {
  Remove-Item -ErrorAction SilentlyContinue @Args
}

function task-install {
  yarn install
}

## Runs webpack
function task-webpack {
  yarn run webpack-cli @Args
}

## Runs a development server
function task-dev-server {
  yarn node "packages/tgui-dev-server/index.esm.js" @Args
}

## Run a linter through all packages
function task-eslint {
  yarn run eslint packages @Args
  Write-Output "tgui: eslint check passed"
}

## Mr. Proper
function task-clean {
  ## Build artifacts
  Remove-Quiet -Recurse -Force "public\.tmp"
  Remove-Quiet -Force "public\*.map"
  Remove-Quiet -Force "public\*.hot-update.*"
  ## Yarn artifacts
  Remove-Quiet -Recurse -Force ".yarn\cache"
  Remove-Quiet -Recurse -Force ".yarn\unplugged"
  Remove-Quiet -Recurse -Force ".yarn\build-state.yml"
  Remove-Quiet -Recurse -Force ".yarn\install-state.gz"
  Remove-Quiet -Force ".pnp.js"
  ## NPM artifacts
  Get-ChildItem -Path "." -Include "node_modules" -Recurse -File:$false | Remove-Item -Recurse -Force
  Remove-Quiet -Force "package-lock.json"
}


## Main
## --------------------------------------------------------

if ($Args[0] -eq "--clean") {
  task-clean
  exit 0
}

if ($Args[0] -eq "--dev") {
  $Rest = $Args | Select-Object -Skip 1
  task-install
  task-dev-server @Rest
  exit 0
}

if ($Args[0] -eq "--lint") {
  $Rest = $Args | Select-Object -Skip 1
  task-install
  task-eslint @Rest
  exit 0
}

if ($Args[0] -eq "--lint-harder") {
  $Rest = $Args | Select-Object -Skip 1
  task-install
  task-eslint -c ".eslintrc-harder.yml" @Rest
  exit 0
}

if ($Args[0] -eq "--fix") {
  $Rest = $Args | Select-Object -Skip 1
  task-install
  task-eslint --fix @Rest
  exit 0
}

## Analyze the bundle
if ($Args[0] -eq "--analyze") {
  task-install
  task-webpack --mode=production --analyze
  exit 0
}

## Make a production webpack build
if ($Args.Length -eq 0) {
  task-install
  task-eslint
  task-webpack --mode=production
  exit 0
}

## Run webpack with custom flags
task-install
task-webpack @Args
