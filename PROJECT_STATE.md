# Portal Hop：项目现状与接续指南

最后整理：2026-10-26。先完整读本文件，再读AGENTS.md和README；按最新用户要求继续，不把历史计划当待做任务。

## 最新接续方向

2026-10-26标题设计素材：按最新意见生成[PORTAL HOP标题v3](docs/title-art/portal-hop-title-v3.png)：不再使用传送门圆环，两个O恢复普通浅色字母，T顶部横笔为红线、H中部横笔为蓝线，呼应游戏实际线段门。2172×724透明PNG已视觉核对文字/结构并验证角落alpha=0；v1/v2保留。仍仅交付标题图供查看，未接入菜单或更新EXE/安装器，本轮未重新验证游戏运行。

2026-10-26主菜单小修：删除退出按钮下的版本/关卡小字，标题改为960px全宽居中。版本仍1.0，版本信息保留在工程与Windows属性中。源码GPU中英文页面检查及截图已核对；更新安装包后，隔离安装、内嵌语言检查、GPU启动、卸载与存档保护均通过。日志docs/menu-polish-*.log；本轮未重跑完整47组/96例，以下全套结果属于此前1.0基础发行。

当前版本定为Portal Hop 1.0（Windows文件/产品版本1.0.0.0），29关。主菜单新增“语言 / Language”，支持简体中文与English；首次运行及无语言字段的旧存档默认中文，保存过的语言选择下次恢复。菜单、设置、键位说明、选关/29个关卡名称、暂停与结算均有中文。Noto Sans SC字体随包嵌入，不依赖目标电脑系统中文字体；原地图、物理与传送公式未改。

交付仍使用唯一游戏入口builds/PortalHop.exe；新增builds/PortalHop-1.0-Windows-x64-Setup.exe为安装器，不是并列游戏版本。安装器支持Windows10+ x64、当前用户目录安装、开始菜单、可选桌面快捷方式及Windows应用卸载。卸载保留玩家存档。开发目录原桌面快捷方式仍指向builds/PortalHop.exe。安装构建源与说明见installer/README.md；最新文件大小和SHA256见docs/build-manifest.txt。

1.0基础发行轮已通过源码GPU中英文/字体/布局/保存检查、内嵌包键位与隔离挑战入口、安装后的内嵌语言/字体检查与实际GPU启动；安装/卸载均退出0，已验证文件哈希、开始菜单目标、卸载项与实际存档哈希/修改时间不变。47组完整回归与96例重试压力全部通过，退出0且无SCRIPT ERROR/ERROR/退出泄漏。独立只读审阅无实质问题；英文最终结算已从PROTOTYPE COMPLETE调整为GAME COMPLETE。中英文截图docs/v1-*.png已查看主要页面；本轮未逐关重拍GPU或做人手难度验收。

第29关THE BORROWED EXIT（借来的出口，稳定ID56）保留此前已交付的高难解谜。用户希望先自行探索，不加解法提示；详细解法仅在[开发设计记录](docs/level-editor/designs/2026-10-25-borrowed-exit/README.md)，试玩汇报不要剧透。命令行PortalHop.exe -- --challenge直接进入29且禁用该进程所有存档写入；正常完成28解锁29。第28关自由解法与移动机关见[28开发记录](docs/level-editor/designs/2026-10-25-kinetic-chamber/README.md)。不把自动路线通过当成人手难度认可。
## 当前版本与约束

- Portal Hop 1.0；Godot4.7.2/GDScript，Windows x64，单人离线、960×540固定单屏、120Hz、Compatibility。
- 当前源码29关。原50关按用户指令删除27关、保留23关后追加24–29；[编号对照](docs/编号对照.md)保留原顺序，新增稳定ID56，不复用被删编号。
- 选关3页（10/10/9），选关与NEXT直接入关。第28完成后NEXT到29，第29显示最终结算。无入关说明卡、建议圈、教程/机关说明菜单；准星、放门预览、枪线及机关反馈保留。
- 唯一交付入口builds/PortalHop.exe；桌面C:\Users\XH\Desktop\Portal Hop.lnk指向它。禁止并列可玩游戏版本EXE（1.0安装器除外），不终止用户试玩来替换文件。
- 自动通关不代表人手难度认可或所有巧解已穷尽。后续按用户反馈改地图，不自动改手感或实装其他草图。

