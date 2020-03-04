#!/bin/bash
set -euo pipefail

source dependencies.sh

cd $HOME/SpacemanDMM

git init
git remote add origin https://github.com/SpaceManiac/SpacemanDMM.git
git fetch origin --depth=1 $SPACEMAN_DMM_COMMIT_HASH
git reset --hard FETCH_HEAD

cargo build --release --bin $1
cp target/release/$1 ~
~/$1 --version
