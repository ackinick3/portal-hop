# Portal Hop：项目现状与接续指南

最后整理：2026-10-25。先完整读本文件，再读AGENTS.md和README；按最新用户要求继续，不把历史计划当待做任务。

## 最新接续方向

已按用户调用portalhop-level-builder提交的11-09-18 JSON追加第28关THE KINETIC CHAMBER（流动密室），稳定ID55。用户明确确认自由解法：四面白墙自由放门，避开六只独立巡逻怪和移动刺台，追上另一块平台上的终点；不强制固定传送顺序/次数。保留15部件ID/nextId16，没有给原图追加强制路线箭头。

[原/修订/计算与实测](docs/level-editor/designs/2026-10-25-kinetic-chamber/README.md)。原件SHA256 6E8628CB09A038A4034839EDB4F3209CD9A6B48DC8C62A07A7F462AB35224AF4。四面白墙内沿校准为x40–920/y40–510；终点绑定ID11的120×20灰台，保留五节点；尖刺绑定ID12的148×12灰台，保留三节点，左端中心74→116以容纳全台/墙缝。平台速度60/75，怪速仍70。参考解法：出生跳入地面门，顶门向下出门，实际落上移动终点；允许其他合法门位、踩怪和解法。

必要支撑：旧平台三参API兼容可选折线，逐边扫掠/末端原路返回；六怪名单兼容旧guard字段和enemy首只别名，两点向量巡逻；moving_hazards按真实mover位置供绘制/伤害共用。人物普通物理/传送公式、旧1–27地图均未改。修复两项实际复现问题：出生previous_position为零导致假扫过怪群；斜向平台接触恢复量投影错误造成交汇穿入约0.545px，改按阻挡法线限制推进后长相位重叠面积0并继续下一段。轨道遮住尖刺的审阅P2也已修复并重拍。

最新43组实时完整回归、93例重试/暂停压力通过，无运行错误/退出泄漏；docs/kinetic-all-tests.log及final-*.log。7组实际参考门位/近门位/短延迟都0死亡、1传送并实际落台；无门/远顶门不达，顶门350确实落在移动刺台死亡。机制夹具另验转角载人、高速逐边不剪角、薄墙、非首怪伤害、六怪速度/有界反向、2500帧平台交汇及重试出生安全，未把摆位当通关证据。

GPU初始/顶门出口/实落台及包内第28关/第三页8关图已查看；对照网页原/修订切换和实际下载JSON一致。名义GPU出口(225,56)/v(0,375)，实际落台约(225,176.06)，身体上沿最低约41。普通EXE菜单启动退出0，内嵌包28关身份、保留24–27及新28核心真实路线和整组kinetic_stage机制都通过。构建109340000字节，SHA256 CA3ACDB0DA9046E1F11B0A9263773E0DB16100FB05EB24305CC88C72411B3BE0。唯一入口/快捷方式保持，真实cfg仍45字节/2026-10-24 19:08:28；用户原file编辑器布局未操作。

独立只读审阅重跑旧moving_platform/vertical_guard，无其他已确认实质问题。自由参考解法较快，难度待用户评价；未穷尽全部门位/相位/巧解、极端速度下斜向载人挤压、长时间运行或显示映射。构建身份和实际证据统一见docs/build-manifest.txt。

此前24–27的实现与证据：[24上下怪](docs/level-editor/designs/2026-10-25-fall-bounce-guard/README.md)、[25二次蓄势](docs/level-editor/designs/2026-10-25-double-return/README.md)、[26赤坡接力](docs/level-editor/designs/2026-10-25-boost-bounce/README.md)、[27流动终点](docs/level-editor/designs/2026-10-25-wandering-goal/README.md)。此前27关轮41组/90例、26关轮38组/87例属于相应旧版本，不能替代本轮43组/93例。

技能portalhop-level-builder已安装，版本控制源skills/portalhop-level-builder，安装目录C:/Users/XH/.codex/skills/portalhop-level-builder。提供JSON调用即授权保持思路自主校准/实装/测试/导出；仅评图仍只评图，关键玩法语义不明时询问。[技能入口](skills/portalhop-level-builder/SKILL.md)。

## 当前版本与约束

- Godot4.7.2/GDScript，Windows x64，单人离线、960×540固定单屏、120Hz、Compatibility。
- 当前源码28关。原50关按用户指令删除27关、保留23关后追加24/25/26/27/28；[编号对照](docs/编号对照.md)保留原顺序，新增稳定ID55，不复用被删编号。
- 选关3页（10/10/8），选关与NEXT直接入关。第27完成后NEXT到28，第28显示最终结算。无入关说明卡、建议圈、教程/机关说明菜单；准星、放门预览、枪线及机关反馈保留。
- 唯一交付入口builds/PortalHop.exe；桌面C:\Users\XH\Desktop\Portal Hop.lnk指向它。禁止并列版本EXE，不终止用户试玩来替换文件。
- 自动通关不代表人手难度认可或所有巧解已穷尽。后续按用户反馈改地图，不自动改手感或实装其他草图。

## 当前机制与操作

A/D移动、Space跳跃、左右鼠标红/蓝门、R重试、Esc暂停、F11全屏。UI仍为英文。

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

