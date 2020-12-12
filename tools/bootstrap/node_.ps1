# bootstrap/node_.ps1
#
# Node bootstrapping script for Windows.
#
# Automatically downloads a Node version to a cache directory and invokes it.
#
# The underscore in the name is so that typing `bootstrap/node` into
# PowerShell finds the `.bat` file first, which ensures this script executes
# regardless of ExecutionPolicy.
$ErrorActionPreference = "Stop"

function ExtractVersion {
	param([string] $Path, [string] $Key)
	foreach ($Line in Get-Content $Path) {
		if ($Line.StartsWith("export $Key=")) {
			return $Line.Substring("export $Key=".Length)
		}
	}
}

# Convenience variables
$Bootstrap = Split-Path $script:MyInvocation.MyCommand.Path
$Cache = "$Bootstrap/.cache"
if ($Env:TG_BOOTSTRAP_CACHE) {
	$Cache = $Env:TG_BOOTSTRAP_CACHE
}
$NodeVersion = ExtractVersion -Path "$Bootstrap/../../dependencies.sh" -Key "NODE_VERSION_PRECISE"
$NodeFullVersion = "node-v$NodeVersion-win-x64"
$NodeDir = "$Cache/$NodeFullVersion"
$NodeExe = "$NodeDir/node.exe"
$Log = "$Cache/last-command.log"

# Download and unzip Node
if (!(Test-Path $NodeExe -PathType Leaf)) {
	Write-Output "Downloading Node $NodeVersion..."
	New-Item $Cache -ItemType Directory -ErrorAction silentlyContinue | Out-Null

	$Archive = "$Cache/node-v$NodeVersion.zip"
	Invoke-WebRequest `
		"https://nodejs.org/download/release/v$NodeVersion/$NodeFullVersion.zip" `
		-OutFile $Archive `
		-ErrorAction Stop

	Expand-Archive $Archive `
		-DestinationPath $Cache `
		-ErrorAction Stop

	Remove-Item $Archive
	Clear-Host
}

# Invoke Node with all command-line arguments
Write-Output $NodeExe | Out-File -Encoding utf8 $Log
[System.String]::Join([System.Environment]::NewLine, $args) | Out-File -Encoding utf8 -Append $Log
Write-Output "---" | Out-File -Encoding utf8 -Append $Log
$Env:PATH = "$NodeDir;$ENV:Path"  # Set PATH so that recursive calls find it
$ErrorActionPreference = "Continue"
& $PythonExe $args 2>&1 | ForEach-Object {
	"$_" | Out-File -Encoding utf8 -Append $Log
	"$_" | Out-Host
}
exit $LastExitCode
