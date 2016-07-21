@echo off
@title Server Updater
set HOME = %USERPROFILE%
call config.bat
call bin\getcurdate.bat
echo This will handle downloading git, compiling the server, and applying the update.
echo ready?
timeout 120
if exist updating.lk (
	echo ERROR! A current update script has been detected running. if you know this is a mistake:
	pause
	echo Please be double sure that an update script is not currently running, if you think one might be, close this window. otherwise:
	pause
)
if exist rotating.lk (
	echo ERROR! A current map rotation operation has been detected running. IT IS STRONGLY RECOMMENDED YOU DO NOT UPDATE RIGHT NOW. if you know this is a mistake, and that the game server is not currently rotating the map:
	pause
	echo IT IS STRONGLY RECOMMENDED YOU DO NOT UPDATE RIGHT NOW. If a map rotation script runs at the same time as an update script the server will generally break in ways not trivial to recover from. Are you REALLY sure? Please close this window if you are not, otherwise:
	pause
)
@del /F /Q rotating.lk >nul 2>nul
echo lock>updating.lk

rem if the first arg to nudge.py is not a channel, it is treated as the "source"
if not defined UPDATE_LOG_CHANNEL set UPDATE_LOG_CHANNEL="UPDATER"

python bot\nudge.py %UPDATE_LOG_CHANNEL% "Update job started" >nul 2>nul

call bin\updategit.bat
if %GIT_EXIT% neq 0 (
	echo git pull failed. Aborting update
	python bot\nudge.py %UPDATE_LOG_CHANNEL% "Git pull failed. Aborting update"
	@del updating.lk >nul 2>nul
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
		git commit -m "Automatic changelog compile, [ci skip]"
		if %ERRORLEVEL% == 0 (
			git push
		)
		REM an error here generally means there was nothing to commit.
	)
)

call bin\findab.bat

call bin\copyfromgit.bat



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
	@del /F /Q updating.lk >nul 2>nul
	pause
	exit /b 1
)

if not defined NOWAITUPDATES (
	echo OK, compiled and ready. So at the hit of a button, we can apply the update live. Technically speaking, it's best to wait until near round end, but unless a html/css/js file in the code had been deleted, edited, or moved recently, no ill effects of applying the update will happen, and the worst is that new clients have display oddities relating to in game windows. Existing connections should have no issue.
	echo Ready?
	pause
)
@del updating.lk >nul 2>nul
rmdir /q gamefolder
mklink /d gamefolder gamecode\%AB% >nul
python bot\nudge.py %UPDATE_LOG_CHANNEL% "Update job finished. Update will take place next round." >nul 2>nul
echo Done. The update will automatically take place at round restart.
timeout 300