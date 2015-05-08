@echo off

@dm.exe -h >nul 2>nul
IF %ERRORLEVEL% NEQ 9009 (
	goto :eof
)

set PATH=%PATH%;%BYOND_LOCATION_PATH%
@dm.exe -h >nul 2>nul
IF %ERRORLEVEL% NEQ 9009 (
	goto :eof
)

@"c:\Program Files (x86)\BYOND\bin\dm.exe" -h >nul 2>nul
IF %ERRORLEVEL% NEQ 9009 (
	set "PATH=%PATH%;c:\Program Files (x86)\BYOND\bin\"
	goto :eof
)
@"c:\Program Files\BYOND\bin\dm.exe" -h >nul 2>nul
IF %ERRORLEVEL% NEQ 9009 (
	set "PATH=%PATH%;c:\Program Files\BYOND\bin\"
	goto :eof
)

echo byond not found. Aborting. If byond is installed, set the GIT_LOCATION variable inside config.bat
pause
exit 11