## 当前机制与操作

A/D移动、Space跳跃、鼠标瞄准、左右鼠标红/蓝门、R计死亡重试、Esc暂停/继续、F11全屏。主菜单“键位说明 / CONTROLS”可查看操作并返回；“语言 / Language”切换中英文，默认中文。

| 项目 | 参数/规则 |
|---|---|
| 普通地面 | 跑速210，起跑/反向1400，松键2300；满速滑行约8.71px |
| 跳跃/空中 | 跳跃-330、重力900、土狼/缓冲0.1秒；空中按键380、松键横向90减速 |
| 门 | 72px真实开口，角色22×30；浅色面自由放、端点完整内贴、射线不穿实体、同色替换；新增凸多边形斜面支持 |
| 出口速度 | length(v_in)*n_out；总速度沿出口法线，无切向继承或关卡奖励 |
| 蓝材质 | 碰撞前速度反弹、保留切向；地板最低法向580，其他420，上限900 |
| 红材质 | 水平规则不变；可行走红坡按真实floor接触沿切线驱动，目标650、按键1800、松键2300，离面保留自然速度 |
| 绿材质 | 枪线等角反射最多8次，共用首实体路径；不反射激光；本轮未扩展绿色斜面 |
| 激光/接收器 | 真实双门转向沿出口法线，2px边缘余量，最多16跳/4000px；真实无遮挡照射后锁存至R |
| 门锁/平台 | 所需信号全亮动作；真实碰撞、折线逐边/末端往返/齿轮双轨、承载及扫掠避碰；平台不放门 |
| 阻枪光幕/移动终点 | 光幕只挡枪线（含反射），人/激光沿用原规则；移动终点/尖刺跟随各自真实灰平台，实际落台后才可完成 |
| 重试/暂停 | R计死亡并清门/阶段/材质计数/接收器，门关闭、平台复位；暂停冻结，RESTART另清计时/死亡 |

怪物沿用70px/s及原侧碰死亡/向下踩踏规则；guard.vertical默认为false，24/27关开启上下巡逻，28关启用六只两点向量巡逻；第三关普通跳跃踩踏仍合法。B圆润旗帜/终点门、动作反馈及固定音效池不变。可拿取的惯性方块、压力按钮、用于连续激光的挡光和红色致死激光仍未实现。

## 工程与存档接续

- levels/maps.gd唯一数量LEVEL_COUNT=29，get_level接受0..28；ROOM_IDS是稳定ID列表，不是另一套游玩编号，index_for_id用于迁移/测试。
- 原地图仍在maps/campaign/coating_rooms/laser_rooms/advanced_rooms；levels/designed_rooms.gd保存新增ID51/52/53/54/55/56。章节路由使用稳定ID减一，旧28关地图数据未改。
- scenes/main.gd管菜单/分页/进度/结算及交互，将可选polygons交给门系统。actors/player.gd新增红坡接触/切向分支，world/materials.gd未改；actors/sentry.gd支持可选vertical；portals/system.gd保留旧Rect2及凸多边形路径。
- 地图必需name/spawn/goal/blocks/faces/enemy，可选polygons:Array[PackedVector2Array]、guard/guards/materials/mirrors/emitters/receivers/gates/movers/hazards/moving_hazards/gun_screens。移动终点用goal_mover（movers索引）及goal_offset（相对平台左上角）绑定；polygons仅凸多边形，面与外法线须贴合实体；不添加hint/guide/briefing。
- movers可选path为包含起点的左上角点数组，省略时沿用rect→to；guards为spawn/patrol两点向量名单，旧guard和enemy别名保留。moving_hazards条目为mover索引及相对左上角rect，伤害/绘制使用同一hazard_rects。出生先初始化previous_position，避免虚假首帧扫掠。
- progress.order_version仍为2，存当前编号unlocked/音量/语言settings.language（zh_CN或en）；版本2按1..29限幅，不重复迁移。已有28解锁保持28，完成28后解锁29，不自动修改玩家进度。
- 缺版本的旧50关存档迁移到首个保留原ID≥旧最高解锁ID。旧12→新12（原14）、旧22→新17（原25）、旧49/50→新23，新增ID51/52/53/54/55/56不改变这些映射。
- 测试persistence_enabled=false，不写实际%APPDATA%/Godot/app_userdata/Portal Hop/progress.cfg。

