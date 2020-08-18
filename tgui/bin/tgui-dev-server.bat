@echo off
cd "%~dp0\.."
call yarn install
call yarn run watch
if %0 == "%~0" pause
