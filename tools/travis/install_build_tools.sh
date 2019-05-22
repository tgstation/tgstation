#!/bin/bash
set -e

source dependencies.sh

if [ "$BUILD_TOOLS" = true ]; then
      source ~/.nvm/nvm.sh
      nvm install $NODE_VERSION
      pip3 install --user PyYaml
      pip3 install --user beautifulsoup4
fi;
