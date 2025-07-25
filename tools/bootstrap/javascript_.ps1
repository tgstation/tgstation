## bootstrap/bun_.ps1
## Downloads a Bun version to a cache directory and invokes it.

$ErrorActionPreference = "Stop"

# Check minimum PowerShell version and required cmdlets
if ($PSVersionTable.PSVersion.Major -lt 5 -or $PSVersionTable.PSVersion.Minor -lt 1) {
    Write-Error "This script requires PowerShell 5.1 or newer. Your version: $($PSVersionTable.PSVersion)"
    exit 1
}

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
    if (Test-Path $BunExe -PathType Leaf) {
        # Bun already exists
        return
    }

    # Test AVX2 support. Bun builds for this
    # https://bun.sh/docs/installation#cpu-requirements-and-baseline-builds
    Get-CoreInfo
    Write-Output "Checking CPU for AVX2 support"
    $avx2Supported = (& $CoreInfoExe -accepteula -f | Select-String "AVX2\s+\*") -ne $null
    $BunRelease= "$BunPlatform"
    $BunTag
    if (-not $avx2Supported) {
        $BunRelease = "$BunPlatform-baseline"
        $BunTag = " (baseline)"
    }

    if (Test-Path $BunTargetDir -PathType Container) {
        Write-Output "Bun target directory exists but bun.exe is missing. Re-downloading."
        Remove-Item $BunTargetDir -Recurse -Force
    }

    $BunSource = "https://github.com/oven-sh/bun/releases/download/bun-v$BunVersion/$BunRelease.zip"

    Write-Output "Downloading Bun v$BunVersion$BunTag"
    New-Item $BunTargetDir -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
    try {
        Invoke-WebRequest -Uri $BunSource -OutFile "$BunZip.downloading" -UseBasicParsing
    } catch {
        Write-Error "Failed to download Bun from $BunSource. $_"
        exit 1
    }
    Rename-Item "$BunZip.downloading" $BunZip
    Test-BunHash -Baseline (-not $avx2Supported)

    Write-Output "Extracting Bun archive"
    Expand-Archive -Path $BunZip -DestinationPath $BunTargetDir -Force

    # Move the exe out of the subdirectory
    if (Test-Path "$BunTargetDir\$BunRelease\bun.exe") {
        Move-Item "$BunTargetDir\$BunRelease\bun.exe" $BunTargetDir -Force
    }
    else {
        Write-Output "Failed to find bun.exe in the extracted directory."
        exit 1
    }

    Remove-Item $BunZip -Force
    Remove-Item "$BunTargetDir\$BunRelease" -Recurse -Force
}

# For CPU detection (Bun needs avx2 instructions)
function Get-CoreInfo {
    $CoreInfoUrl = "https://download.sysinternals.com/files/Coreinfo.zip"
    $CoreInfoCacheDir = "$Cache\coreinfo"
    $CoreInfoZip = "$CoreInfoCacheDir\Coreinfo.zip"

    if (Test-Path $CoreInfoExe -PathType Leaf) {
        return
    }

    Write-Output "Downloading Coreinfo from Microsoft Sysinternals"
    New-Item $CoreInfoCacheDir -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
    try {
        Invoke-WebRequest -Uri $CoreInfoUrl -OutFile $CoreInfoZip -UseBasicParsing
    } catch {
        Write-Error "Failed to download Coreinfo. $_"
        exit 1
    }

    Expand-Archive -Path $CoreInfoZip -DestinationPath $CoreInfoCacheDir -Force
    Remove-Item $CoreInfoZip -Force

}

function Test-BunHash {
    param(
        [bool]$Baseline = $false
    )
    $Tries = $Tries + 1
    $BunRelease = $BunPlatform
    if ($Baseline) {
        $BunRelease = "$BunPlatform-baseline"
    }

    Write-Output "Verifying Bun checksum"
    $FileHash = Get-FileHash $BunZip -Algorithm SHA256
    $ActualSha = $FileHash.Hash
    $LoginResponse = Invoke-WebRequest "https://github.com/oven-sh/bun/releases/download/bun-v$BunVersion/SHASUMS256.txt" -UseBasicParsing
    $ContentString = [System.Text.Encoding]::UTF8.GetString($LoginResponse.Content)
    $ShaArray = $ContentString -split "`n"
    foreach ($ShaArrayEntry in $ShaArray) {
        $EntrySplit = $ShaArrayEntry -split "\s+"
        $EntrySha = $EntrySplit[0]
        $EntryFile = $EntrySplit[1]
        if ($EntryFile -eq "$BunRelease.zip") {
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
        Remove-Item $BunTargetDir -Recurse -Force
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
$BunTargetDir = "$Cache\bun-v$BunVersion-x64"
$BunExe = "$BunTargetDir\bun.exe"
$BunZip = "$BunTargetDir\bun.zip"
$CoreInfoExe = "$Cache\coreinfo\Coreinfo.exe"

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
& "$BunExe" @Args
exit $LastExitCode
