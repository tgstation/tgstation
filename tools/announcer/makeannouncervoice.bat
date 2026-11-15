@echo off
setlocal DisableDelayedExpansion
title Announcer voice filter applier
echo Announcer voice filter applier
echo.
if "%~1"=="" goto usage
rem Use the local Python setup if it is there. Otherwise use uv.
set "ANNOUNCER_PYTHON=%~dp0.venv\Scripts\python.exe"
if exist "%ANNOUNCER_PYTHON%" goto convert
set "ANNOUNCER_UV=%USERPROFILE%\.local\bin\uv.exe"
if exist "%ANNOUNCER_UV%" goto convert
where uv.exe >nul 2>nul
if errorlevel 1 goto missing
set "ANNOUNCER_UV=uv.exe"
:convert
if "%~1"=="" goto done
if exist "%ANNOUNCER_PYTHON%" goto local_python
"%ANNOUNCER_UV%" run --script "%~dp0makeannouncervoice.py" --drop "%~1"
goto next
:local_python
"%ANNOUNCER_PYTHON%" "%~dp0makeannouncervoice.py" --drop "%~1"
:next
echo.
shift
rem Do the same for the next file if more than one was dropped.
goto convert
:done
echo Finished. Check the announcer-output folder beside your original WAV.
goto finish
:usage
echo Drag one or more WAV files onto this file to apply the announcer voice filter.
echo Finished OGGs go in an announcer-output folder beside each WAV.
echo Originals are preserved. Repeat conversions receive numbered filenames.
goto finish
:missing
echo Could not find the local Python environment or uv.
echo Install uv or follow the environment setup in tools\announcer\README.md.
:finish
echo.
if not "%ANNOUNCER_NO_PAUSE%"=="1" pause
endlocal
