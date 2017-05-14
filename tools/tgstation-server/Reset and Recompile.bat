@echo off
@title Server Updater
set HOME = %USERPROFILE%

call config.bat
call bin\getcurdate.bat
call bin\findgit.bat

echo This will handle resetting the git repo, recompiling the server, and applying the new version.
echo Ready?

timeout 120

if exist updating.lk (
	echo ERROR: A current update script has been detected running. if you know this is a mistake:
	pause
	echo Please be double sure that an update script is not currently running, if you think one might be, close this window. otherwise:
	pause
)

echo lock>updating.lk

rem if the first arg to nudge.py is not a channel, it is treated as the "source"
if not defined UPDATE_LOG_CHANNEL set UPDATE_LOG_CHANNEL="UPDATER"

call python bot\nudge.py %UPDATE_LOG_CHANNEL% "Reset local changes job started" >nul 2>nul

cd gitrepo
git reset --hard
git clean -df
cd ..
echo ##################################
echo ##################################
echo:
echo Resetting done, compiling in 10 seconds. If you want to preform other actions (like test merges) You can close this now and do them.
echo:
del updating.lk >nul 2>nul

timeout 10

echo lock>updating.lk
call bin\findab.bat

call bin\copyfromgit.bat

echo compiling change log
cd gamecode\%AB%
call python tools\ss13_genchangelog.py html/changelog.html html/changelogs
cd ..\..

echo Compiling game.
call bin\build.bat
if %DM_EXIT% neq 0 (
	echo DM compile failed. Aborting.
	call python bot\nudge.py %UPDATE_LOG_CHANNEL% "DM compile failed Aborting Reset." >nul 2>nul
	del /F /Q updating.lk >nul 2>nul
	pause
	exit /b 1
)

del updating.lk >nul 2>nul
rmdir /q gamefolder
mklink /d gamefolder gamecode\%AB% >nul
call python bot\nudge.py %UPDATE_LOG_CHANNEL% "Reset finished. Reset will take place next round." >nul 2>nul
echo Done. The Reset will automatically take place at round restart.
timeout 300
