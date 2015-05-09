@echo off
call config.bat
call bin\getcurdate.bat
call bin\findgit.bat

REM the live update system works by swapping a symlink (gamefolder) between two folders (gamedata\a and gamedata\b). Because file locks and file handles in windows apply to the target of a symbolic link, and not the actual link, byond never stops seeing the old version of the code, until world reboot when it closes the link and reopens it. So we can just update, compile, and switch link location by deleting the old link and making the new one.


REM if the first arg to nudge.py is not a channel, it is treated as the "source"
if not defined UPDATE_LOG_CHANNEL set UPDATE_LOG_CHANNEL="UPDATER"


python bot\nudge.py %UPDATE_LOG_CHANNEL% "Update job started" >nul 2>nul

echo Updating repo
cd gitrepo
git branch backup-%CUR_DATE% >nul 2>nul
git reset --hard
git pull --force
if %ERRORLEVEL% neq 0 (
	echo git pull failed. Aborting update
	python bot\nudge.py %UPDATE_LOG_CHANNEL% "Git pull failed. Aborting update"
	pause
	exit /b 1
)
@for /f "usebackq" %i in (`git log "--format=%h" "--abbrev-commit" -1`) do set COMMITHASH=%~ni
cd ..
@del gamecode\a\updater.temp >nul 2>nul
@del gamecode\b\updater.temp >nul 2>nul

echo test >gamefolder\updater.temp
echo 1
if exist gamefolder\%PROJECTNAME%.rsc.lk (
	echo 2
	rem we attempt to delete the lock file to see if the server is currently running.
	del /q gamefolder\%PROJECTNAME%.rsc.lk >nul 2>nul
	if exist gamefolder\%PROJECTNAME%.rsc.lk set RUNNING=1
	
)
echo %ERRORLEVEL% %RUNNING% !
if exist gamecode\a\updater.temp (
	if defined RUNNING (
		set AB=b
	) else (
		set AB=a
	)
) else if exist gamecode\b\updater.temp (
		if defined RUNNING (
		set AB=a
	) else (
		set AB=b
	)
)

echo Copying to the %AB% folder

echo Removing old files
REM delete the symlinks manually to ensure their targets don't get recursively deleted
rmdir /q gamecode\%AB%\data >nul 2>nul
rmdir /q gamecode\%AB%\config >nul 2>nul
rmdir /q gamecode\%AB%\cfg >nul 2>nul
del /q gamecode\%AB%\nudge.py >nul 2>nul
del /q gamecode\%AB%\CORE_DATA >nul 2>nul

rmdir /S /q gamecode\%AB%

echo Copying files
xcopy gitrepo gamecode\%AB% /Y /X /K /R /H /I /C /V /E /Q /EXCLUDE:copyexclude.txt >nul

mklink gamecode\%AB%\nudge.py ..\..\bot\nudge.py >nul
mklink gamecode\%AB%\CORE_DATA.py ..\..\bot\CORE_DATA.py >nul
mklink /d gamecode\%AB%\data ..\..\gamedata\data >nul
mklink /d gamecode\%AB%\config ..\..\gamedata\config >nul
mklink /d gamecode\%AB%\cfg ..\..\gamedata\cfg >nul



echo compiling change log
cd gamecode\%AB%
call python tools\ss13_genchangelog.py html/changelog.html html/changelogs
cd ..\..
echo building script.
call bin\build.bat
if %DM_EXIT% neq 0 (
	echo DM compile failed. Aborting.
	python bot\nudge.py %UPDATE_LOG_CHANNEL% "DM compile failed. Aborting update." >nul 2>nul
	pause
	exit /b 1
)

if not defined NOWAITUPDATES (
	echo OK, compiled and ready. So at the hit of a button, we can apply the update live. Technically speaking, it's best to wait until near round end, but unless a html/css/js file in the code had been deleted, edited, or moved recently, no ill effects of applying the update will happen, and the worst is that new clients have display oddities relating to in game windows. Existing connections should have no issue.

	echo Ready?
	pause
)
echo Applying the update.

rmdir /q gamefolder
mklink /d gamefolder gamecode\%AB% >nul

echo done.
python bot\nudge.py %UPDATE_LOG_CHANNEL% "Update %COMMITHASH% applied and will take effect next round" >nul 2>nul
pause