#!/bin/bash
shopt -s nullglob
cd "$(dirname "$0")"
for f in *.hook; do
	echo Installing hook: ${f%.hook}
	cp $f ../../.git/hooks/${f%.hook}
done
for f in *.merge; do
	echo Installing merge driver: ${f%.merge}
	git config --replace-all merge.${f%.merge}.driver "tools/hooks/$f %P %O %A %B %L"
done
echo "Done"
