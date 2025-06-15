## bootstrap/bun_.ps1
## Downloads a Bun version to a cache directory and invokes it.

$ErrorActionPreference = "Stop"

function Get-VariableFromFile {
    param([string] $Path, [string] $Key)
    foreach ($Line in Get-Content $Path) {
        if ($Line.StartsWith("export $Key=")) {
            return $Line.Substring(("export $Key=").Length)
        }
    }
    throw "Couldn't find value for $Key in $Path"
}

function Get-Bun {
    if (Test-Path $BunTarget -PathType Leaf) {
        # Bun already exists
        return
    }

    Write-Output "Downloading Bun v$BunVersion (may take a while)"
    New-Item $BunTargetDir -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
    $WebClient = New-Object Net.WebClient
    $WebClient.DownloadFile($BunSource, "$BunZip.downloading")
    Rename-Item "$BunZip.downloading" $BunZip
    Test-BunHash

    Write-Output "Extracting Bun archive"
    Expand-Archive -Path $BunZip -DestinationPath $BunTargetDir -Force

    # Move the exe out of the subdirectory
    if (Test-Path "$BunTargetDir\$BunPlatform\bun.exe") {
        Move-Item "$BunTargetDir\$BunPlatform\bun.exe" $BunTargetDir -Force
    }
    else {
        Write-Output "Failed to find bun.exe in the extracted directory."
        exit 1
    }

    Remove-Item $BunZip -Force
    Remove-Item "$BunTargetDir\$BunPlatform" -Recurse -Force
}

function Test-BunHash {
    $Tries = $Tries + 1

    Write-Output "Verifying Bun checksum"
    $FileHash = Get-FileHash $BunZip -Algorithm SHA256
    $ActualSha = $FileHash.Hash
    $LoginResponse = Invoke-WebRequest "https://github.com/oven-sh/bun/releases/download/bun-v$BunVersion/SHASUMS256.txt"
    $ContentString = [System.Text.Encoding]::UTF8.GetString($LoginResponse.Content)
    $ShaArray = $ContentString -split "`n"
    foreach ($ShaArrayEntry in $ShaArray) {
        $EntrySplit = $ShaArrayEntry -split "\s+"
        $EntrySha = $EntrySplit[0]
        $EntryFile = $EntrySplit[1]
        if ($EntryFile -eq "bun-windows-x64.zip") {
            $ExpectedSha = $EntrySha
            break
        }
    }

    if ($null -eq $ExpectedSha) {
        Write-Output "Failed to determine the correct checksum value. This is probably fine."
        return
    }

    if ($ExpectedSha -ne $ActualSha) {
        Write-Output "$ExpectedSha != $ActualSha"
        if ($Tries -gt 3) {
            Write-Output "Failed to verify Bun checksum three times. Aborting."
            exit 1
        }
        Write-Output "Checksum mismatch on Bun. Retrying."
        Remove-Item $BunTarget
        Get-Bun
    }
}

## Convenience variables
$BaseDir = Split-Path $script:MyInvocation.MyCommand.Path
$Cache = "$BaseDir\.cache"
if ($Env:TG_BOOTSTRAP_CACHE) {
    $Cache = $Env:TG_BOOTSTRAP_CACHE
}

$BunVersion = Get-VariableFromFile -Path "$BaseDir\..\..\dependencies.sh" -Key "BUN_VERSION"
$BunPlatform = "bun-windows-x64"
$BunSource = "https://github.com/oven-sh/bun/releases/download/bun-v$BunVersion/$BunPlatform.zip"
$BunTargetDir = "$Cache\bun-v$BunVersion-x64"
$BunTarget = "$BunTargetDir\bun.exe"
$BunZip = "$BunTargetDir\bun.zip"

## Just print the path and exit
if ($Args.length -eq 1 -and $Args[0] -eq "Get-Path") {
    Write-Output "$BunTargetDir"
    exit 0
}

## Just download bun and exit
if ($Args.length -eq 1 -and $Args[0] -eq "Download-Bun") {
    Get-Bun
    exit 0
}

## Download bun
Get-Bun

## Set PATH so that recursive calls find it
$Env:PATH = "$BunTargetDir;$ENV:Path"

## Invoke Bun with all command-line arguments
$ErrorActionPreference = "Continue"
& "$BunTarget" @Args
exit $LastExitCode
