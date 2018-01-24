#!/usr/bin/env powershell
# Assume that if IsWindows doesn't exist, we're on Windows.
# This assumption is because outdated Powershell versions don't have the variable.
if ($IsWindows -Or !(Test-Path variable:global:IsWindows))
{
	$target = "i686-pc-windows-msvc"
	$filename = "libvg"
	$ext = "dll"
}
elseif ($IsLinux)
{
	$target = "i686-unknown-linux-gnu"
	$filename = "liblibvg"
	$ext = "so"
}
else
{
	Write-Error "BYOND only runs on Linux or Windows, what're you even building libvg for?"
}

cargo build --release --target $target

if ($?)
{
	if (Test-Path "../libvg.$ext")
	{
		Write-Host "Deleting old version of libvg in the project root."
		Remove-Item "../libvg.$ext"
	}
	Copy-Item "target/$target/release/$filename.$ext" "../libvg.$ext"
}
else
{
	Write-Error "There was an error during the build."
}
