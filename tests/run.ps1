$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path $PSScriptRoot -Parent
$engine = Join-Path $projectRoot 'tools\godot-4.7.2\Godot_v4.7.2-stable_win64_console.exe'
foreach ($test in @('movement','portals','portal_integration','physical_orientations','edge_cases','game','ceiling_route','respawn','feedback','tutorial','polish','audio','stability','audio_quit')) {
    & $engine --headless --path $projectRoot --script "tests/$test.gd" --log-file "docs/final-$test.log"
    if ($LASTEXITCODE -ne 0) { throw "Failed: $test ($LASTEXITCODE)" }
    $testLog = Join-Path $projectRoot "docs/final-$test.log"
    if (Select-String -LiteralPath $testLog -Pattern 'SCRIPT ERROR:|ERROR:|leaked at exit' -Quiet) { throw "Unexpected runtime error or leak warning: $test" }
}
Write-Output 'ALL 14 HEADLESS TEST SUITES PASSED'
Write-Output 'For GPU/window tests: run Godot --path . --script tests/display.gd'

