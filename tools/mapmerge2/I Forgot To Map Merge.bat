@echo off
echo Installing hooks for next time...
call "%~dp0\..\bootstrap\python.bat" -m hooks.install
echo.
echo Fixing things up...
call "%~dp0\..\bootstrap\python.bat" -m mapmerge2.fixup
pause
