@echo off
@title Map Rotator

if not exist setnewmap.bat exit 1
call setnewmap.bat
cd ..
if not exist config.bat exit 2
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
if %DM_EXIT% neq 0 exit 3

rmdir /q gamefolder
mklink /d gamefolder gamecode\%AB% >nul
