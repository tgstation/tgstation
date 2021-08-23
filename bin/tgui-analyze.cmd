@echo off
call "%~dp0\..\tools\build\build.cmd" --wait-on-error tgui-analyze %*
