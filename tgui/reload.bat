@echo off
REM Get the documents folder from the registry.
@echo off
for /f "tokens=3*" %%p in ('REG QUERY "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v Personal') do (
    set DocumentsFolder=%%p
)
REM Copy assets to the BYOND cache
cmd /c copy assets\* "%DocumentsFolder%\BYOND\cache" /y
REM Copy to tmp subdirectories
FOR /D %%G in ("%DocumentsFolder%\BYOND\cache\tmp*") DO (cmd /c copy assets\* %%G /y)