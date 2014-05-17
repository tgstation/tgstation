set MAPFILE_TG=tgstation.2.1.0.0.1.dmm
set MAPFILE_VG=vgstation.dmm

cd ../maps
copy %MAPFILE_TG% %MAPFILE_TG%.backup
copy %MAPFILE_VG% %MAPFILE_VG%.backup

pause
