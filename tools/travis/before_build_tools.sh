#!/bin/bash
set -e

if [ "$BUILD_TOOLS" = true ]; then
    cd tgui && source ~/.nvm/nvm.sh && npm install && cd ..
fi;

