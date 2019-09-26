@echo off
REM Get the documents folder from the registry.
@echo off
for /f "tokens=3*" %%p in ('REG QUERY "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v Personal') do (
    set DocumentsFolder=%%p
)
REM Copy to tmp subdirectories
FOR /D %%G in ("%DocumentsFolder%\BYOND\cache\tmp*") DO (cmd /c xcopy /E /I packages\tgui\public\bundles %%G\bundles /y)
