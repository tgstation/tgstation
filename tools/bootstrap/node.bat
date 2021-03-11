@echo off
where node.exe >nul 2>nul
if %errorlevel% == 0 (
	echo | set /p printed_str="Using system-wide Node "
	call node.exe --version
	call node.exe %*
) else (
	call powershell.exe -NoLogo -ExecutionPolicy Bypass -File "%~dp0\node_.ps1" %*
)
