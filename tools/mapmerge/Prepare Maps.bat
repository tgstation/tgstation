@echo off
cd ../../_maps/map_files/

for /R %%f in (*.dmm) do copy "%%f" "%%f.backup"

cls
echo All dmm files in map_files directories have been backed up
echo Now you can make your changes...
echo ---
echo Remember to run Run_Map_Merge.bat just before you commit your changes!
echo ---
pause
