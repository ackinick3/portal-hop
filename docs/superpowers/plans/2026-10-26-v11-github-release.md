# Portal Hop 1.1 release and GitHub archive

User approved title v3, centered main-menu replacement, version1.1, Windows download, public GitHub archive of1.0/1.1, then local old-version cleanup.

- [x] Preserve existing1.0 EXE/setup/checksum in ignored staging; retarget unpublished v1.0 tag to b153735, the final1.0 menu build commit.
- [x] Replace only main-menu title with approved PNG in centered TextureRect; set application/export/installer metadata1.1, retain AppId/save location/default Chinese and game physics.
- [x] Run current language/layout/controls checks and GPU captures; export same builds/PortalHop.exe and new1.1 setup; verify upgrade/install/hash/launch/uninstall with save preservation.
- [x] Commit source and matching manifests; create public ackinick3/portal-hop, push source and v1.0/v1.1 tags; publish releases containing matching EXE/setup/SHA256.
- [x] Verify remote refs and GitHub server SHA256/size and public download/checksum readback before removing exact old1.0 installer/checksum and temporary old binaries. Keep current project/source history/approved title original.

No force push or deletion of source history. Existing local v1.0 tag has never been pushed because repository has no remote. Both release tags must match the actual respective builds. Do not call full old47-suite results current unless rerun. Latest code/header art integration has no map/physics change.
