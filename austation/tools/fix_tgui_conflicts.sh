#!/bin/bash
# Usage: fix_tgui_conflicts.sh <reset commit sha>
# Fixes conflicts in tgui folder by resetting everything to the correct commit
# Run in repository root AFTER merging all proceeding PRs (Don't merge out of order.)
if [ -z "$1" ]
then
	echo "Specify a commit sha to reset to."
	exit 1
fi
echo "Updating"
git pull > /dev/null
git fetch tgstation > /dev/null # requires a remote to be added for this
echo "Merging"
git merge master > /dev/null
echo "Resetting"
git reset master -- tgui-next/ > /dev/null
echo "Checking Out"
git checkout $1 -- tgui-next/ > /dev/null
