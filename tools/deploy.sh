#!/bin/bash

#Run this in the repo root after compiling
#First arg is path to where you want to deploy
#creates a work tree free of everything except what's necessary to run the game

mkdir -p \
    $1/.git/logs \
    $1/_maps \
    $1/icons/minimaps \
    $1/sound/chatter \
    $1/sound/voice/complionator \
    $1/sound/instruments \
    $1/strings

cp tgstation.dmb tgstation.rsc $1/
cp -r .git/logs/* $1/.git/logs/
cp -r _maps/* $1/_maps/
cp icons/default_title.dmi $1/icons/
cp -r icons/minimaps/* $1/icons/minimaps/
cp -r sound/chatter/* $1/sound/chatter/
cp -r sound/voice/complionator/* $1/sound/voice/complionator/
cp -r sound/instruments/* $1/sound/instruments/
cp -r strings/* $1/strings/
