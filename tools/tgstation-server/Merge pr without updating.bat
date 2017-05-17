@echo off
@title Server Updater
SETLOCAL ENABLEDELAYEDEXPANSION
set HOME = %USERPROFILE%

call config.bat
rem if the first arg to nudge.py is not a channel, it is treated as the "source"
if not defined UPDATE_LOG_CHANNEL set UPDATE_LOG_CHANNEL="UPDATER"
call bin\getcurdate.bat
call bin\findgit.bat
echo This will handle merging a pr locally, compiling the server, and applying the PR test job.

:PROMPT
SET /P UserInput=Please enter the pr number (without a # or anything of the sorts):
SET /A PR=UserInput

if %PR% EQU %UserInput% (
    if %PR% GTR 0 ( 
		echo updating to pr %PR%
	) else (
		echo Bad input
		goto PROMPT
	)
) else (
	echo Bad input
	goto PROMPT
)
if exist updating.lk (
	echo ERROR: A current update script has been detected running. if you know this is a mistake:
	pause
	echo Please be double sure that an update script is not currently running, if you think one might be, close this window. otherwise:
	pause
)

echo lock>updating.lk

call python bot\nudge.py %UPDATE_LOG_CHANNEL% "PR test job started. Merging PR #%PR% locally" >nul 2>nul


cd gitrepo
git fetch -f origin pull/%PR%/head:pr-%PR%
if %ERRORLEVEL% neq 0 (
	cd ..
	echo git fetch failed. Aborting test merge.
	call python bot\nudge.py %UPDATE_LOG_CHANNEL% "Git fetch failed. Aborting test merge"
	del updating.lk >nul 2>nul
	pause
	exit /b 1
)
git merge pr-%PR%
if %ERRORLEVEL% neq 0 (
	cd ..
	echo git merge of PR #%PR% failed. Aborting test merge
	call python bot\nudge.py %UPDATE_LOG_CHANNEL% "git merge of PR #%PR% failed. Aborting PR test merge" >nul 2>nul
	cd gitrepo
	git merge --abort
	if !ERRORLEVEL! neq 0 (
		echo ERROR: Error aborting test merge, resetting repo.
		cd ..
		call python bot\nudge.py %UPDATE_LOG_CHANNEL% "Error aborting test merge, resetting git repo to head" >nul 2>nul
		cd gitrepo
		git reset --hard
		git clean -fd
		<nul set /p TRIM="set PR=" > bin/activepr.bat
		del /F /Q prtestjob.lk >nul 2>nul
		echo NOTICE: We had to reset the repo's state, all other active test merges were undone.
	)
	cd ..
	del updating.lk >nul 2>nul
	pause
	exit /b 1
)
cd ..

echo %PR%>>prtestjob.lk
<nul set /p TRIM=%PR% >> bin/activepr.bat

echo ##################################
echo ##################################
echo:
echo Test merging pr done, compiling in 10 seconds. If you want to preform other actions (like more test merges) You can close this now and do them.
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
	call python bot\nudge.py %UPDATE_LOG_CHANNEL% "DM compile failed. Aborting test merge." >nul 2>nul
	del /F /Q updating.lk >nul 2>nul
	pause
	exit /b 1
)

del updating.lk >nul 2>nul
rmdir /q gamefolder
mklink /d gamefolder gamecode\%AB% >nul
call python bot\nudge.py %UPDATE_LOG_CHANNEL% "Test merge job finished. Test merge will take place next round." >nul 2>nul
echo Done. The test merge will automatically take place at round restart.
timeout 300
