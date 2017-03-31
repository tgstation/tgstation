export MAPFILE_TG=tgstation.2.1.3.dmm

java -jar MapPatcher.jar -clean ../../_maps/map_files/TgStation/$MAPFILE_TG.backup ../../_maps/map_files/TgStation/$MAPFILE_TG ../../_maps/map_files/TgStation/$MAPFILE_TG

read -n1 -r -p "Press any key to continue..." key
