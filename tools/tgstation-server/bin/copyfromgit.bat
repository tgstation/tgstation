echo Removing old files
rem delete the symlinks manually to ensure their targets don't get recursively deleted
rmdir /q gamecode\%AB%\data >nul 2>nul
rmdir /q gamecode\%AB%\config >nul 2>nul
rmdir /q gamecode\%AB%\cfg >nul 2>nul
del /q gamecode\%AB%\nudge.py >nul 2>nul
del /q gamecode\%AB%\CORE_DATA.py >nul 2>nul

del /S /F /Q gamecode\%AB% >nul 2>nul

echo Copying files
xcopy gitrepo gamecode\%AB% /Y /X /K /R /H /I /C /V /E /Q /EXCLUDE:copyexclude.txt >nul
mkdir gamecode\%AB%\.git\logs
copy gitrepo\.git\logs\HEAD gamecode\%AB%\.git\logs\HEAD /D /V /Y >nul

mklink gamecode\%AB%\nudge.py ..\..\bot\nudge.py >nul
mklink gamecode\%AB%\CORE_DATA.py ..\..\bot\CORE_DATA.py >nul
rmdir /q gamecode\%AB%\data >nul 2>nul
rmdir /s /q gamecode\%AB%\data >nul 2>nul
mklink /d gamecode\%AB%\data ..\..\gamedata\data >nul
mklink /d gamecode\%AB%\config ..\..\gamedata\config >nul
mklink /d gamecode\%AB%\cfg ..\..\gamedata\cfg >nul