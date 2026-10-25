# Portal Hop

Godot4.7.2 / GDScript，Windows x64，26关单机版。开发接续先读[PROJECT_STATE.md](PROJECT_STATE.md)与AGENTS.md；换对话时再读[新对话交接总结](docs/新对话交接.md)。

双击`builds/PortalHop.exe`或桌面Portal Hop快捷方式，持续使用同一个文件。用户指定的27关已删，剩余关卡连续编号；[新旧编号对照](docs/编号对照.md)。游戏内教学卡、建议圈、教程和机关说明菜单均已移除，选关/NEXT直接开始。

- A/D：移动；Space：跳跃。
- 鼠标左/右键：红/蓝传送门。
- R：重试；Esc：暂停；F11：全屏。
- 设置支持音量，选关3页；旧存档自动迁移，不清空进度。实际存档位于`%APPDATA%/Godot/app_userdata/Portal Hop/progress.cfg`。

原有手感、保留关卡布局、B美术与操作反馈保持。准星、放门预览、枪线和机关状态仍可见。原50关详细路线文档与截图仅作开发历史，不能按旧编号作为当前关卡清单。

## 开发与检查

自主画关卡入口：[空白关卡编辑器](docs/关卡编辑器.html)，普通浏览器打开即可。点击放置部件、拖墙/地刺、设置发射器方向/怪物范围，使用曲线箭头画预期路线；新增移动平台可改宽高、灰/蓝/红材质及多点往返轨迹，绿色虚线阻枪光幕表示人过、枪线不过。导出JSON回传；新增两类本轮仅支持设计器，后续提交关卡时补齐游戏运行机制。[操作说明](docs/level-editor/README.md)。

自动实装入口：[portalhop-level-builder技能](skills/portalhop-level-builder/SKILL.md)，已安装到用户Codex技能目录。发送`使用 $portalhop-level-builder，地图JSON：<文件路径>`，助手保持思路，自主计算比例、创建关卡、实际通关与回归、更新同一EXE并汇报；无需再次确认比例稿。仅要求评图时仍按评图范围，未定义的玩法语义会先询问。原稿/旧关/普通物理和真实存档保留。

首张用户草图已确认并实装为第24关THE FALLING RETURN（落差折返）：蓝斜面反弹、右白斜面传送门与120px底部白带。最新小修加入x542、y54–363上下巡逻怪，路线②/③要观察时机；[当前小修图/JSON](docs/level-editor/designs/2026-10-25-fall-bounce-guard/plan.html)。[原图/批准方案对照](docs/level-editor/designs/2026-10-25-fall-bounce/plan.html)及可编辑JSON保留。先通关第23关即可解锁，不重置旧进度。

第25关THE SECOND ASCENT（二次蓄势）保留两次斜面出门，需空中移动底门、第一次出门按A收落点、第二次松键。[原稿/修订及实测图](docs/level-editor/designs/2026-10-25-double-return/plan.html)。通关24后解锁25，旧进度与音量保留。

第26关THE CRIMSON ARC（赤坡接力）为红跑道/红坡越刺坑→双白斜面传送→蓝台反弹至终点；新增红坡接触支撑，普通和水平参数不改。[当前修订/实测图](docs/level-editor/designs/2026-10-25-boost-bounce/plan.html)。完成25后解锁26，原进度保留。

关卡设计评审入口：[本地地图批注网页](docs/地图批注.html)，用普通浏览器打开，可逐关翻页、画笔/箭头/文字批注、自动保存及导入/导出。评完导出全部批注JSON发回对话，再更新计划图，用户确认后实装游戏。当前只包含手绘五图A–E，不是新增可玩关卡；[使用与维护说明](docs/map-review/README.md)。

```powershell
& ./tools/godot-4.7.2/Godot_v4.7.2-stable_win64.exe --editor --path .
& ./tools/godot-4.7.2/Godot_v4.7.2-stable_win64_console.exe --path .
./tests/run.ps1
& ./tools/godot-4.7.2/Godot_v4.7.2-stable_win64_console.exe --path . --script tests/campaign_preview.gd
& ./tools/godot-4.7.2/Godot_v4.7.2-stable_win64_console.exe --headless --path . --export-release 'Windows Desktop' builds/PortalHop.exe
```

测试隔离真实进度。当前入口38组，覆盖当前26关真实输入路线、8方向斜面真实开口、核心物理/光路/平台、删关顺序、无提示、重编号、分页、存档迁移及重试。第26关GPU在docs/boost-bounce-preview，第25关在docs/double-return-preview，第24关在docs/sloped-preview，当前新图与选关在docs/curated-preview；实际验证及导出身份见docs/build-manifest.txt。工具/模板与builds不进入Git，新克隆需自行准备；资源嵌入EXE，无需玩家安装Godot。
