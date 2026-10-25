> 历史50关版本档案：本轮已按用户要求删减至23关并移除游戏提示。下方旧编号/路线不是当前关卡清单；以PROJECT_STATE.md与docs/编号对照.md为准。

# Laser chapter: rooms 20–25

All coordinates use the 960×540 view. Lasers are continuous and harmless puzzle tools. Receivers latch real beam contact until R/restart; there is no forced power, goal trigger, velocity or position assignment in route tests. Each full-height gate is a real collider and shot blocker. The full floor is safe for retries. The portal aperture is still freely placed on each pale face.

## 20 — First Light

From (140,465), shoot RED at hanging wall (340,300), BLUE at floor (100,480) behind the start. Horizontal source (80,300) enters RED and rises from BLUE into receiver (100,160), opening gate x780. Hold D through the 60px passage below the hanging wall to the exit. The blue opening is behind the route, so this first introduction needs no jumping or bodily teleport. Without redirecting light the gate stops ordinary walking. R closes the gate, extinguishes the receiver, clears doors and restores spawn.

## 21 — Light Well

From (140,465), shoot RED floor (300,480), BLUE floor (620,480). The source drops at x300, exits upward at x620 and reaches receiver (620,190), opening x800. Walk to x240, jump right across the red opening to approximately x390; walk under the suspended central divider to x560, jump across the blue opening to x710, then continue right. Both floor openings are 72px and the jumps have normal player physics. Failure is recoverable on the safe floor or with R. Initial vertical light cannot reach the other shaft.

## 22 — Around the Corner

Spawn (220,465). Shoot RED at floor (150,480) behind you and BLUE at the far hanging wall (500,280), facing left. The source drops into the floor and emerges leftward from the wall toward receiver (370,280) behind the tall divider. Walk through the 130px divider passage and 60px wall passage to the powered gate x760 and exit. The output wall is genuinely visible from the initial low shooting position: the aim line passes below the high divider. No shot passes through its collision.

## 23 — Two Light Memory

Shoot RED wall (300,260), then BLUE floor (520,480). Receiver (520,180) lights, but the gate x800 stays closed because it needs both ids. Move BLUE to floor (660,480); the first light stays latched, and the second beam reaches (660,140). Walk through the hanging partitions to x600, jump over the remaining blue opening to about x750, and continue. Old BLUE at x520 has closed, so only the final opening needs a jump. R restores both lights and the gate.

## 24 — Ceiling Switchboard

First RED wall (300,240). Walk under that wall to x400. The gate x600 blocks a premature far-ceiling shot; shoot BLUE at near ceiling (480,100), sending light downward into (480,300). Cross the now-open first gate to x660, then replace BLUE at far ceiling (760,100). Its downward beam powers (760,300), opening gate x860. Continue right. The first receiver remembers its light, so replacing BLUE does not trap the player between the gates. Neither door crosses the walking floor.

## 25 — Circuit Exchange

First circuit: RED wall (300,220), walk beneath it to x390, then BLUE near ceiling (440,100). Receiver (440,300) opens access gate x560. Walk through to x620. Replace RED with floor (700,480) beneath the second downward source; replace BLUE with far wall (820,280), facing left. Receiver (650,280) now powers gate x870; the first light stays latched. Walk to x640, jump right across the red opening to about x785, settle onto the floor, then walk through the 60px wall passage to the exit. This chapter finale requires switching both ends to a separate source and a different output orientation.

## Verification

`tests/laser_routes.gd` uses `Input.action_press/release`, actual `player.gun_origin()` and `portals.shoot`, real receiver contact and normal goal detection. Each room has an initial no-shot walking control, actual power check, R reset check including collision layers, and a fresh zero-death completion route. Rooms 23–25 also check partial-circuit gating; room 24 checks an actual blocked premature shot. The integrated `--fixed-fps 120` run passed all six routes with `state=won`, `deaths=0` and `LASER_ROUTE_FAILURES=0`; full stdout/stderr in `docs/laserchapter-check.log` contained no runtime errors or exit leaks. The test allows 350ms of wall time after audio cleanup because accelerated virtual time cannot drain the audio mixer. The first expected missing-chapter failure is `docs/laserchapter-before.log`.

Human playtesting and GPU visual review remain for integration; this file describes the standard route, not human approval of difficulty.
