@echo off
@title NT IRC BOT
echo Welcome to the start bot script, This will start the bot and make sure it stays running. This assumes python in the path. To continue, press any key or wait 60 seconds.
timeout 60
cd bot
:START
call ..\bin\getcurdate.bat
if not exist ..\gamedata\data\logs\bot mkdir ..\gamedata\data\logs\bot\
cls
echo NT IRC Bot
echo Bot Running. Watching for Bot exits.
start /WAIT python NanoTrasenBot.py >>..\gamedata\data\logs\bot\bot-%CUR_DATE%.txt
cls
echo NT IRC Bot
echo Bot exit detected. Restarting in 15 minutes.
REM this is so long because we want to avoid the bot spamming the server and getting klined/glined/or akilled
timeout 900

goto :START
