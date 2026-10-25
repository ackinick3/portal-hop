# Portal Hop

Godot4.7.2 / GDScript，Windows x64，23关单机版。开发接续先读[PROJECT_STATE.md](PROJECT_STATE.md)与AGENTS.md；换对话时再读[新对话交接总结](docs/新对话交接.md)。

双击`builds/PortalHop.exe`或桌面Portal Hop快捷方式，持续使用同一个文件。用户指定的27关已删，剩余关卡连续编号；[新旧编号对照](docs/编号对照.md)。游戏内教学卡、建议圈、教程和机关说明菜单均已移除，选关/NEXT直接开始。

- A/D：移动；Space：跳跃。
- 鼠标左/右键：红/蓝传送门。
- R：重试；Esc：暂停；F11：全屏。
- 设置支持音量，选关3页；旧存档自动迁移，不清空进度。实际存档位于`%APPDATA%/Godot/app_userdata/Portal Hop/progress.cfg`。

原有手感、保留关卡布局、B美术与操作反馈保持。准星、放门预览、枪线和机关状态仍可见。原50关详细路线文档与截图仅作开发历史，不能按旧编号作为当前关卡清单。

## 开发与检查

自主画关卡入口：[空白关卡编辑器](docs/关卡编辑器.html)，普通浏览器打开即可。点击放置部件、拖墙/地刺、设置发射器方向/怪物范围，使用曲线箭头画预期路线；导出设计JSON回传后再计算地图比例，用户确认后实装。[操作说明](docs/level-editor/README.md)。

首张用户草图的[原图/比例修订对照](docs/level-editor/designs/2026-10-25-fall-bounce/plan.html)已形成，附可编辑JSON与计算依据；等待用户复核，不是新增可玩关卡。

关卡设计评审入口：[本地地图批注网页](docs/地图批注.html)，用普通浏览器打开，可逐关翻页、画笔/箭头/文字批注、自动保存及导入/导出。评完导出全部批注JSON发回对话，再更新计划图，用户确认后实装游戏。当前只包含手绘五图A–E，不是新增可玩关卡；[使用与维护说明](docs/map-review/README.md)。

```powershell
& ./tools/godot-4.7.2/Godot_v4.7.2-stable_win64.exe --editor --path .
& ./tools/godot-4.7.2/Godot_v4.7.2-stable_win64_console.exe --path .
./tests/run.ps1
& ./tools/godot-4.7.2/Godot_v4.7.2-stable_win64_console.exe --path . --script tests/campaign_preview.gd
& ./tools/godot-4.7.2/Godot_v4.7.2-stable_win64_console.exe --headless --path . --export-release 'Windows Desktop' builds/PortalHop.exe
```

测试隔离真实进度。当前入口32组，覆盖保留23关的真实输入路线、核心物理/光路/平台、删关顺序、无提示、重编号、分页、存档迁移及重试。GPU截图在docs/curated-preview；实际验证及导出身份见docs/build-manifest.txt。工具/模板与builds不进入Git，新克隆需自行准备；资源嵌入EXE，无需玩家安装Godot。
