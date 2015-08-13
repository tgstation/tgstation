@echo off
@title Server Updater
set HOME = %USERPROFILE%
call config.bat
call bin\getcurdate.bat
call bin\findgit.bat
echo This will handle downloading git, compiling the server, and applying the update.
echo ready?
timeout 120
rem if the first arg to nudge.py is not a channel, it is treated as the "source"
if not defined UPDATE_LOG_CHANNEL set UPDATE_LOG_CHANNEL="UPDATER"

cd bot
python nudge.py %UPDATE_LOG_CHANNEL% "Update job started" >nul 2>nul
cd ..
echo Updating repo
cd gitrepo
git branch backup-%CUR_DATE% >nul 2>nul
git fetch
git checkout %REPO_BRANCH%
git reset origin/%REPO_BRANCH% --hard
git pull --force
if %ERRORLEVEL% neq 0 (
	echo git pull failed. Aborting update
	python bot\nudge.py %UPDATE_LOG_CHANNEL% "Git pull failed. Aborting update"
	pause
	exit /b 1
)

if defined PUSHCHANGELOGTOGIT (
	echo compiling change log
	python tools\ss13_genchangelog.py html/changelog.html html/changelogs
	if %ERRORLEVEL% == 0 (
		echo pushing compiled changelog to server
		git add -u html/changelog.html
		git add -u html/changelogs
		git commit -m "Automatic changelog compile"
		REM an error here generally means there was nothing to commit.
		if %ERRORLEVEL% == 0 (
			git push
		)
	)
)

cd ..
@del gamecode\a\updater.temp >nul 2>nul
@del gamecode\b\updater.temp >nul 2>nul

echo test >gamefolder\updater.temp

if exist gamefolder\%PROJECTNAME%.rsc.lk (
	rem we attempt to delete the lock file to see if the server is currently running.
	del /q gamefolder\%PROJECTNAME%.rsc.lk >nul 2>nul
	if exist gamefolder\%PROJECTNAME%.rsc.lk set RUNNING=1
)

if exist gamecode\a\updater.temp (
	if defined RUNNING (
		echo Current folder detected to be the "A" folder. Game is currently running. Updating to the "B" folder.
		set AB=b
	) else (
		echo Current folder detected to be the "A" folder. Game is not currently running, Updating to the "A" folder.
		set AB=a
	)
) else if exist gamecode\b\updater.temp (
	if defined RUNNING (
		echo Current folder detected to be the "B" folder. Game is currently running, Updating to the "A" folder.
		set AB=a
	) else (
		echo Current folder detected to be the "B" folder. Game is not currently running, Updating to the "B" folder.
		set AB=b
	)
)

echo Removing old files
rem delete the symlinks manually to ensure their targets don't get recursively deleted
rmdir /q gamecode\%AB%\data >nul 2>nul
rmdir /q gamecode\%AB%\config >nul 2>nul
rmdir /q gamecode\%AB%\cfg >nul 2>nul
del /q gamecode\%AB%\nudge.py >nul 2>nul
del /q gamecode\%AB%\CORE_DATA >nul 2>nul

rmdir /S /q gamecode\%AB%

echo Copying files
xcopy gitrepo gamecode\%AB% /Y /X /K /R /H /I /C /V /E /Q /EXCLUDE:copyexclude.txt >nul
mkdir gamecode\%AB%\.git\logs
copy gitrepo\.git\logs\HEAD gamecode\%AB%\.git\logs\HEAD /D /V /Y >nul

mklink gamecode\%AB%\nudge.py ..\..\bot\nudge.py >nul
mklink gamecode\%AB%\CORE_DATA.py ..\..\bot\CORE_DATA.py >nul
rmdir /q gamecode\%AB%\data >nul 2>nul
rmdir /s /q gamecode\%AB%\data >nul 2>nul
mklink /d gamecode\%AB%\data ..\..\gamedata\data >nul
mklink /d gamecode\%AB%\config ..\..\gamedata\config >nul
mklink /d gamecode\%AB%\cfg ..\..\gamedata\cfg >nul


if not defined PUSHCHANGELOGTOGIT (
	echo compiling change log
	cd gamecode\%AB%
	call python tools\ss13_genchangelog.py html/changelog.html html/changelogs
	cd ..\..
)
echo building script.
call bin\build.bat
if %DM_EXIT% neq 0 (
	echo DM compile failed. Aborting.
	python bot\nudge.py %UPDATE_LOG_CHANNEL% "DM compile failed Aborting update." >nul 2>nul
	@del gamefolder\updater.temp >nul 2>nul
	pause
	exit /b 1
)

if not defined NOWAITUPDATES (
	echo OK, compiled and ready. So at the hit of a button, we can apply the update live. Technically speaking, it's best to wait until near round end, but unless a html/css/js file in the code had been deleted, edited, or moved recently, no ill effects of applying the update will happen, and the worst is that new clients have display oddities relating to in game windows. Existing connections should have no issue.
	echo Ready?
	pause
)
@del gamefolder\updater.temp >nul 2>nul
rmdir /q gamefolder
mklink /d gamefolder gamecode\%AB% >nul
python bot\nudge.py %UPDATE_LOG_CHANNEL% "Update job finished. Update will take place next round." >nul 2>nul
echo Done. The update will automatically take place at round restart.
timeout 300