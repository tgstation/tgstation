@echo off
title Server Boot Detected.
echo This script is only meant to start byond when the server first boots, do not manually run this.
echo If you manually ran this, close this window NOW.
timeout 15
start cmd /c "Start Bot.bat"
cls
echo Server boot detected. Starting byond and Space Station 13.
echo Prepping code
mkdir gamecode\a
cls
echo Server boot detected. Starting byond and Space Station 13.
echo Prepping code
mkdir gamecode\b
cls
echo Server boot detected. Starting byond and Space Station 13.
echo Prepping code
del /S /F /Q gamefolder >nul 2>nul
cls
echo Server boot detected. Starting byond and Space Station 13.
echo Prepping code
rmdir /S /q gamefolder
cls
echo Server boot detected. Starting byond and Space Station 13.
echo Prepping code
mklink /d gamefolder gamecode\a
cls
echo Server boot detected. Starting byond and Space Station 13.
echo Prepping code
call bin\findab.bat
cls
echo Server boot detected. Starting byond and Space Station 13.
echo Re-Initializing code
call bin\copyfromgit.bat
cls
echo Server boot detected. Starting byond and Space Station 13.
echo Re-Initializing code
cls
cls
echo Server boot detected. Starting byond and Space Station 13.
echo Compiling the game. If you plan to update or testmerge you can just close this program now and continue.
call bin\build.bat
cls
echo Server boot detected. Starting byond and Space Station 13.
echo Starting server and bot.
start cmd /c "Start Server.bat"
timeout 10