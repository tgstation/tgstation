#!/usr/bin/env bash
source ~/.discordauth

# ~/.discordauth contains:
# CHANNELID=x
# TOKEN=x
# CHANNELID being the Discord Channel ID
# TOKEN being the bot token

set -u # don't expand unbound variable
set -f # disable pathname expansion
set -C # noclobber

readonly BASE_BRANCH_NAME="upstream-merge-"
readonly BASE_PULL_URL="https://api.github.com/repos/tgstation/tgstation/pulls"

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

containsElement () {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

# Make sure we have our upstream remote
if ! git remote | grep tgstation > /dev/null; then
   git remote add tgstation https://github.com/tgstation/tgstation.git
fi

curl -v \
-H "Authorization: Bot $TOKEN" \
-H "User-Agent: myBotThing (http://some.url, v0.1)" \
-H "Content-Type: application/json" \
-X POST \
-d "{\"content\":\"Mirroring [$1] from /tg/ to Citadel\"}" \
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
readonly MERGE_SHA=$(curl --silent "$BASE_PULL_URL/$1" | jq '.merge_commit_sha' -r)

# Get the commits
readonly COMMITS=$(curl --silent "$BASE_PULL_URL/$1/commits" | jq '.[].sha' -r)

# Cherry pick onto the new branch
echo "Cherry picking onto branch"
CHERRY_PICK_OUTPUT=$(git cherry-pick -m 1 "$MERGE_SHA" 2>&1)
echo "$CHERRY_PICK_OUTPUT"

# If it's a squash commit, you can't use -m 1, you need to remove it
# You also can't use -m 1 if it's a rebase and merge...
if echo "$CHERRY_PICK_OUTPUT" | grep -i 'error: mainline was specified but commit'; then
  echo "Commit was a squash, retrying"
  if containsElement "$MERGE_SHA" "${COMMITS[@]}"; then
    for commit in $COMMITS; do
  	  echo "Cherry-picking: $commit"
	  git cherry-pick "$commit"
	  # Add all files onto this branch
	  git add -A .
	  git cherry-pick --continue
    done
  else
    echo "Cherry-picking: $MERGE_SHA"
	git cherry-pick "$MERGE_SHA"
	# Add all files onto this branch
	git add -A .
	git cherry-pick --continue
  fi
else
  # Add all files onto this branch
  echo "Adding files to branch:"
  git add -A .
fi

# Commit these changes
echo "Commiting changes"
git commit --allow-empty -m "$2"

# Push them onto the branch
echo "Pushing changes"
git push -u origin "$BASE_BRANCH_NAME$1"
