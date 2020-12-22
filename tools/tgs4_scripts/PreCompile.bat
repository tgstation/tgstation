@echo off
set TG_BOOTSTRAP_CACHE=%cd%
IF NOT "%1" == "" (
	rem TGS4: we are passed the game directory on the command line
	cd %1
) ELSE IF EXIST "..\Game\A\tgstation.dmb" (
	rem TGS3: Game/A/tgstation.dmb exists, so build in Game/B
	cd ..\Game\B
) ELSE (
	rem TGS3: Otherwise build in Game/A
	cd ..\Game\A
)
set TG_BUILD_TGS_MODE=1
tools\build\build
