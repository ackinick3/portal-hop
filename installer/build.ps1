param([string]$Compiler = '')
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$engine = Join-Path $root 'tools/godot-4.7.2/Godot_v4.7.2-stable_win64_console.exe'
if (-not $Compiler) { $Compiler = Join-Path $root 'tools/inno-setup/ISCC.exe' }
if (-not (Test-Path -LiteralPath $Compiler)) { throw 'Install Inno Setup 6.7.3 and pass -Compiler <absolute ISCC.exe path>.' }
& $engine --headless --path $root --export-release 'Windows Desktop' (Join-Path $root 'builds/PortalHop.exe') --log-file (Join-Path $root 'docs/v1-export.log')
if ($LASTEXITCODE -ne 0) { throw 'Godot export failed' }
& $Compiler (Join-Path $PSScriptRoot 'PortalHop.iss')
if ($LASTEXITCODE -ne 0) { throw 'Installer compilation failed' }
Get-FileHash -Algorithm SHA256 -LiteralPath (Join-Path $root 'builds/PortalHop.exe'),(Join-Path $root 'builds/PortalHop-1.1-Windows-x64-Setup.exe')
