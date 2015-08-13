@echo off
REM check if git is already in path
git --version >nul 2>nul && goto :eof

REM now lets try our override.
set PATH=%PATH%;%GIT_LOCATION_PATH%
@git --version >nul 2>nul && goto :eof

REM credit to sschuberth@http://stackoverflow.com/questions/8507368/finding-the-path-where-git-is-installed-on-a-windows-system
REM Read the Git for Windows installation path from the Registry.

:REG_QUERY
for /f "skip=2 delims=: tokens=1*" %%a in ('reg query "HKLM\SOFTWARE%WOW%\Microsoft\Windows\CurrentVersion\Uninstall\Git_is1" /v InstallLocation 2^> nul') do (
    for /f "tokens=3" %%z in ("%%a") do (
        set GIT=%%z:%%b
    )
)
if "%GIT%"=="" (
    if "%WOW%"=="" (
        rem Attempt to find it on the 32bit register section
        set WOW=\Wow6432Node
        goto REG_QUERY
    )
)

set PATH=%GIT%bin;%PATH%

@git --version >nul 2>nul && goto :eof

echo Git not found. Aborting. If git is installed, set the GIT_LOCATION variable inside config.bat
timeout 60
exit 10