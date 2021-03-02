@echo off
where node.exe >nul 2>nul
if %errorlevel% == 0 (
	echo | set /p printed_str="Using system-wide Node "
	call node.exe --version
	call node.exe %*
	exit /b %errorlevel%
)
call powershell -NoLogo -ExecutionPolicy Bypass -File "%~dp0\node_.ps1" Download-Node
for /f "tokens=* USEBACKQ" %%s in (`
	call powershell -NoLogo -ExecutionPolicy Bypass -File "%~dp0\node_.ps1" Get-Path
`) do (
	set "PATH=%%s;%PATH%"
)
where node.exe >nul 2>nul
if %errorlevel% == 0 (
	echo | set /p printed_str="Using vendored Node "
	call node.exe --version
	call node.exe %*
	exit /b %errorlevel%
)
echo "build.bat: Failed to bootstrap Node!"
exit /b 1
