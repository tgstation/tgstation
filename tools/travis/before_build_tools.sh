#!/bin/bash
set -e

if [ "$BUILD_TOOLS" = true ]; then
    cd tgui && source ~/.nvm/nvm.sh && npm install && cd ..
fi;

if [ "$DM_MAPFILE" = "templates" ]; then
    python tools/travis/template_dm_generator.py
fi;
