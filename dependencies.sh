#!/bin/bash

#Project dependencies file
#Final authority on what's required to fully build the project

# byond version
# Extracted from the Dockerfile. Change by editing Dockerfile's FROM command.
LIST=($(sed -n 's/.*byond:\([0-9]\+\)\.\([0-9]\+\).*/\1 \2/p' Dockerfile))
export BYOND_MAJOR=${LIST[0]}
export BYOND_MINOR=${LIST[1]}
unset LIST

#rust_g git tag
export RUST_G_VERSION=0.4.3

#bsql git tag
export BSQL_VERSION=v1.4.0.0

#node version
export NODE_VERSION=12

# PHP version
export PHP_VERSION=5.6

# SpacemanDMM git tag
export SPACEMAN_DMM_VERSION=suite-1.3

# SpacemanDMM commit hash
export SPACEMAN_DMM_COMMIT_HASH=3cd3c402af04e6deedc9149caf5c5b0dfd44ad3b
