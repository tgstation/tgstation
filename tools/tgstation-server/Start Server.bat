@echo off
@title SERVER WATCHDOG
call config.bat
call bin\findbyond.bat

echo Welcome to the start server watch dog script, This will start the server and make sure it stays running. To continue, press any key or wait 60 seconds.
timeout 60

if not exist gamedata\data\logs\runtimes mkdir gamedata\data\logs\runtimes\
@python bot\nudge.py "WATCHDOG" "Watch Dog online. Starting server" >nul 2>nul

:START
call bin\getcurdate.bat
cls
echo Watch Dog.
echo Server Running. Watching for server exits.
start /WAIT /ABOVENORMAL "" dreamdaemon.exe gamefolder\%PROJECTNAME%.dmb -port %PORT% -trusted -close -log "data\logs\runtimes\runtime-%CUR_DATE%.log"
cls
echo Watch Dog.
echo Server exit detected. Restarting in 60 seconds.
@python bot\nudge.py "WATCHDOG" "Server exit detected. Restarting server in 60 seconds." >nul 2>nul
timeout 60

goto :START
