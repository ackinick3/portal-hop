$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path $PSScriptRoot -Parent
$engine = Join-Path $projectRoot 'tools\godot-4.7.2\Godot_v4.7.2-stable_win64_console.exe'
foreach ($test in @('movement','portals','portal_integration','physical_orientations','edge_cases','game','ceiling_route','respawn')) {
    & $engine --headless --path $projectRoot --script "tests/$test.gd" --log-file "docs/final-$test.log"
    if ($LASTEXITCODE -ne 0) { throw "Failed: $test ($LASTEXITCODE)" }
}
Write-Output 'ALL 8 TEST SUITES PASSED'

