@echo off
setlocal EnableDelayedExpansion
if "%~1"=="-tooltask" (
	goto run-updatepaths-all
)
if "%~1"=="" (
	:run-updatepaths-all
	echo Running UpdatePaths with all scripts in the Scripts directory.
	echo This will take a while, and cannot be interrupted without data corruption.
	echo Make sure you commit all changes first!

	:ask-to-continue
	set "continue="
	echo Are you sure you want to continue? ^(y / n^)
	set /p "continue="

	if "!continue!"=="" (
		goto ask-to-continue
	) else if /i "!continue!"=="y" (
		for /f "delims=" %%F in ('dir /b /on /a-d scripts\*_*.txt') do (
      		call "%~dp0\..\bootstrap\python" -m UpdatePaths "scripts\%%~nxF"
		)
	) else if /i "!continue!"=="n" (
		echo usage: ^"Update Paths.bat^" [-h] [--map MAP] [--directory DIRECTORY] [--inline] [--verbose] script_path
	) else (
		goto ask-to-continue
	)
	goto stop
) else (
	call "%~dp0\..\bootstrap\python" -m UpdatePaths %*
)

:stop
if "%~1"=="-tooltask" (
	goto eof
)
echo %CMDCMDLINE% | findstr /C:"/c">nul && pause

:eof
