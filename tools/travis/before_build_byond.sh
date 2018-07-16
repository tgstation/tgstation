#!/bin/bash
set -e

#If this is the build tools step, we do not bother to install/build byond
if [ "$BUILD_TOOLS" = true ]; then
  exit 0
fi

echo "Combining maps for building"
if [ $BUILD_TESTING = true ]; then
    python tools/travis/template_dm_generator.py
fi

source dependencies.sh

versionpath = "$HOME/BYOND/version.txt"

if [ -d "$HOME/BYOND/byond/bin" ] && grep -Fxq "${BYOND_MAJOR}.${BYOND_MINOR}" $HOME/BYOND/version.txt;
then
  echo "Using cached directory."
else
  echo "Setting up BYOND."
  mkdir -p "$HOME/BYOND"
  rm -rf "$HOME/BYOND/*"
  cd "$HOME/BYOND"
  curl "http://www.byond.com/download/build/${BYOND_MAJOR}/${BYOND_MAJOR}.${BYOND_MINOR}_byond_linux.zip" -o byond.zip
  unzip byond.zip
  cd byond
  make here
  echo "$BYOND_MAJOR.$BYOND_MINOR" > "$HOME/BYOND/version.txt"
  cd ~/
fi
