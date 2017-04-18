@echo off
@title Server Tools Installer.
set HOME = %USERPROFILE%
call config.bat

echo This will download the game code from git and install the all the files and folders and symbolic links needed to use the server tools in to the current directory.

echo This requires git be installed.

echo Once this is done, you can safely delete this file if you wish.

echo Ready?
pause

call bin/findgit.bat

echo Downloading repo....
git clone %REPO_URL% gitrepo
IF %ERRORLEVEL% NEQ 0 (
	echo git clone failed. aborting.
	pause
	goto ABORT
)
cd gitrepo
git checkout %REPO_BRANCH%
cd ..

echo Repo downloaded.
echo Setting up folders...
mkdir gamecode\a
mkdir gamecode\b
mkdir gamedata
mkdir bot

echo Copying things around....
echo (1/3)
xcopy gitrepo\data gamedata\data /Y /X /K /R /H /I /C /V /E /Q >nul
xcopy gitrepo\config gamedata\config /Y /X /K /R /H /I /C /V /E /Q >nul
xcopy gitrepo\bot bot /Y /X /K /R /H /I /C /V /E /Q >nul
copy gitrepo\libmysql.dll gamedata\libmysql.dll /D /V /Y >nul
echo (2/3)
xcopy gitrepo gamecode\a /Y /X /K /R /H /I /C /V /E /Q /EXCLUDE:copyexclude.txt >nul
mkdir gamecode\a\.git\logs\
copy gitrepo\.git\logs\HEAD gamecode\a\.git\logs\HEAD /D /V /Y >nul
echo (3/3)
xcopy gitrepo gamecode\b /Y /X /K /R /H /I /C /V /E /Q /EXCLUDE:copyexclude.txt >nul
mkdir gamecode\b\.git\logs >nul
copy gitrepo\.git\logs\HEAD gamecode\b\.git\logs\HEAD /D /V /Y >nul
echo done.

echo Setting up symbolic links.
mklink gamecode\a\nudge.py ..\..\bot\nudge.py
mklink gamecode\a\libmysql.dll ..\..\gamedata\libmysql.dll
mklink /d gamecode\a\data ..\..\gamedata\data
mklink /d gamecode\a\config ..\..\gamedata\config

mklink gamecode\b\nudge.py ..\..\bot\nudge.py
mklink gamecode\b\libmysql.dll ..\..\gamedata\libmysql.dll
mklink /d gamecode\b\data ..\..\gamedata\data
mklink /d gamecode\b\config ..\..\gamedata\config

mklink /d gamefolder gamecode\a

echo prepping python (if installed)
pip install PyYaml
pip install beautifulsoup4

echo Compiling for the first time.

echo Compiling change log.
cd gamefolder
call python tools\ss13_genchangelog.py html/changelog.html html/changelogs
cd ..
echo Compiling game.
call bin\build.bat
if %DM_EXIT% neq 0 echo DM compile failed.

echo Done. You may start the server using the start server program or change the game config in gamedata\config 
pause

:ABORT
