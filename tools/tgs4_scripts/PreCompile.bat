@echo off
set TG_BOOTSTRAP_CACHE=%cd%
cd %1
set TG_BUILD_TGS_MODE=1
tools\build\build
