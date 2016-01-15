@echo off
REM This assumes you have NPM installed
if not exist generated mkdir generated
del /S /Q generated\*.*
for /D %%i in (src\*.*) do xcopy /S /Y "%%i\*.*" "generated\*.*"
if not exist generated\images mkdir generated\images
for /D %%i in (images\*.*) do xcopy /S /Y "%%i\*.*" "generated\images\*.*"
cmd /c gulp --min
pause