@echo off
set /p moduleName="Enter module name: "
set "moduleName=%moduleName: =_%"

xcopy "example" "%moduleName%" /s /i

ren "%moduleName%\_example.dm" "_%moduleName%.dm"
ren "%moduleName%\_example.dme" "_%moduleName%.dme"
ren "%moduleName%\code\example.dm" "%moduleName%.dm"

mkdir "%moduleName%\icons"

Powershell -Command "(Get-Content '%moduleName%\_%moduleName%.dm') -replace 'Example modpack', '%moduleName%' | Set-Content '%moduleName%\_%moduleName%.dm'"
Powershell -Command "(Get-Content '%moduleName%\_%moduleName%.dm') -replace 'example', '%moduleName%' | Set-Content '%moduleName%\_%moduleName%.dm'"
Powershell -Command "(Get-Content '%moduleName%\_%moduleName%.dme') -replace 'Example modpack', '%moduleName%' | Set-Content '%moduleName%\_%moduleName%.dme'"
Powershell -Command "(Get-Content '%moduleName%\_%moduleName%.dme') -replace 'example', '%moduleName%' | Set-Content '%moduleName%\_%moduleName%.dme'"
Powershell -Command "(Get-Content '%moduleName%\_%moduleName%.dm') -replace 'furior', '%USERNAME%' | Set-Content '%moduleName%\_%moduleName%.dm'"

Powershell -Command ^
    "$dmeFile = 'modular_bandastation.dme';" ^
    "$newInclude = '#include \"%moduleName%/_%moduleName%.dme\"';" ^
    "$lines = Get-Content $dmeFile;" ^
    "$startIndex = $lines.IndexOf('// --- MODULES START --- //') + 1;" ^
    "$endIndex = $lines.IndexOf('// --- MODULES END --- //');" ^
    "if ($startIndex -eq -1 -or $endIndex -eq -1) { Write-Host 'Error: Comments not found'; exit 1 }" ^
    "$before = $lines[0..($startIndex - 1)];" ^
    "$moduleLines = $lines[$startIndex..($endIndex - 1)] + $newInclude | Sort-Object;" ^
    "$after = $lines[($endIndex)..($lines.Length - 1)];" ^
    "Set-Content $dmeFile -Value ($before + $moduleLines + $after)"
