[Setup]
AppId={{71BF9072-A6BA-46F4-A0CD-E61AC0CD1F10}
AppName=Portal Hop
AppVersion=1.1
AppVerName=Portal Hop 1.1
VersionInfoVersion=1.1.0.0
VersionInfoProductName=Portal Hop
DefaultDirName={localappdata}\Programs\Portal Hop
DefaultGroupName=Portal Hop
PrivilegesRequired=lowest
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
MinVersion=10.0
OutputDir=..\builds
OutputBaseFilename=PortalHop-1.1-Windows-x64-Setup
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
DisableProgramGroupPage=yes
UninstallDisplayIcon={app}\PortalHop.exe
SetupLogging=yes
CloseApplications=no
RestartApplications=no

[Languages]
Name: "chinesesimp"; MessagesFile: "ChineseSimplified.isl"
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "..\builds\PortalHop.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\assets\fonts\OFL.txt"; DestDir: "{app}\licenses"; DestName: "NotoSansSC-OFL.txt"; Flags: ignoreversion
Source: "GODOT-LICENSE.txt"; DestDir: "{app}\licenses"; Flags: ignoreversion
Source: "说明.txt"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{group}\Portal Hop"; Filename: "{app}\PortalHop.exe"
Name: "{autodesktop}\Portal Hop"; Filename: "{app}\PortalHop.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\PortalHop.exe"; Description: "{cm:LaunchProgram,Portal Hop}"; Flags: nowait postinstall skipifsilent
