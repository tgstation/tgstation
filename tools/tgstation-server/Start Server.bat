@echo off
call config.bat
call bin\findbyond.bat


cd gamefolder

if not exist .\data\logs\runtimes mkdir data\logs\runtimes\
@python nudge.py "WATCHDOG" "Watch Dog online. Starting server" >nul 2>nul

:START
call ..\bin\getcurdate.bat
cls
echo Server Running. Watching for server exits.
start /WAIT /ABOVENORMAL "" dreamdaemon.exe %PROJECTNAME%.dmb -port %PORT% -trusted -close -log "data\logs\runtimes\runtime-%CUR_DATE%.log"
cls
echo Server exit detected. Restarting in 60 seconds.
@python nudge.py "WATCHDOG" "Server exit detected. Restarting server in 60 seconds." >nul 2>nul
timeout 60 /NOBREAK

goto :START
