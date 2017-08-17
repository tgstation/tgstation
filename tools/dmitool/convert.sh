#!/bin/bash
for filename in pngs/*.png; do
	realname=$(basename "$filename")
	java -jar dmitool.jar import credits.dmi "$realname" "$filename"
done