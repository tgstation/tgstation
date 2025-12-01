@echo off
REM If you hit github's rate limit, add a 3rd parameter here that is a github personal access token
CreditsTool.exe tgstation tgstation

del "%~dp0\..\..\config\contributors.dmi"
call "%~dp0\..\bootstrap\python" credits.py %*
rmdir /s /q credit_pngs
pause
