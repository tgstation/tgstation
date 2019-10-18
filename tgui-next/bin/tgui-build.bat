@echo off
cd "%~dp0\.."
call npm ci
call npm run build

timeout /t 30
