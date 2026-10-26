# Portal Hop 1.0 release review

Scope: main-menu locale selection, Chinese default/persistence, bundled font, version metadata, Windows installer. Reviewed uncommitted changes against 84c434e, including new languages/theme/installer/localization test files.

Independent read-only reviewer: no actionable correctness findings. Persistence preserves unlocks/volume; missing language defaults Chinese; font is bundled; per-user installer and save location are consistent.

Minor polish raised: final English completion used the old PROTOTYPE COMPLETE wording. Resolved as GAME COMPLETE; Chinese remains 全部通关. Source captures and installed-package language checks rerun after this change.

No map or physical parameter changes. Actual checks and remaining coverage limits are listed in build-manifest.txt and PROJECT_STATE.md.
