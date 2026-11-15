@echo off
setlocal DisableDelayedExpansion
title Crystal announcer converter
echo Crystal announcer converter
echo.
if "%~1"=="" goto usage
set "CRYSTAL_PYTHON=%~dp0.venv\Scripts\python.exe"
if exist "%CRYSTAL_PYTHON%" goto convert
set "CRYSTAL_UV=%USERPROFILE%\.local\bin\uv.exe"
if exist "%CRYSTAL_UV%" goto convert
where uv.exe >nul 2>nul
if errorlevel 1 goto missing
set "CRYSTAL_UV=uv.exe"
:convert
if "%~1"=="" goto done
if exist "%CRYSTAL_PYTHON%" goto local_python
"%CRYSTAL_UV%" run --script "%~dp0makeannouncervoice.py" --drop "%~1"
goto next
:local_python
"%CRYSTAL_PYTHON%" "%~dp0makeannouncervoice.py" --drop "%~1"
:next
echo.
shift
goto convert
:done
echo Finished. Check the announcer-output folder beside your original WAV.
goto finish
:usage
echo Drag one or more original Crystal WAV files onto this file.
echo Finished OGGs go in an announcer-output folder beside each WAV.
echo Originals are preserved. Repeat conversions receive numbered filenames.
goto finish
:missing
echo Could not find the local Python environment or uv.
echo Install uv or follow the environment setup in tools\announcer\README.md.
:finish
echo.
if not "%CRYSTAL_NO_PAUSE%"=="1" pause
endlocal
