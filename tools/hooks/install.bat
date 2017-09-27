@echo off
cd %~dp0
for %%f in (*.hook) do (
	echo Installing %%~nf
	copy %%f ..\..\.git\hooks\%%~nf >nul
)
echo Done
pause
