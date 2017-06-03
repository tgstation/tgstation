$src = $Env:APPVEYOR_BUILD_FOLDER + "\TGServiceInstaller\bin\Release"
$destination = $Env:APPVEYOR_BUILD_FOLDER + "\TGS3.zip"

 If(Test-path $destination) {Remove-item $destination}

Add-Type -assembly "system.io.compression.filesystem"

[io.compression.zipfile]::CreateFromDirectory($src, $destination) 

$destination_md5sha = $Env:APPVEYOR_BUILD_FOLDER + "\MD5-SHA1.txt"

& fciv -both $destination > $destination_md5sha
