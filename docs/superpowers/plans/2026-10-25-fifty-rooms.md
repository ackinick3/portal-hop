# Fifty-room campaign implementation plan

> **For agentic workers:** use executing-plans for integration, with independent material and optical implementation domains delegated under dispatching-parallel-agents. User explicitly opted out of further approvals.

**Goal:** Deliver Portal Hop through room 50 with coatings, portal lasers, receivers, gun mirrors and moving platforms.
**Architecture:** Keep old maps/player/portal interfaces compatible; add optional material patches and ray occluders, a stage mechanisms node, and a campaign map module. All new fields default empty.
**Tech Stack:** Godot 4.7.2 / GDScript / PowerShell.
**Spec:** docs/superpowers/specs/2026-10-25-fifty-rooms-design.md

## Global constraints

Single 960x540 screen, previous eight maps unchanged, ordinary ground210/1400/2300, jump-330, gravity900, air380/release90, scalar portal speed. One builds/PortalHop.exe, real collision and no wall penetration, no HUD text. No save writes by tests. No stopping user's game process.

## Review focus

- A green face hidden behind an opaque solid never reflects a shot; preview and actual ray end match.
- Beam aperture edges, inactive portals and ray loops cannot spuriously activate a receiver.
- Bounce must use pre-slide collision velocity, boost must not leak onto normal floor or after reset.
- Movers carry riders and remain blockers for guns/beams; receiver reset restores real gate collision.
- Each new room wins by real route and cannot pass a test by assigned speed, position or scripted completion.

## Tasks

- [x] Materials: tests/materials.gd first fails for missing player.materials; implement optional patches {a,b,n,kind} in actors/player.gd plus world/materials.gd. Tests actual landing rebound, wall rebound, boosted run exceeding210 but bounded, preserved air speed, old ground unchanged, death reset. Interface player.materials:Array[Dictionary], bounces:int, boost_distance:float; Materials.draw(canvas,patches,time) and helpers chosen by implementer. No main/maps edits.
- [x] Optics: tests/optics.gd first catches missing reflected shot and beam route. portals/system.gd adds mirrors:Array[Dictionary] {a,b,n}, occluders:Array[Rect2], shot_path(origin,target)->Array[Dictionary] {a,b}, beam_path(origin,direction)->Array[Dictionary] {a,b}; keep ray_hit first-solid contract, candidate uses final reflected segment, shoot renders all segments. Beam passes only active apertures, bounded16 hops. Test reflection, occlusion, final edge clamp, inactive/active pairs, edge misses and bounded loops. No player/main/maps edits.
- [x] Mechanisms: tests/mechanisms.gd red first. world/mechanisms.gd Node2D configure(data,portals), reset(), receivers:Array[Dictionary] runtime active, movers:Array, gates:Array, beams:Array. Optional map fields materials,mirrors,emitters {p,d},receivers {p,id},gates {rect,requires},movers {rect,to,speed,requires}. Receivers latch actual beam hits. Stage owns moving collisions and drawings and sets portal.occluders. Main constructs stage before player, assigns materials, reset on death. All gates require all linked receiver ids. Test real blocked ray, beam unlock, reset, pause and rider motion.
- [x] Campaign: tests/campaign.gd initially catches missing room9; levels/campaign.gd static get_level for indices8..49, maps delegates after original branches. Stage1 rooms9-19, stage2 rooms20-35, stage3 rooms36-50. Save intended route and retry for every room in docs/campaign-routes.md; tests/campaign_routes.gd holds real-input controllers. Verify each family before expanding variants; don't change old physics to suit map.
- [x] UX/progression: paginated 10-room menu, generic new briefing with map title and readable short instructions; stage-aware textless guide points. tests/progression.gd update dynamic final expectations and iterate50 unlocks; no completing old test via real goal spoof. GPU preview50 and cards; verify locked rows/page boundaries and direct restart.
- [x] Integrate verification: extend tests/run.ps1 with mechanism and campaign route suites, capture full output; all old tests plus new ones pass. Run GPU previews/display, independent fresh code review and fix substantive findings.
- [x] Delivery: update PROJECT_STATE/README/roadmap/issues/progress, export same EXE when unused, standalone GPU exit0, hash/size/singleEXE/shortcut readback, docs/build-manifest, commits and clean status. Only then mark goal complete.
