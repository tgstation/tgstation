@echo off
set MAPROOT=../../_maps/
set TGM=0
"%~dp0\..\bootstrap\python" -m mapmerge2.convert
pause
