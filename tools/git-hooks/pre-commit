#!/bin/sh

# This git hook runs optipng on any staged PNG (and DMI, obviously) before committing, and
# updates the staged one with its optimized version automatically. optipng preserves PNG comments
# by default, avoiding breaking DMI files.
#
# The script should be POSIX standard enough that you shouldn't encounter any problem using it,
# provided your shell can find optipng.
#
# To install, just use the install-hooks.sh file provided in this directory, or copy this
# file manually to .git/hooks. Remember that it needs execution permissions in order to work.
#
# If something breaks, bark at wwjnc.

TAG="[optipng-hook]"
OPTIPNG_NOT_FOUND_MSG="$TAG \033[31mCouldn't find optipng, aborting PNG optimization...\033[0m
$TAG \033[31mPlease consider installing optipng before committing PNG/DMI files to the repo!\033[0m"

# Retrieve added or changed PNG files on the commit (if any)
PNG_FILES=`git diff --cached --diff-filter=AM --name-only | grep -i -e ".png\$" -e ".dmi\$"`
[ -z "$PNG_FILES" ] && exit 0

# Check if optipng is available
command -v optipng > /dev/null 2>&1 || { echo -e "$OPTIPNG_NOT_FOUND_MSG"; exit 0; }

# Process files
echo "$TAG Optimizing staged image files..."
for file in $PNG_FILES; do
	if [ -f "$file" ]; then
		before_size_str=`du -h --apparent-size "$file" | cut -f1`
		before_size_bytes=`du -b "$file" | cut -f1`
		optipng -quiet -clobber -keep -- "$file"
		git add "$file"
		after_size_str=`du -h --apparent-size "$file" | cut -f1`
		after_size_bytes=`du -b "$file" | cut -f1`

		if [ "$before_size_bytes" -eq "$after_size_bytes" ]; then
			echo -e "$TAG \033[34m$file is already optimized.\033[0m"
		else
			percent=`echo "scale=2; 100 - 100*$after_size_bytes/$before_size_bytes" | bc`
			echo -e "$TAG \033[32m$file was optimized from $before_size_str to $after_size_str ($percent% reduction)\033[0m"
		fi
	else
		echo -e "$TAG \033[31mCouldn't find file $file, skipping...\033[0m"
	fi
done