- levels/maps.gd唯一数量LEVEL_COUNT=28，get_level接受0..27；ROOM_IDS是稳定ID列表，不是另一套游玩编号，index_for_id用于迁移/测试。
- 原地图仍在maps/campaign/coating_rooms/laser_rooms/advanced_rooms；levels/designed_rooms.gd保存新增ID51/52/53/54/55。章节路由使用稳定ID减一，旧27关地图数据未改。
- scenes/main.gd管菜单/分页/进度/结算及交互，将可选polygons交给门系统。actors/player.gd新增红坡接触/切向分支，world/materials.gd未改；actors/sentry.gd支持可选vertical；portals/system.gd保留旧Rect2及凸多边形路径。
- 地图必需name/spawn/goal/blocks/faces/enemy，可选polygons:Array[PackedVector2Array]、guard/guards/materials/mirrors/emitters/receivers/gates/movers/hazards/moving_hazards/gun_screens。移动终点用goal_mover（movers索引）及goal_offset（相对平台左上角）绑定；polygons仅凸多边形，面与外法线须贴合实体；不添加hint/guide/briefing。
- movers可选path为包含起点的左上角点数组，省略时沿用rect→to；guards为spawn/patrol两点向量名单，旧guard和enemy别名保留。moving_hazards条目为mover索引及相对左上角rect，伤害/绘制使用同一hazard_rects。出生先初始化previous_position，避免虚假首帧扫掠。
- progress.order_version仍为2，存当前编号unlocked/音量；版本2按1..28限幅，不重复迁移。已有27解锁保持27，完成27后解锁28，不自动修改玩家进度。
- 缺版本的旧50关存档迁移到首个保留原ID≥旧最高解锁ID。旧12→新12（原14）、旧22→新17（原25）、旧49/50→新23，新增ID51/52/53/54/55不改变这些映射。
- 测试persistence_enabled=false，不写实际%APPDATA%/Godot/app_userdata/Portal Hop/progress.cfg。

## 验证与运行

最新第28关轮：tests/run.ps1实际43组通过，93例重试压力通过；kinetic_stage/kinetic_chamber涵盖必要机制与真实路线，原运动/传送/斜面/材料/光路/旧移动平台/旧27关路线/存档边界全部继续通过。源码完整日志docs/kinetic-all-tests.log，包内实际路线与新机制分别在kinetic-standalone-kinetic_chamber.log、kinetic-standalone-kinetic_stage.log，均退出0/失败数0/无运行错误或退出泄漏。独立审阅记录kinetic-chamber-review.log。

GPU全组通过，P2尖刺可读性修复后单独重拍参考路线，初始/出口/实落台以及包内关卡/选关图已解码查看。普通EXE菜单启动--quit-after120退出0；包内28关直接进入、保留24怪/25/26/27身份及最后两台5/3节点/六怪/移动刺验证通过。没有修改真实进度；没有重新验证显示映射/逐张重拍旧27图，未声称人手难度或全部自由解法通过。

静态核对原件SHA/15IDs/nextId16、编辑器JSON往返、平台5/3点完整范围、六怪/实测落台/终点与尖刺相对绑定、HTML嵌入JSON/脚本、SVG唯一ID/文档链接、runner43。对照网页实际切换和下载核对通过；22项编辑器/旧批注Node回归通过。原用户file页未操作。

```powershell
./tests/run.ps1
& ./tools/godot-4.7.2/Godot_v4.7.2-stable_win64_console.exe --path . --script tests/kinetic_chamber.gd -- --capture
& ./tools/godot-4.7.2/Godot_v4.7.2-stable_win64_console.exe --headless --path . --script tests/kinetic_stage.gd
& ./tools/godot-4.7.2/Godot_v4.7.2-stable_win64_console.exe --path . --script tests/display.gd
& ./tools/godot-4.7.2/Godot_v4.7.2-stable_win64_console.exe --headless --path . --export-release 'Windows Desktop' builds/PortalHop.exe
```

最新GPU在docs/kinetic-chamber-preview；历史27在wandering-goal-preview、26在boost-bounce-preview、25在double-return-preview、24在sloped-preview，其他历史图不能冒充本轮。EXE大小/SHA/启动/内嵌包/单一入口统一见docs/build-manifest.txt。tools/builds忽略，新克隆须准备引擎/模板。实时回归不使用--fixed-fps加速。

## 创作工具与后续范围

[空白关卡编辑器](docs/关卡编辑器.html)现有16类部件；移动平台与阻枪光幕支持JSON/绘制/属性/轨迹编辑，保留曲线预设路径、撤销/重做、本机保存及JSON/PNG导入导出。网页只表达布局，不模拟运动/碰撞/激光或自动求解；普通评图先计算并确认再实装，调用portalhop-level-builder则按最新授权自主完成分析至交付。27/28已接灰平台/折线往返/移动终点/移动尖刺/阻枪光幕；蓝红移动平台材质未在当前图实现，不能从编辑器支持推断游戏已支持。

此前工具轮编辑器13项+旧批注页9项Node检查及新部件浏览器放置/属性/轨迹/存储/导出实测通过，工具轮当时游戏未变。27/28关轮上述22项工具检查再次通过，未改编辑器网页或用户原file布局；新的对照网页独立测试原/修订切换与下载，并比对修订JSON。游戏本轮验证与新EXE身份见最新接续和构建清单，不混用此前工具轮“不改游戏”的结论。

[本地地图批注页](docs/地图批注.html)保留五图A–E逐页批注；94条原始手写意见归档docs/map-review/feedback/2026-10-25-050407.json，R2底图版本50640cab687f。旧五图仍未接入游戏，当前草图01批准不等于它们全部已批准。D/E红实线是加速墙，红坡接触支撑现已补齐并在26验证，但这些草图的具体斜率/接缝/可达性仍未逐图验收。原14类部件的完整浏览器实测属于首版工具；本轮旧数据兼容和批注页Node回归通过，未改批注工具逻辑。

历史交接见docs/新对话交接.md，过程见docs/进度.md。行为/运行/验证变化同步本文件、README、已知问题及构建清单，与代码一起提交。
