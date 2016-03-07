@echo off
set MAPROOT="../../_maps/"
set TGM=0
python mapmerger.py %1 %MAPROOT% %TGM%
pause