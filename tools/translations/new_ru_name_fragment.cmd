@echo off
call powershell.exe -NoLogo -ExecutionPolicy Bypass -File "%~dp0new_ru_name_fragment.ps1" %*
exit /b %ERRORLEVEL%
