#!/bin/bash

#Run this in the repo root after compiling
#First arg is path to where you want to deploy
#creates a work tree free of everything except what's necessary to run the game

mkdir -p \
    $1/_maps \
    $1/icons/minimaps \
    $1/sound/chatter \
    $1/sound/voice/complionator \
    $1/sound/instruments \
    $1/strings

if [ -d ".git" ]; then
  # Control will enter here if $DIRECTORY exists.
  mkdir -p $1/.git/logs
  cp -r .git/logs/* $1/.git/logs/
fi

cp tgstation.dmb tgstation.rsc $1/
cp -r _maps/* $1/_maps/
cp icons/default_title.dmi $1/icons/
cp -r icons/minimaps/* $1/icons/minimaps/
cp -r sound/chatter/* $1/sound/chatter/
cp -r sound/voice/complionator/* $1/sound/voice/complionator/
cp -r sound/instruments/* $1/sound/instruments/
cp -r strings/* $1/strings/

#remove .dm files from _maps

#this regrettably doesn't work with windows find
#find $1/_maps -name "*.dm" -type f -delete

#dlls on windows
cp rust_g* $1/ || true
cp *BSQL.* $1/ || true
