set MAPFILE_TG=tgstation.2.1.0.0.1.dmm
set MAPFILE_VG=vgstation.dmm

java -jar MapPatcher.jar -clean ../maps/%MAPFILE_TG%.backup ../maps/%MAPFILE_TG% ../maps/%MAPFILE_TG%
java -jar MapPatcher.jar -clean ../maps/%MAPFILE_VG%.backup ../maps/%MAPFILE_VG% ../maps/%MAPFILE_VG%

pause
