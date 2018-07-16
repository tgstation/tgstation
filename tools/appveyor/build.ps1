if(!(Test-Path -Path "C:/byond")){
    sh tools/appveyor/download_byond.sh
    [System.IO.Compression.ZipFile]::ExtractToDirectory("byond.zip", "C:/")
    Remove-Item byond.zip
}

Set-Location $env:APPVEYOR_BUILD_FOLDER

&"C:/byond/bin/dm.exe" -max_errors 0 tgstation.dme
exit $LASTEXITCODE