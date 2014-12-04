@echo off
echo. >> ../../.git/config
echo [merge "merge-dmm"] >> ../../.git/config
echo	name = mapmerge driver >> ../../.git/config
echo	driver = ./tools/mapmerge/mapmerge.sh %O %A %B >> ../../.git/config
echo. >> ../../.git/config

