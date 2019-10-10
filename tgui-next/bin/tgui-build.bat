@echo off
cd "%~dp0\.."
if not exist node_modules call npm install
call npm run build
