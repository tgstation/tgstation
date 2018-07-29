#!/bin/sh

#Project dependencies file
#Final authority on what's required to fully build the project

#byond version
#note, this also needs to be changed in the Dockerfile's initial FROM command
#If someone has an idea for how to set that version within the Dockerfile itself without any other dependencies, feel free to PR it
export BYOND_MAJOR=512
export BYOND_MINOR=1441

#rust_g git tag
export RUST_G_VERSION=0.4.0

#bsql git tag
export BSQL_VERSION=v1.4.0.0

#node version
export NODE_VERSION=4
