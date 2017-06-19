call config.bat
call bin/findbyond.bat
set DME_FOLDER=gamefolder\
if defined AB set DME_FOLDER=gamecode\%AB%\

set DME_LOCATION=%DME_FOLDER%%PROJECTNAME%.dme
set MDME_LOCATION=%DME_FOLDER%%PROJECTNAME%.mdme

@del %MDME_LOCATION% >nul 2>nul
if defined MAPROTATE set MAPFILE=%MAPROTATE%
if not defined MAPFILE goto BUILD

echo #define MAP_OVERRIDE >>%MDME_LOCATION%
echo #include "_maps\%MAPFILE%.dm" >>%MDME_LOCATION%

:BUILD
echo #define SERVERTOOLS 1 >>%MDME_LOCATION%
echo #define PUTONHUB 1 >>%MDME_LOCATION%
type %DME_LOCATION% >>%MDME_LOCATION%

dm -clean %MDME_LOCATION%
set DM_EXIT=%ERRORLEVEL%
@del %DME_FOLDER%%PROJECTNAME%.dmb >nul 2>nul
@del %DME_FOLDER%%PROJECTNAME%.rsc >nul 2>nul
@move %DME_FOLDER%%PROJECTNAME%.mdme.dmb %DME_FOLDER%%PROJECTNAME%.dmb  >nul 2>nul
@move %DME_FOLDER%%PROJECTNAME%.mdme.rsc %DME_FOLDER%%PROJECTNAME%.rsc >nul 2>nul
