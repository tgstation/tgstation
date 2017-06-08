#!/bin/bash
set -e

if [ "$BUILD_TOOLS" = true ]; then
      rm -rf ~/.nvm && git clone https://github.com/creationix/nvm.git ~/.nvm && (cd ~/.nvm && git checkout `git describe --abbrev=0 --tags`) && source ~/.nvm/nvm.sh && nvm install $NODE_VERSION
      npm install -g gulp-cli
      npm install -g jsonlint-cli
      pip install --user PyYaml -q
      pip install --user beautifulsoup4 -q
fi;


