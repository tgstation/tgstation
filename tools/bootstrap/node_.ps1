## bootstrap/node_.ps1
## Downloads a Node version to a cache directory and invokes it.

$ErrorActionPreference = "Stop"

function Extract-Variable {
	param([string] $Path, [string] $Key)
	foreach ($Line in Get-Content $Path) {
		if ($Line.StartsWith("export $Key=")) {
			return $Line.Substring("export $Key=".Length)
		}
	}
	throw "Couldn't find value for $Key in $Path"
}

function Download-Node {
	if (Test-Path $NodeTarget -PathType Leaf) {
		return
	}
	Write-Output "Downloading Node v$NodeVersion (may take a while)"
	New-Item $NodeTargetDir -ItemType Directory -ErrorAction silentlyContinue | Out-Null
	$WebClient = New-Object Net.WebClient
	$WebClient.DownloadFile($NodeSource, $NodeTarget)
}

## Convenience variables
$BaseDir = Split-Path $script:MyInvocation.MyCommand.Path
$Cache = "$BaseDir\.cache"
if ($Env:TG_BOOTSTRAP_CACHE) {
	$Cache = $Env:TG_BOOTSTRAP_CACHE
}
$NodeVersion = Extract-Variable -Path "$BaseDir\..\..\dependencies.sh" -Key "NODE_VERSION_PRECISE"
$NodeSource = "https://nodejs.org/download/release/v$NodeVersion/win-x86/node.exe"
$NodeTargetDir = "$Cache\node-v$NodeVersion"
$NodeTarget = "$NodeTargetDir\node.exe"

## Just print the path and exit
if ($Args.length -eq 1 -and $Args[0] -eq "Get-Path") {
	Write-Output "$NodeTargetDir"
	exit 0
}

## Just download node and exit
if ($Args.length -eq 1 -and $Args[0] -eq "Download-Node") {
	Download-Node
	exit 0
}

## Download node
Download-Node

## Set PATH so that recursive calls find it
$Env:PATH = "$NodeTargetDir;$ENV:Path"

## Invoke Node with all command-line arguments
$ErrorActionPreference = "Continue"
& "$NodeTarget" @Args
exit $LastExitCode
