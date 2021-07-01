@echo off
rem Cheridan asked for this. - N3X
call "%~dp0\bootstrap\python" ss13_genchangelog.py ../html/changelog.html ../html/changelogs
pause
