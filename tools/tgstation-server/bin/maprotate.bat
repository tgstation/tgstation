@echo off
@title Map Rotator

if not exist setnewmap.bat exit 11
call setnewmap.bat
cd ..
if not exist config.bat exit 12
call config.bat

cls
echo Rotating map to %MAPROTATE%

call bin\findab.bat

cls
echo Rotating map to %MAPROTATE%

call bin\copyfromgit.bat

cls
echo Rotating map to %MAPROTATE%

call bin\build.bat
if %DM_EXIT% neq 0 exit 13

rmdir /q gamefolder
mklink /d gamefolder gamecode\%AB%
