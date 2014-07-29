#!/bin/bash

#MAPROOT='../../_maps/map_files/'
MAPROOT="../maps/"
MAPFILES=(
	$MAPROOT"tgstation.dmm"
	$MAPROOT"tgstation.2.1.0.0.1.dmm"
	$MAPROOT"vgstation.dmm"
	$MAPROOT"efficiency.dmm"
)
for MAPFILE in "${MAPFILES[@]}"
do
	echo "Processing $MAPFILE..."
	git show HEAD:$MAPFILE > tmp.dmm
	java -jar MapPatcher.jar -clean tmp.dmm $MAPFILE $MAPFILE
	#dos2unix -U '../../_maps/map_files/'$MAPFILE
	rm tmp.dmm
	echo "----------------------"
	continue
done