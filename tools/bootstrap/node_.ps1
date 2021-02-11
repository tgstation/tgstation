## bootstrap/node_.ps1
##
## Node bootstrapping script for Windows.
##
## Automatically downloads a Node version to a cache directory and invokes it.
##
## The underscore in the name is so that typing `bootstrap/node` into
## PowerShell finds the `.bat` file first, which ensures this script executes
## regardless of ExecutionPolicy.

#Requires -Version 4.0

$Host.ui.RawUI.WindowTitle = "starting :: node $Args"
$ErrorActionPreference = "Stop"

## This forces UTF-8 encoding across all powershell built-ins
$OutputEncoding = [System.Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$PSDefaultParameterValues['*:Encoding'] = 'utf8'

function ExtractVersion {
	param([string] $Path, [string] $Key)
	foreach ($Line in Get-Content $Path) {
		if ($Line.StartsWith("export $Key=")) {
			return $Line.Substring("export $Key=".Length)
		}
	}
	throw "Couldn't find value for $Key in $Path"
}

## Convenience variables
$BaseDir = Split-Path $script:MyInvocation.MyCommand.Path
$Cache = "$BaseDir/.cache"
if ($Env:TG_BOOTSTRAP_CACHE) {
	$Cache = $Env:TG_BOOTSTRAP_CACHE
}
$NodeVersion = ExtractVersion -Path "$BaseDir/../../dependencies.sh" -Key "NODE_VERSION_PRECISE"
$NodeDir = "$Cache/node-v$NodeVersion"
$NodeExe = "$NodeDir/node.exe"

## Download and unzip Node
if (!(Test-Path $NodeExe -PathType Leaf)) {
	$Host.ui.RawUI.WindowTitle = "Downloading Node $NodeVersion..."
	New-Item $NodeDir -ItemType Directory -ErrorAction silentlyContinue | Out-Null
	Invoke-WebRequest `
		"https://nodejs.org/download/release/v$NodeVersion/win-x86/node.exe" `
		-OutFile $NodeExe `
		-ErrorAction Stop
}

## Set PATH so that recursive calls find it
$Env:PATH = "$NodeDir;$ENV:Path"

## Invoke Node with all command-line arguments
$Host.ui.RawUI.WindowTitle = "node $Args"
$ErrorActionPreference = "Continue"
& "$NodeExe" @Args
exit $LastExitCode
