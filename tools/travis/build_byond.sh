#!/bin/bash

#nb: must be bash to support shopt globstar
set -e
shopt -s globstar

if [ "$BUILD_TOOLS" = false ]; then
	if grep 'step_[xy]' _maps/**/*.dmm;	then
    	echo "step_[xy] variables detected in maps, please remove them."
    	exit 1
	fi;
	if grep '\W\/turf\s*[,\){]' _maps/**/*.dmm; then
    	echo "base /turf path use detected in maps, please replace with proper paths."
    	exit 1
	fi;
	if grep '^/*var/' code/**/*.dm; then
		echo "Unmanaged global var use detected in code, please use the helpers."
		grep '^var/' code/*.dm | echo
		exit 1
	fi;
    source $HOME/BYOND-${BYOND_MAJOR}.${BYOND_MINOR}/byond/bin/byondsetup
	if [ "$BUILD_TESTING" = true ]; then
		tools/travis/dm.sh -DTRAVISBUILDING tgstation.dme
	else
		tools/travis/dm.sh -DTRAVISBUILDING -DTRAVISTESTING -DALL_MAPS tgstation.dme
	fi;
fi;
