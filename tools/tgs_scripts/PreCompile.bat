@echo off
cd /D "%~dp0"
set TG_BOOTSTRAP_CACHE=%cd%
cd %1
set CBT_BUILD_MODE=TGS
tools\build\build
