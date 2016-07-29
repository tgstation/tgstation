#!/bin/bash -ex
set -x
# ARGUMENT 1: Map
BYOND_MAJOR="509"
BYOND_MINOR="1307"
# Jenkins doesn't have permissions to do this.
# Jenkins is also on Debian so the packages are wrong.
#apt-get update
#apt-get --yes install build-essential unzip lib32stdc++6 gcc-multilib

# This ensures we have an up-to-date LOCAL install of BYOND, and doesn't download it every goddamn build.
BYOND_DIR=/tmp/byond-${BYOND_MAJOR}.${BYOND_MINOR}
if [ ! -d $BYOND_DIR ]; then
  rm -rf /tmp/byond-* byond.zip
  curl "http://www.byond.com/download/build/${BYOND_MAJOR}/${BYOND_MAJOR}.${BYOND_MINOR}_byond_linux.zip" -o byond.zip
  unzip byond.zip
  mv byond/ $BYOND_DIR
  cd $BYOND_DIR
  make here
  cd ..
fi
# Environment setup
source $BYOND_DIR/bin/byondsetup

bash dm.sh -M$1 vgstation13.dme
