#!/bin/bash
set -e

source dependencies.sh

if [ "$BUILD_TOOLS" = true ]; then
      nvm install $NODE_VERSION
      pip3 install --user PyYaml
      pip3 install --user beautifulsoup4
fi;
