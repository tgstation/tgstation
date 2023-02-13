#!/bin/bash

# Special file to ensure all dependencies still exist between server lanuches.
# Mainly for use by people who abuse docker by modifying the container's system.

set -e
set -x

./InstallDeps.sh
