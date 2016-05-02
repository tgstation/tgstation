@echo off
REM Get the documents folder from the registry.
for /f "tokens=3* delims= " %%a in (
    'reg query "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v "Personal"'
) do (
    set documents=%%a
)
REM Copy assets to the BYOND cache
cmd /c copy assets\* "%documents%\BYOND\cache" /y
