#!/bin/bash
set -e
source dependencies.sh
echo "Downloading BYOND version ${BYOND_MAJOR}.${BYOND_MINOR}"

if [ "$DOWNLOAD_FROM_BYOND_WEBSITE" = "1" ]; then
	base_url="http://www.byond.com/download/build"
else
	base_url="https://byond-builds.dm-lang.org"
fi

curl -H "User-Agent: tgstation/1.0 CI Script" "${base_url}/${BYOND_MAJOR}/${BYOND_MAJOR}.${BYOND_MINOR}_byond.zip" -o C:/byond.zip
