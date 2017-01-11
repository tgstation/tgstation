@echo off
set DME_FOLDER=gamefolder\
if defined AB set DME_FOLDER=gamecode\%AB%\

call %DME_FOLDER%\tgui\install_dependancies_noprune.bat
set TGUI_EXIT=%ERRORLEVEL%
if %TGUI_EXIT% neq 0 (
	exit /b 1
)

call %DME_FOLDER%\tgui\build.bat
set TGUI_EXIT=%ERRORLEVEL%