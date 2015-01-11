@echo off
cd ../../_maps/map_files/
set /P MAPFILE=Please enter mapfile (relative to map_files folder):

java -jar ../../tools/mapmerge/MapPatcher.jar -clean "%MAPFILE%.backup" "%MAPFILE%" "%MAPFILE%"

pause