@echo off
title Automated Error Fixer.
echo This will reset some things, the byond server (DreamDaemon) and the start server script must not be running. Some error messages are normal.
echo You will be prompted to press any key 3 times
pause
pause
pause
cls
echo Resetting folders
mkdir gamecode\a
mkdir gamecode\b
del /S /F /Q gamefolder >nul 2>nul
rmdir /S /q gamefolder
mklink /d gamefolder gamecode\a
call bin\findab.bat
cls
echo Re-Initializing code
call bin\copyfromgit.bat
cls
echo Recompiling the game. If you plan to update or testmerge you can just close this program now and continue.
call bin\build.bat
cls
echo Done! (hopefully)
pause