## 验证与运行

1.0基础发行轮（菜单小修前）：完整47组回归/96例重试压力通过，runner退出0，无运行错误或退出泄漏。源码GPU tests/localization.gd检查中英文页面/全部29个关卡译名、按钮宽度、内嵌字体字形、旧存档默认中文与隔离文件保存/恢复；LOCALIZATION_FAILURES=0。键位测试、内嵌challenge_entry及安装包内语言测试通过。安装后的GPU启动退出0；安装/卸载、开始菜单目标、Windows版本和存档保护检查见docs/v1-installer-validation.log。

源码日志docs/v1-all-tests.log、v1-language-test.log；导出docs/v1-export.log；包内docs/v1-pack-controls.log、v1-pack-challenge.log；实际安装docs/v1-install-test.log、v1-installed-language.log、v1-installed-start.log、v1-uninstall-test.log。中英文截图docs/v1-*.png。历史第29关45组/96例及第28关43组/93例不替代本轮结果；未做全部旧关GPU/长时间/所有显示器/全部巧解验收。
```powershell
./tests/run.ps1
& ./tools/godot-4.7.2/Godot_v4.7.2-stable_win64_console.exe --path . --script tests/kinetic_chamber.gd -- --capture
& ./tools/godot-4.7.2/Godot_v4.7.2-stable_win64_console.exe --headless --path . --script tests/kinetic_stage.gd
& ./tools/godot-4.7.2/Godot_v4.7.2-stable_win64_console.exe --path . --script tests/display.gd
& ./tools/godot-4.7.2/Godot_v4.7.2-stable_win64_console.exe --headless --path . --export-release 'Windows Desktop' builds/PortalHop.exe
```

最新GPU在docs/borrowed-exit-preview；历史28在kinetic-chamber-preview、27在wandering-goal-preview、26在boost-bounce-preview、25在double-return-preview、24在sloped-preview，其他历史图不能冒充本轮。EXE大小/SHA/启动/内嵌包/单一入口统一见docs/build-manifest.txt。tools/builds忽略，新克隆须准备引擎/模板。实时回归不使用--fixed-fps加速。

## 创作工具与后续范围

[空白关卡编辑器](docs/关卡编辑器.html)现有16类部件；移动平台与阻枪光幕支持JSON/绘制/属性/轨迹编辑，保留曲线预设路径、撤销/重做、本机保存及JSON/PNG导入导出。网页只表达布局，不模拟运动/碰撞/激光或自动求解；普通评图先计算并确认再实装，调用portalhop-level-builder则按最新授权自主完成分析至交付。27/28已接灰平台/折线往返/移动终点/移动尖刺/阻枪光幕；蓝红移动平台材质未在当前图实现，不能从编辑器支持推断游戏已支持。

此前工具轮编辑器13项+旧批注页9项Node检查及新部件浏览器放置/属性/轨迹/存储/导出实测通过，工具轮当时游戏未变。27/28关轮上述22项工具检查再次通过，未改编辑器网页或用户原file布局；新的对照网页独立测试原/修订切换与下载，并比对修订JSON。游戏本轮验证与新EXE身份见最新接续和构建清单，不混用此前工具轮“不改游戏”的结论。

[本地地图批注页](docs/地图批注.html)保留五图A–E逐页批注；94条原始手写意见归档docs/map-review/feedback/2026-10-25-050407.json，R2底图版本50640cab687f。旧五图仍未接入游戏，当前草图01批准不等于它们全部已批准。D/E红实线是加速墙，红坡接触支撑现已补齐并在26验证，但这些草图的具体斜率/接缝/可达性仍未逐图验收。原14类部件的完整浏览器实测属于首版工具；本轮旧数据兼容和批注页Node回归通过，未改批注工具逻辑。

历史交接见docs/新对话交接.md，过程见docs/进度.md。行为/运行/验证变化同步本文件、README、已知问题及构建清单，与代码一起提交。
