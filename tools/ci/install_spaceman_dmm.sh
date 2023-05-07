#!/bin/bash
set -euo pipefail

source dependencies.sh

if [ ! -f ~/$1 ]; then
	mkdir -p "$HOME/SpacemanDMM"
	CACHEFILE="$HOME/SpacemanDMM/$1"

	if ! [ -f "$CACHEFILE.version" ] || ! grep -Fxq "$SPACEMAN_DMM_VERSION-Cyberboss" "$CACHEFILE.version"; then # FIX THIS LINE TOO
		wget -O "$CACHEFILE" "https://github.com/Cyberboss/SpacemanDMM/releases/download/$SPACEMAN_DMM_VERSION/$1" # DO NOT MERGE UNTIL THIS IS SET BACK TO SPACEMANIAC'S VERSION OF THE REPO
		chmod +x "$CACHEFILE"
		echo "$SPACEMAN_DMM_VERSION" >"$CACHEFILE.version"
	fi

	ln -s "$CACHEFILE" ~/$1
fi

~/$1 --version
