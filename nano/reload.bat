@echo off

for /f "tokens=3* delims= " %%a in (
    'reg query "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v "Personal"'
) do (
    set documents=%%a
)

copy assets\* "%documents%\BYOND\cache" /y
