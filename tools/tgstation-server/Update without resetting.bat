@echo off
@title Server Updater
SETLOCAL ENABLEDELAYEDEXPANSION
set HOME = %USERPROFILE%

call config.bat
call bin\getcurdate.bat
call bin\findgit.bat

echo This will update the server without resetting local changes like test merges.
echo Note: This doesn't update the changelog like a normal update does.
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

call python bot\nudge.py %UPDATE_LOG_CHANNEL% "Update job started (No reset mode)" >nul 2>nul

cd gitrepo
git fetch origin
if %ERRORLEVEL% neq 0 (
	cd ..
	echo git fetch failed. Aborting update.
	call python bot\nudge.py %UPDATE_LOG_CHANNEL% "Git fetch failed. Aborting update"
	del updating.lk >nul 2>nul
	pause
	exit /b 1
)
git merge origin/%REPO_BRANCH%
if %ERRORLEVEL% neq 0 (
	cd ..
	echo git merge of upstream master failed, aborting update.
	call python bot\nudge.py %UPDATE_LOG_CHANNEL% "git merge of upstream master failed, aborting update." >nul 2>nul
	cd gitrepo
	git merge --abort
	if %ERRORLEVEL% neq 0 (
		echo ERROR: Error aborting update, resetting repo.
		cd ..
		call python bot\nudge.py %UPDATE_LOG_CHANNEL% "Error aborting merge, Resetting git repo" >nul 2>nul
		cd gitrepo
		git reset --hard
		git clean -fd
		<nul set /p TRIM="set PR=" > bin/activepr.bat
		del /F /Q prtestjob.lk >nul 2>nul
		echo NOTICE: We had to reset the repo's state, all active test merges were undone.
	)
	cd ..
	del updating.lk >nul 2>nul
	pause
	exit /b 1
)
cd ..


echo ##################################
echo ##################################
echo:
echo In place update done, compiling in 10 seconds. If you want to preform other actions (like more test merges) You can close this now and do them.
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
