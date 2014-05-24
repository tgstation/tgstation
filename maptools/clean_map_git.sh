#!/bin/sh

#MAPROOT='../../_maps/map_files/'
MAPROOT='../maps/'
MAPFILE=$MAPROOT'tgstation.dmm'

git show HEAD:$MAPFILE > tmp.dmm
java -jar MapPatcher.jar -clean tmp.dmm $MAPFILE $MAPFILE
#dos2unix -U '../../_maps/map_files/'$MAPFILE
rm tmp.dmm

