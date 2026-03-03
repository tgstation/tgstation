@echo off

:: Call pwsh if available
set "powershellCmd=powershell"
where pwsh >nul 2>nul
if %errorlevel%==0 (
    set "powershellCmd=pwsh"
)

call %powershellCmd% -NoLogo -ExecutionPolicy Bypass -File "%~dp0\javascript_.ps1" Download-Bun
for /f "tokens=* USEBACKQ" %%s in (`
    call %powershellCmd% -NoLogo -ExecutionPolicy Bypass -File "%~dp0\javascript_.ps1" Get-Path
`) do (
    set "PATH=%%s;%PATH%"
)
where bun.exe >nul 2>nul
if %errorlevel% == 0 (
    echo | set /p printed_str="Using vendored Bun "
    call bun.exe --version
    call bun.exe %*
    goto exit_with_last_error_level
)
echo "javascript.bat: Failed to bootstrap Bun!"
%COMSPEC% /c exit 1

:exit_with_last_error_level
if not %errorlevel% == 0 %COMSPEC% /c exit %errorlevel% >nul
