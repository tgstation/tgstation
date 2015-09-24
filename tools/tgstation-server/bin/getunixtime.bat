@echo off
for /f "delims=" %%x in ('cscript /nologo unixtime.vbs') do set UNIXTIME=%%x