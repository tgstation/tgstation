#!/bin/bash
set -e

source dependencies.sh

if [ "$BUILD_TOOLS" = true ]; then
      rm -rf ~/.nvm && git clone https://github.com/creationix/nvm.git ~/.nvm && (cd ~/.nvm && git checkout `git describe --abbrev=0 --tags`) && source ~/.nvm/nvm.sh && nvm install $NODE_VERSION
      npm install -g gulp-cli
      pip3 install --user PyYaml -q
      pip3 install --user beautifulsoup4 -q
fi;


