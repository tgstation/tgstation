@echo off
call config.bat
call bin\getcurdate.bat
call bin\findgit.bat

rem if the first arg to nudge.py is not a channel, it is treated as the "source"
if not defined UPDATE_LOG_CHANNEL set UPDATE_LOG_CHANNEL="UPDATER"

cd bot
python nudge.py %UPDATE_LOG_CHANNEL% "Update job started" >nul 2>nul
cd ..
echo Updating repo
cd gitrepo
git branch backup-%CUR_DATE% >nul 2>nul
git reset --hard
git pull --force
if %ERRORLEVEL% neq 0 (
	echo git pull failed. Aborting update
	python nudge.py %UPDATE_LOG_CHANNEL% "Git pull failed. Aborting update"
	pause
	exit /b 1
)
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
rem delete the symlinks manually to ensure their targets don't get recursively deleted
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
	python nudge.py %UPDATE_LOG_CHANNEL% "DM compile failed Aborting update." >nul 2>nul
	pause
	exit /b 1
)

echo ok, compilled and ready. so at the hit of a button, we can apply the update live. its best to wait until near round end, but unless a html/css/js file in the code had been deleted, edited, 0r moved recently, no ill effects of this will happen. and the worst is that new clients have display oddites, existing connections should have no issue.

echo Ready?
pause 

rmdir /q gamefolder
mklink /d gamefolder gamecode\%AB% >nul

echo done.
pause