#!/bin/bash

#nb: must be bash to support shopt globstar
set -e
shopt -s globstar

if [ "$BUILD_TOOLS" = false ]; then
    source $HOME/BYOND-${BYOND_MAJOR}.${BYOND_MINOR}/byond/bin/byondsetup
	if [ "$BUILD_TESTING" = true ]; then
		tools/travis/dm.sh -DTRAVISBUILDING tgstation.dme
	else
		tools/travis/dm.sh -DTRAVISBUILDING -DTRAVISTESTING -DALL_MAPS tgstation.dme
	fi;
fi;
