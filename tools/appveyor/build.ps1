wget http://www.byond.com/download/build/512/512.1427_byond.zip -O byond.zip
[System.IO.Compression.ZipFile]::ExtractToDirectory("byond.zip", "C:/")

&"C:/byond/bin/dm.exe" -max_errors 0 tgstation.dme
exit $LASTEXITCODE