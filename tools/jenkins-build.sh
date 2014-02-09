#!/bin/bash -ex
# Blatantly stolen from /tg/'s .travis.yml script.
curl "http://www.byond.com/download/build/${BYOND_MAJOR}/${BYOND_MAJOR}.${BYOND_MINOR}_byond_linux.zip" -o byond.zip
unzip byond.zip
cd byond
sudo make install
cd ..
chmod +x dm.sh

./dm.sh baystation12.dme -Mtgstation.2.1.0.0.1