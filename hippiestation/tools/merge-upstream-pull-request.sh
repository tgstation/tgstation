#!/usr/bin/env bash

set -u # don't expand unbound variable
set -f # disable pathname expansion
set -C # noclobber

BASE_PATCH_URL="https://patch-diff.githubusercontent.com/raw/tgstation/tgstation/pull/"
BASE_BRANCH_NAME="upstream-merge-"

# Ensure the current directory is a git directory
if [ ! -d .git ]; then
    echo "Error: must run this script from the root of a git repository"
    exit 1
fi

# Ensure all given parameters exist
if [ $# -eq 0 ]; then
    echo "Error: No arguments have been given, the first argument needs to be a pull ID, the second argument needs to be the commit message"
    exit 1
fi

# We need to make sure we are always on a clean master when creating the new branch.
# So we forcefully reset, clean and then checkout the master branch
git fetch
git checkout master
git reset --hard origin/master
git clean -f

# Remove the other branches
git branch | grep -v "master" | xargs git branch -D

# Create a new branch
git checkout -b "$BASE_BRANCH_NAME$1"

# Cherry pick onto the new branch
git cherry-pick -m 1 -X ignore-all-space "$3"

# Add all files onto this branch
git add -A .

# Commit these changes
git commit -m "$2"

# Push them onto the branch
git push -u origin "$BASE_BRANCH_NAME$1"
