# Portal Hop 1.0 bilingual Windows release

User scope: main-menu language selection, Simplified Chinese default on fresh install, retain English, version 1.0, downloadable Windows installer.

Design: local English-to-Chinese UI dictionary, preserve map data and gameplay; store language in existing settings alongside volume/unlocks. Bundle redistributable Noto Sans SC with OFL. Main menu fits six buttons and displays v1.0. Inno Setup installs for current user with start-menu shortcut, optional desktop shortcut, and uninstall support; preserve user saves.

- [x] Add failing language/default/persistence/version checks.
- [x] Add translations for all menu/help/pause/results/29 names, language selection and bundled font; verify both-language layout and existing regressions.
- [x] Mark project/export Windows metadata 1.0; export the single builds/PortalHop.exe; verify embedded package.
- [x] Compile installer; install into isolated test directory, compare EXE hash, launch, verify uninstall entry and uninstall; publish local artifact link and SHA256.
- [x] Refresh PROJECT_STATE/README/known issues/build manifest/progress; commit source and release instructions.

Validation: isolate test settings from actual progress.cfg; no map or movement parameter changes. Fresh install defaults Chinese; existing unlocks/volume preserved; saved English restores English. Installer testing uses separate directory and no desktop shortcut overwrite. No online publishing requested.
