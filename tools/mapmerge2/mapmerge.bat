@echo off
set MAPROOT=../../_maps/
set TGM=1
"%~dp0\..\bootstrap\python" -m mapmerge2.mapmerge
pause
