# Twenty-three-room pruning plan

User requests deletion of original rooms12,13,15,16,18,22,23,24,26,27,28,29,30,31,32,33,35,39,40,41,42,43,44,45,46,47,49 (too easy), continuous renumbering, all hints removed. Latest action revokes earlier wait-until-play-finished instruction.

Keep original IDs1-11,14,17,19,20,21,25,34,36,37,38,48,50, displayed1-23. Keep geometry/physics of survivors. Stable original IDs remain internal for migration and route fixtures, not alternate playable indices. Physically prune deleted map branches and unused map helpers. Remove briefing, guide, hint data and gameplay tutorial code/menus; preserve aiming cursor, candidate preview, shot traces and mechanical wiring feedback.

- [x] First fail tests/curation.gd on old count; verify exact roster, deleted bounds, no hint data/UI, direct enter,3page locks, legacy save migration and versioned progress.
- [x] Maps.ROOM_IDS + index_for_id, private dispatch by stable source ID; prune chapter cases and remove all hint metadata/helper code. Main direct enter, remove tutorial imports/functions/circles/menus, version2 save count and migration to next surviving original ID.
- [x] Update authentic route fixtures to use surviving stable IDs and current indices; remove deleted routes/guidance assertions, keep all remaining mechanics coverage; add curation to runner. Preserve interrupted QA168-case result as previous50-room evidence, adapt stress fixture to retained rooms.
- [x] Full relevant suites, authentic routes for23, fresh read-only review, GPU menu/3pages/no-hint room render, display, canonical EXE export and pack smoke. No stopping user's game; oneEXE only.
- [x] Update PROJECT_STATE/README/issues/current mapping and build manifest; old detailed routes labelled historical; commit source/docs and retain rollback point.

Save migration: missing order_version is legacy original50 layout. For legacy highest-unlocked U, new highest-unlocked is first surviving ID>=U; if none use23. This preserves completed surviving predecessors and allows the next playable room when U was removed. order_version2 counts are already renumbered and only clamp1..23; new saves write2. Do not edit player's cfg during development tests.
