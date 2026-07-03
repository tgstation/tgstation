$ErrorActionPreference = 'Stop'

$phrase = ($args -join ' ').Trim()
if (-not $phrase) { Write-Error 'empty phrase - select text or pass a phrase'; exit 1 }

$q = { '"{0}"' -f ($args[0].Replace('\', '\\').Replace('"', '\"')) }
$val = & $q $phrase
$stem = $phrase -replace '[\\/:*?"<>| ]', '_'
if (-not $stem) { $stem = '_' }

$root = (Resolve-Path "$PSScriptRoot/../..").Path
$dir = "$root/modular_bandastation/translations/public/ru_names"
$path = Join-Path $dir "$stem.toml"
New-Item -ItemType Directory -Force -Path $dir | Out-Null

$body = @"
[$( & $q $phrase )]
nominative = $val
genitive = $val
dative = $val
accusative = $val
instrumental = $val
prepositional = $val
gender = "plural"
"@

[IO.File]::WriteAllText($path, $body + "`n", [Text.UTF8Encoding]::new($false))
Write-Host "[ru_names] $path"
$path
