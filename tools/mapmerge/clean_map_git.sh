#!/bin/sh

MAPFILE='tgstation.2.1.3.dmm'

git show HEAD:_maps/map_files/$MAPFILE > tmp.dmm
java -jar MapPatcher.jar -clean tmp.dmm '../../_maps/map_files/'$MAPFILE '../../_maps/map_files/'$MAPFILE
dos2unix -U '../../_maps/map_files/'$MAPFILE
rm tmp.dmm

