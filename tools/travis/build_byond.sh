#!/bin/bash

#nb: must be bash to support shopt globstar
set -e
shopt -s globstar

if [ "$BUILD_TOOLS" = false ]; then
	if grep 'pixel_[xy] = 0' _maps/**/*.dmm;	then
    	echo "pixel_[xy] = 0 detected in maps, please review to ensure they are not dirty varedits."
	fi;
	if grep '^/area/.+[\{]' _maps/**/*.dmm;	then
    	echo "Vareditted /area path use detected in maps, please replace with proper paths."
    	exit 1
	fi;
	if grep '^/*var/' code/**/*.dm; then
		echo "Unmanaged global var use detected in code, please use the helpers."
		exit 1
	fi;
	if grep -i 'centcomm' code/**/*.dm; then
		echo "Misspelling(s) of CENTCOM detected in code, please remove the extra M(s)."
		exit 1
	fi;
	if grep -i 'centcomm' _maps/**/*.dmm; then
		echo "Misspelling(s) of CENTCOM detected in maps, please remove the extra M(s)."
		exit 1
	fi;

	#config folder should not be mandatory
	rm -rf config

    source $HOME/BYOND-${BYOND_MAJOR}.${BYOND_MINOR}/byond/bin/byondsetup
	if [ "$BUILD_TESTING" = true ]; then
		tools/travis/dm.sh -DTRAVISBUILDING -DTRAVISTESTING -DALL_MAPS tgstation.dme
	else
		tools/travis/dm.sh -DTRAVISBUILDING tgstation.dme && DreamDaemon tgstation.dmb -close -trusted -params "test-run&log-directory=travis"
		cat data/logs/travis/clean_run.lk
	fi;
fi;
