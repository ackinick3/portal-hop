# Implementation plan

Spec: 任务书.md. Execute inline, stage by stage; no core rule changes.

- [x] 0. Official portable Godot, Git, 960x540 fixed view, main scene. Verify editor and actual scene startup; preserve logs.
- [x] 1. Reusable CharacterBody2D Pip and test room. Verify motion, wall collision, variable jump, coyote and buffered jump.
- [x] 2. Portal test room: continuous axis-aligned surfaces, ray occlusion, 72px placement, real split colliders. Verify all orientations before levels.
- [x] 3. Unified vector transform and swept portal crossing. Verify 16 direction pairs, speed preservation, high speed wall/hazard collision, exit separation.
- [x] 4. Level 1 and repeatable floor-to-floor route.
- [x] 5. Level 2 and repeatable gravity slingshot route with actual physics.
- [x] 6. Sentry patrol, stomp and side-hit tests, Level 3 ordinary and portal routes.
- [x] 7. Menus, unlock persistence, timer/deaths, sounds, settings, full progression.
- [x] 8. Full regression, matching official export templates, standalone Windows launch, README and known issues.

Collision approach to validate: split only the player collision layer at active portal intervals; enemy and gun ray layers retain full surfaces. Trace crossings along swept player movement and preserve full vector using t=(-n.y,n.x). Reject blocked exits without modifying existing portals.
