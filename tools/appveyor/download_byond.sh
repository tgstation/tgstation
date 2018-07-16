#!/bin/bash

source dependencies.sh
curl "http://www.byond.com/download/build/$BYOND_MAJOR/$BYOND_MAJOR.$BYOND_MINOR}_byond.zip" -o byond.zip
