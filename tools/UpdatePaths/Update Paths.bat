@echo off

if "%~1"=="" (
	echo Running UpdatePaths with all scripts in the Scripts directory.
	echo This will take a while, and cannot be interrupted without data corruption.
	echo Make sure you commit all changes first!
	echo Are you sure you want to continue? ^(y / n^)
	set /p "continue="

	if /i "%continue%"=="y" (
		for /f "delims=" %%F in ('dir /b /on /a-d scripts\*_*.txt') do (
      		call "%~dp0\..\bootstrap\python" -m UpdatePaths "scripts\%%~nxF"
		)
	) else (
		echo usage: ^"Update Paths.bat^" [-h] [--map MAP] [--directory DIRECTORY] [--inline] [--verbose] script
	)
) else (
	call "%~dp0\..\bootstrap\python" -m UpdatePaths %*
)
