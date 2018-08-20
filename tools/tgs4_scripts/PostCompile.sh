#!/bin/sh

#Basically run deploy.sh, but first

echo 'Deploying tgstation compilation...'

cd $1

mkdir build

shopt -s extglob dotglob
mv !(build) build
shopt -u dotglob

build/tools/deploy.sh $1 $1/build

rm -rf build
