@echo off
@title Map Rotator

if not exist setnewmap.bat exit 11
call setnewmap.bat
cd ..

if exist updating.lk exit 21
if exist rotating.lk exit 22

if not exist config.bat exit 12
call config.bat
echo lock>rotating.lk
cls
echo Rotating map to %MAPROTATE%

call bin\findab.bat

cls
echo Rotating map to %MAPROTATE%

call bin\copyfromgit.bat

cls
echo Rotating map to %MAPROTATE%

call bin\build.bat
@del /F /Q rotating.lk >nul 2>nul
if %DM_EXIT% neq 0 exit 31

rmdir /q gamefolder
mklink /d gamefolder gamecode\%AB%
