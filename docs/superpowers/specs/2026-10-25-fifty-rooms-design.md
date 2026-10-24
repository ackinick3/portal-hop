# Portal Hop fifty-room campaign design

User authorization: autonomously design, implement and verify through room 50 without awaiting answers; solve issues independently and preserve one game. This overrides earlier pending brainstorming questions and the earlier stop-at-eight roadmap. No platform quota reset capability is assumed.

## Decisions

Retain Godot 4.7.2, 960x540, previous eight maps and ordinary physics. Blue coating automatically rebounds on contact; red coating accelerates held movement along a floor, with a speed cap and retained speed after leaving it. Colored patches are not portal surfaces unless a separate pale face explicitly exists. Use portals in single-material groups; only the other new coating is excluded. Room 9 uses a generous geometric high-point window for sequential floor portal relays.

Laser emitters fire continuously. An active portal pair redirects a beam through real apertures, blocked by all other solids. Receivers struck by a real beam latch on until R/restart and activate linked doors or moving platforms. Lasers are visible puzzle tools, not an additional unrequested lethal hazard. Multiple receivers may be required. Door/platform movement is visible and has actual collision. Connections use light/cable graphics, not in-play HUD text.

Green surfaces reflect portal gun rays geometrically. Only the first solid encountered may reflect if its exposed face is green; no shooting through walls. Preview and shots share reflected paths and final inward portal clamping. Bound reflections to avoid loops. Lasers use portal routing, not green gun mirrors. Moving platforms have spinning undercarriage gears and background inset rail tracks, carry a standing character, pause with the scene, and reset on retry. Moving platforms themselves do not accept portal placement in this release, avoiding unsupported moving door attachments.

## Campaign sequence

9 floor relay above spikes. 10 blue bounce introduction. 11 red runway plus portal over spikes. 12-14 blue only, 15-17 red only, 18-19 mixed. Latest request makes room 20 the first laser introduction; 20-25 laser puzzles. 26-35 mix coatings with laser-controlled scene changes. 36-50 introduce green ray reflection, moving platforms, then combine all features with increasing route planning. Each map has a distinct geometry/shot target/action sequence rather than copied room names.

## Completion criteria

50 selectable rooms, old progress preserved, 8→9 and all subsequent unlocks, final only at 50, paginated selection fits viewport, briefing for each new room. Per-room standard route documented and exercised using real movement/jump/shoot calls from actual gun origins; no route-test velocity assignment, forced receiver activation, or direct goal completion. Negative controls prove introductory mechanics required. R clears portals, receivers, movers and stages; pause freezes. Full old regression, new mechanism suites, all new routes, GPU previews, display and unique exported EXE smoke test. Update PROJECT_STATE/README/issues/progress/build manifest and Git checkpoints. Human playtesting remains pending.
