# Portal Hop：项目现状与接续指南

最后整理：2026-10-26。先完整读本文件，再读AGENTS.md和README；按最新用户要求继续，不把历史计划当待做任务。

## 最新接续方向

当前Portal Hop 1.1（Windows产品/文件1.1.0.0），已把用户确认的标题v3接入主菜单：普通O、T顶部红横笔/H中部蓝横笔。实际资产assets/menu-title.png与docs/title-art/portal-hop-title-v3.png SHA256相同；600×160 TextureRect在960px视口水平居中，保持比例，底部不显示小字。原29关、物理/传送规则、中文默认与语言/进度存档均保留。

唯一游戏入口builds/PortalHop.exe；安装器builds/PortalHop-1.1-Windows-x64-Setup.exe。AppId和存档位置保持，实际1.0→1.1覆盖升级、内嵌语言/版本/布局检查、GPU启动、卸载、玩家存档哈希/修改时间保护通过，日志docs/v11-upgrade-validation.log。源码localization/controls/curation/game通过，中英文菜单截图已查看；本轮未重跑完整47组/96例，旧1.0结果仅作历史。

用户确认公开仓库[ackinick3/portal-hop](https://github.com/ackinick3/portal-hop)。[1.0发行](https://github.com/ackinick3/portal-hop/releases/tag/v1.0)对应最终文字标题菜单b153735，[1.1发行](https://github.com/ackinick3/portal-hop/releases/tag/v1.1)对应图片标题源码5396bbb；两版源码/标签/EXE/安装器/SHA256附件均已发布。六个附件远端SHA256和大小与本机一致，两个公开安装包下载HEAD200，校验文件实际下载比对通过，标签指向已读回。随后已删除builds内1.0安装包/校验文件及临时1.0二进制备份，保留当前1.1、Git源码历史与标题原图。证据docs/v11-github-assets.json、v11-github-verification.log、v11-local-cleanup.log。

第29关THE BORROWED EXIT（稳定ID56）沿用已交付解谜。用户自行探索，不加解法提示；[开发记录（含剧透）](docs/level-editor/designs/2026-10-25-borrowed-exit/README.md)。--challenge直入29且该进程禁存档，普通完成28解锁29。1.0基础发行曾完整47组/96例通过，不能冒充当前新增验证。
## 当前版本与约束

- Portal Hop 1.1；Godot4.7.2/GDScript，Windows x64，单人离线、960×540固定单屏、120Hz、Compatibility。
- 当前源码29关。原50关按用户指令删除27关、保留23关后追加24–29；[编号对照](docs/编号对照.md)保留原顺序，新增稳定ID56，不复用被删编号。
- 选关3页（10/10/9），选关与NEXT直接入关。第28完成后NEXT到29，第29显示最终结算。无入关说明卡、建议圈、教程/机关说明菜单；准星、放门预览、枪线及机关反馈保留。
- 唯一交付入口builds/PortalHop.exe；桌面C:\Users\XH\Desktop\Portal Hop.lnk指向它。禁止并列可玩游戏版本EXE（发行安装器除外），不终止用户试玩来替换文件。
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

1.1本轮：源码localization（中英文/字体/保存/布局/1.1版本）、controls、curation（29关/3页/进度迁移）、game通过；GPU菜单截图已核对。安装测试先装1.0再覆盖1.1，版本读回1.0.0.0→1.1.0.0，EXE与构建哈希相同，注册项1.1，内嵌localization/实际GPU启动/卸载通过，真实存档未改。日志docs/v11-language.log、v11-controls.log、v11-curation.log、v11-game.log、v11-upgrade-validation.log、v11-installed-language.log、v11-installed-start.log；导出docs/v11-build.log（Godot子日志docs/v1-export.log）。

此前1.0基础47组/96例完整回归见docs/v1-all-tests.log，本轮未重跑；未做全旧关GPU/小时级/第二台物理机/所有巧解验收。当前图形和安装身份见docs/build-manifest.txt。
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
