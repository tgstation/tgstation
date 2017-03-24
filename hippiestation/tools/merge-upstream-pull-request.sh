#!/usr/bin/env bash

set -u # don't expand unbound variable
set -f # disable pathname expansion
set -C # noclobber

BASE_PATCH_URL="https://patch-diff.githubusercontent.com/raw/tgstation/tgstation/pull/"
BASE_BRANCH_NAME="upstream-merge-"
BASE_COMMIT_MESSAGE="Automatic merge of upstream pull request: "

tmpfile=$(mktemp /tmp/git-patch-script.XXXXXX)

# Ensure the current directory is a git directory
if [ ! -d .git ]; then
    echo "Error: must run this script from the root of a git repository"
    exit 1
fi

# Ensure all given parameters exist
if [ $# -eq 0 ]; then
    echo "Error: No arguments have been given, the first argument needs to be a pull ID"
    exit 1
fi

# Make sure our temp file exists
if [ ! -f $tmpfile ]; then
    echo "Error: mktemp failed to create a temporarily file"
    exit 1
fi

# Ensure wget exists and is available in the current context
type wget >/dev/null 2>&1 || { echo >&2 "Error: This script requires wget, please ensure wget is installed and exists in the current PATH"; exit 1; }

# Download the patchfile
wget "$BASE_PATCH_URL$1.patch" -q -O $tmpfile

# Create a new branch
git checkout -b "$BASE_BRANCH_NAME$1"

# Apply the patch on top of this new branch
git apply --reject --whitespace=nowarn $tmpfile

# Add all files onto this branch
git add -A .

# Commit these changes
git commit -m "$BASE_COMMIT_MESSAGE$1"

# Push them onto the branch
git push -u origin "$BASE_BRANCH_NAME$1"