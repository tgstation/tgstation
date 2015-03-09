#!/bin/bash

#MAPROOT='../../_maps/map_files/'
MAPROOT="../maps/"
MAPFILES=(
	$MAPROOT"tgstation.dmm"
	$MAPROOT"vgstation.dmm"
	$MAPROOT"defficiency.dmm"
	$MAPROOT"taxistation.dmm"
	$MAPROOT"metaclub.dmm"
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