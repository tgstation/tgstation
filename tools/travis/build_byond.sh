#!/bin/bash

#nb: must be bash to support shopt globstar
set -e
shopt -s globstar

if [ "$BUILD_TOOLS" = false ]; then
    (! grep 'step_[xy]' _maps/**/*.dmm)
    source $HOME/BYOND-${BYOND_MAJOR}.${BYOND_MINOR}/byond/bin/byondsetup
    tools/travis/dm.sh -M${DM_MAPFILE} tgstation.dme
fi;
