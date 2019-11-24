# Usage: fix_tgui_conflicts.sh <reset commit sha>
# Fixes conflicts in tgui.bundle.js and tgui.bundle.css
# Run in repository root
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
git reset master -- tgui-next/packages/tgui/public/tgui.bundle.js > /dev/null
git reset master -- tgui-next/packages/tgui/public/tgui.bundle.css > /dev/null
echo "Checking Out"
git checkout $1 -- tgui-next/packages/tgui/public/tgui.bundle.js > /dev/null
git checkout $1 -- tgui-next/packages/tgui/public/tgui.bundle.css > /dev/null
