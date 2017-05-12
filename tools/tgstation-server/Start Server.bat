@echo off
@title SERVER WATCHDOG
call config.bat
call bin\findbyond.bat

echo Welcome to the start server watch dog script, This will start the server and make sure it stays running. To continue, press any key or wait 30 seconds.
timeout 30

if not exist gamedata\data\logs\runtimes mkdir gamedata\data\logs\runtimes\

@call python bot\nudge.py "WATCHDOG" "Watch Dog online. Starting server" >nul 2>nul
:START

call bin\getcurdate.bat

call bin\getunixtime.bat UNIXTIME

echo %UNIXTIME%

set STARTTIME=%UNIXTIME%

cls
echo Watch Dog.
echo Server Running. Watching for server exits.
start /WAIT /ABOVENORMAL "" dreamdaemon.exe gamefolder\%PROJECTNAME%.dmb -port %PORT% -trusted -close -public -verbose
cls

call bin\getunixtime.bat UNIXTIME

SET /A Result=%UNIXTIME% - %STARTTIME%
SET /A Result=180 - (%Result%/3)
if %Result% LSS 0 set /A Result=0

echo Watch Dog.
echo Server exit detected. Restarting in %Result% seconds.
@python bot\nudge.py "WATCHDOG" "Server exit detected. Restarting server in %Result% seconds." >nul 2>nul
timeout %Result%

goto :START
