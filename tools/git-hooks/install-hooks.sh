#!/bin/sh

# List of client-sided Git hooks
GIT_HOOKS="applypatch-msg pre-applypatch post-applypatch pre-commit prepare-commit-msg commit-msg
post-commit pre-rebase post-checkout post-merge pre-auto-gc post-rewrite
pre-push"

BASEDIR=`dirname "$0"`
REPO_ROOT=`git rev-parse --show-toplevel`
REPO_GIT_DIR=`git rev-parse --git-dir`

for hook in $GIT_HOOKS; do
	if [ ! -f "$BASEDIR/$hook" ]; then
		continue;
	fi

	if [ ! -e "$REPO_GIT_DIR/hooks/$hook" ]; then
		ln -s `readlink -f "$BASEDIR/$hook"` "$REPO_GIT_DIR/hooks/$hook"
		echo -e "\033[32m$hook: installed correctly\033[0m"
	else
		echo -e "\033[31m$hook: existing hook found, skipping...\033[0m"
	fi
done
