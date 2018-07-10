
if(!(Test-Path -Path "C:/byond")){
    wget http://www.byond.com/download/build/512/512.1427_byond.zip -O C:\byond.zip
    [System.IO.Compression.ZipFile]::ExtractToDirectory("C:/byond.zip", "C:/")
    rm C:\byond.zip
}

cd $env:APPVEYOR_BUILD_FOLDER

&"C:/byond/bin/dm.exe" -max_errors 0 tgstation.dme
exit $LASTEXITCODE