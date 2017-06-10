@echo off
title Server Updater
SETLOCAL ENABLEDELAYEDEXPANSION
set HOME = %USERPROFILE%

call config.bat
call bin\getcurdate.bat

echo This will handle downloading git, compiling the server, and applying the update.
echo Ready?

timeout 120

if exist updating.lk (
	echo ERROR: A current update script has been detected running. if you know this is a mistake:
	pause
	echo Please be double sure that an update script is not currently running, if you think one might be, close this window. otherwise:
	pause
)

if exist prtestjob.lk (
	call bin/activepr.bat
	echo WARNING: The server is currently testing the following PRs !PR!. This update would override that. Do you still want to update? Close this window if not, otherwise:
	pause
)

del /F /Q prtestjob.lk >nul 2>nul

echo lock>updating.lk
<nul set /p TRIM="set PR=" > bin/activepr.bat

rem if the first arg to nudge.py is not a channel, it is treated as the "source"
if not defined UPDATE_LOG_CHANNEL set UPDATE_LOG_CHANNEL="UPDATER"

call python bot\nudge.py %UPDATE_LOG_CHANNEL% "Update job started" >nul 2>nul

call bin\updategit.bat
if %GIT_EXIT% neq 0 (
	echo git pull failed. Aborting update
	call python bot\nudge.py %UPDATE_LOG_CHANNEL% "Git fetch failed. Aborting update"
	del updating.lk >nul 2>nul
	pause
	exit /b 1
)

if defined PUSHCHANGELOGTOGIT (
	cd gitrepo
	echo compiling change log
	python tools\ss13_genchangelog.py html/changelog.html html/changelogs
	if !ERRORLEVEL! == 0 (
		echo pushing compiled changelog to server
		git add -u html/changelog.html
		git add -u html/changelogs
		git commit -m "Automatic changelog compile, [ci skip]"
		if !ERRORLEVEL! == 0 (
			git push
		)
		REM an error here generally means there was nothing to commit.
	)
	cd ..
)

echo ##################################
echo ##################################
echo:
echo Updating done, compiling in 10 seconds. If you want to preform other actions (like test merge) You can close this now and do them.
echo:
del updating.lk >nul 2>nul

timeout 10

echo lock>updating.lk
call bin\findab.bat

call bin\copyfromgit.bat

if not defined PUSHCHANGELOGTOGIT (
	echo compiling change log
	cd gamecode\%AB%
	call python tools\ss13_genchangelog.py html/changelog.html html/changelogs
	cd ..\..
)

echo Compiling game.
call bin\build.bat
if %DM_EXIT% neq 0 (
	echo DM compile failed. Aborting.
	call python bot\nudge.py %UPDATE_LOG_CHANNEL% "DM compile failed Aborting update." >nul 2>nul
	del /F /Q updating.lk >nul 2>nul
	pause
	exit /b 1
)

del updating.lk >nul 2>nul
rmdir /q gamefolder
mklink /d gamefolder gamecode\%AB% >nul
call python bot\nudge.py %UPDATE_LOG_CHANNEL% "Update job finished. Update will take place next round." >nul 2>nul
echo Done. The update will automatically take place at round restart.
timeout 300