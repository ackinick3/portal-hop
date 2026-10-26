# Portal Hop 1.0 Windows release

Build from the repository root:

```powershell
./installer/build.ps1
# Or pass -Compiler 'C:/path/to/Inno Setup 6/ISCC.exe'
```

Requires Godot 4.7.2/templates in the existing tools directories and Inno Setup 6.7.3. Compiler installer downloaded from the official Inno Setup download link; Authenticode status Valid, signer Pyrsys B.V. No compiler files ship with the game.

Outputs:
- `builds/PortalHop.exe`: the single current playable build.
- `builds/PortalHop-1.0-Windows-x64-Setup.exe`: distributable installer.

Installer: Windows 10+ x64, current-user installation, no elevation, start-menu shortcut, optional desktop shortcut, Windows Apps uninstall entry. Default installation directory `%LOCALAPPDATA%/Programs/Portal Hop`. Save data remains in `%APPDATA%/Godot/app_userdata/Portal Hop`; upgrading/uninstalling preserves it. Fresh or old settings without a language default to Simplified Chinese; a saved English selection remains English.

Bundled font source: https://github.com/notofonts/noto-cjk/blob/main/Sans/SubsetOTF/SC/NotoSansSC-Regular.otf (SIL OFL 1.1, assets/fonts/OFL.txt).
Installer Chinese translation: https://github.com/kira-96/Inno-Setup-Chinese-Simplified-Translation/blob/main/ChineseSimplified.isl (maintainer attribution retained in file).
Godot license source: https://github.com/godotengine/godot/blob/master/LICENSE.txt.
No signing certificate was supplied; the generated game and installer are unsigned. No online upload/hosting is performed; share the installer file itself.

Evidence and SHA256: docs/build-manifest.txt. Automated install testing uses an isolated tools directory, checks installed EXE identity and start-menu target, runs embedded language/font checks and a GPU launch, then uninstalls and confirms save preservation.
