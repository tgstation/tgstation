@echo off
set /p objectName="Enter object name: "

mkdir "%objectName%"
mkdir "%objectName%\code"
mkdir "%objectName%\icons"

type nul > "%objectName%\code\%objectName%.dm"
type nul > "%objectName%\icons\%objectName%.dmi"

powershell -Command ^
    "$dmeFile = '_aesthetics.dme';" ^
    "$newInclude = '#include \"%objectName%/code/%objectName%.dm\"';" ^
    "$lines = Get-Content $dmeFile;" ^
    "$lines += $newInclude;" ^
    "$lines = $lines | Sort-Object;" ^
    "Set-Content $dmeFile $lines"
