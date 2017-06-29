#!/usr/bin/env bash
source ~/.discordauth

set -u # don't expand unbound variable
set -f # disable pathname expansion
set -C # noclobber

BASE_BRANCH_NAME="upstream-merge-"
BASE_PULL_URL="https://api.github.com/repos/tgstation/tgstation/pulls"
LOG_FILE="../logs/$BASE_BRANCH_NAME$1.log"

# Close STDOUT file descriptor
exec 1<&-
# Close STDERR FD
exec 2<&-

# Open STDOUT as $LOG_FILE file for read and write.
exec 1<>$LOG_FILE

# Redirect STDERR to STDOUT
exec 2>&1

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

# Ensure curl exists and is available in the current context
type curl >/dev/null 2>&1 || { echo >&2 "Error: This script requires curl, please ensure curl is installed and exists in the current PATH"; exit 1; }

# Ensure jq exists and is available in the current context
type jq >/dev/null 2>&1 || { echo >&2 "Error: This script requires jq, please ensure jq is installed and exists in the current PATH"; exit 1; }

# Make sure we have our upstream remote
if ! git remote | grep tgstation > /dev/null; then
   git remote add tgstation https://github.com/tgstation/tgstation.git
fi

curl -v \
-H "Authorization: Bot $TOKEN" \
-H "User-Agent: myBotThing (http://some.url, v0.1)" \
-H "Content-Type: application/json" \
-X POST \
-d "{\"content\":\"Mirroring [$1] from /tg/ to Hippie\"}" \
https://discordapp.com/api/channels/$CHANNELID/messages

# We need to make sure we are always on a clean master when creating the new branch.
# So we forcefully reset, clean and then checkout the master branch
git fetch --all
git checkout master
git reset --hard origin/master
git clean -f

# Remove the other branches
git branch | grep -v "master" | xargs git branch -D

# Create a new branch
git checkout -b "$BASE_BRANCH_NAME$1"

# Grab the SHA of the merge commit
MERGE_SHA=$(curl --silent "$BASE_PULL_URL/$1" | jq '.merge_commit_sha' -r)

# Cherry pick onto the new branch
CHERRY_PICK_OUTPUT=$(git cherry-pick -m 1 "$MERGE_SHA" 2>&1)
echo "$CHERRY_PICK_OUTPUT"

# If it's a squash commit, you can't use -m 1, you need to remove it
if echo "$CHERRY_PICK_OUTPUT" | grep 'error: mainline was specified but commit'; then
  echo "Commit was a squash, retrying"
  git cherry-pick "$MERGE_SHA"
  # Add all files onto this branch
  git add -A .
  git cherry-pick --continue
else
  # Add all files onto this branch
  git add -A .
fi

# Commit these changes
git commit --allow-empty -m "$2"

# Push them onto the branch
git push -u origin "$BASE_BRANCH_NAME$1"
