$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path $PSScriptRoot -Parent
$engine = Join-Path $projectRoot 'tools\godot-4.7.2\Godot_v4.7.2-stable_win64_console.exe'
foreach ($test in @('controls','movement','portals','portal_integration','physical_orientations','edge_cases','placement_edges','slopes','slope_boost','game','ceiling_route','respawn','feedback','polish','audio','stability','audio_quit','level4','level5','level6','level7','level7_energy','level8','no_portal_bypass','materials','optics','gun_screen','moving_platform','moving_goal','kinetic_stage','mechanisms','relay9','coating_routes','laser_routes','mixed_routes','advanced_routes','curation','vertical_guard','fall_bounce','double_return','boost_bounce','wandering_goal','kinetic_chamber','borrowed_exit','challenge_entry','retry_stress')) {
    $testArgs = if ($test -eq 'challenge_entry') { @('--', '--challenge') } else { @() }
    $output = & $engine --headless --path $projectRoot --script "tests/$test.gd" --log-file "docs/final-$test.log" @testArgs 2>&1
    $exitCode = $LASTEXITCODE
    $output | ForEach-Object { Write-Output "$_" }
    $testLog = Join-Path $projectRoot "docs/final-$test.log"
    # The engine's log can close before its final cleanup warnings reach stderr.
    $output | ForEach-Object { "$_" } | Set-Content -LiteralPath $testLog -Encoding utf8
    if ($exitCode -ne 0) { throw "Failed: $test ($exitCode)" }
    if (Select-String -LiteralPath $testLog -Pattern 'SCRIPT ERROR:|ERROR:|leaked at exit' -Quiet) { throw "Unexpected runtime error or leak warning: $test" }
}
Write-Output 'ALL 46 HEADLESS TEST SUITES PASSED'
Write-Output 'For GPU/window tests: run Godot --path . --script tests/display.gd'

