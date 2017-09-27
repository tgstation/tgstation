#!/bin/sh
cd "$(dirname "$0")"
for f in *.hook; do
	echo Installing ${f%.hook}
	cp $f ../../.git/hooks/${f%.hook}
done
echo Done
