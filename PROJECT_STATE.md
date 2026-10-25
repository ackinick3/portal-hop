# Portal Hop：项目现状与接续指南

最后整理：2026-10-25。先完整读本文件，再读AGENTS.md和README；按最新用户要求继续，不把历史计划当待做任务。

## 最新接续方向

已按用户通过portalhop-level-builder提交的新草图追加**第26关 THE CRIMSON ARC（赤坡接力），稳定ID53**。四段路线：红跑道与红坡蓄速→自然起飞越刺坑进右白坡门→左白坡出门落蓝台→自动反弹上右终点。红坡校准约16.7°，蓝台外沿y250/x400–550，终点台y100/x650–820；墙段接齐，标记落到台面，原25关地图数据未改。

必要底层支撑：此前只检测向上脚底红材质，实测红坡会掉速。player现在仅在grounded、碰撞法线匹配floor且接触点命中红patch时沿真实切线驱动，仍用目标650/按键1800/松键2300；水平和非红路径、普通参数、蓝反弹和传送公式不改。未扩大可行走坡度，竖直红墙不当作跑道。底层测试先失败后通过，含坡上松键刹车再起步；反向/坡上跳跃/混材边界未专项穷尽。

原件/修订JSON/对照网页/实测轨迹与计算分列摘要见[第26关设计目录](docs/level-editor/designs/2026-10-25-boost-bounce/README.md)。原件SHA256 b59347f2cef8bf34fda51685165d3ce19a59baa6937d3da7140c2bdeae25c5ab，17部件ID1–17和nextId18保留，未覆盖用户浏览器布局。标准按D蓄速，在坡上放两门，传送后松横向键，蓝台自动反弹，实际落台后向右到终点，无需跳跃键。

**本次38组实时完整回归、87例R/暂停压力通过，无运行错误或退出泄漏。** 新关名义+4附近门位均0死亡/1传送/1蓝反弹/真实落台胜利；缺红同输入死于刺坑，缺蓝只留中台，暂停/R复位通过。名义落台约(712.26,84.93)，最高身体上沿约16.4px，无顶屏。独立只读审阅无重要问题，不代表全部巧解或人手难度认可。

GPU起点/离坡/出门/反弹/落台与内嵌包第三页6关已查看。唯一EXE已更新，普通启动退出0，内嵌包26关/保留24怪与25地图/最后3斜面身份及新关同组真实输入全部通过。构建109334176字节，SHA256 4D4D7D28A3844E5FFAC4B39E339E1B5EA42DFC2C59375DCF55DCBED870FC023D，详见docs/build-manifest.txt。真实存档未写；未重测显示映射/旧25张图，坡上快速放门的人手容差待反馈。

第24关上下怪与危险/安全相位、第25关二次蓄势/灰低顶/空中换底门保持，本轮继续回归通过。[24记录](docs/level-editor/designs/2026-10-25-fall-bounce-guard/README.md)、[25记录](docs/level-editor/designs/2026-10-25-double-return/README.md)。原五图A–E仍未实装，红坡支撑不等于它们已验收。

技能portalhop-level-builder已安装，版本控制源skills/portalhop-level-builder，安装目录C:/Users/XH/.codex/skills/portalhop-level-builder。提供JSON调用即授权保持思路自主校准/实装/测试/导出；仅评图仍只评图，关键玩法语义不明时询问。[技能入口](skills/portalhop-level-builder/SKILL.md)。

## 当前版本与约束

- Godot4.7.2/GDScript，Windows x64，单人离线、960×540固定单屏、120Hz、Compatibility。
- 当前源码26关。原50关按用户指令删除27关、保留23关后追加24/25/26；[编号对照](docs/编号对照.md)中1–25不变，第26追加新作，不复用被删编号。
- 选关3页（10/10/6），选关与NEXT直接入关。第25完成后NEXT到26，第26显示最终结算。无入关说明卡、建议圈、教程/机关说明菜单；准星、放门预览、枪线及机关反馈保留。
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
| 门锁/平台 | 所需信号全亮动作；真实碰撞、往返/齿轮双轨、承载及扫掠避碰；平台不放门 |
| 重试/暂停 | R计死亡并清门/阶段/材质计数/接收器，门关闭、平台复位；暂停冻结，RESTART另清计时/死亡 |

怪物沿用70px/s及原侧碰死亡/向下踩踏规则；guard.vertical默认为false，只有24关开启上下巡逻，第三关普通跳跃踩踏仍合法。B圆润旗帜/终点门、动作反馈及固定音效池不变。可拿取的惯性方块、压力按钮、挡光及红色致死激光仍未实现。

## 工程与存档接续

- levels/maps.gd唯一数量LEVEL_COUNT=26，get_level接受0..25；ROOM_IDS是稳定ID列表，不是另一套游玩编号，index_for_id用于迁移/测试。
- 原地图仍在maps/campaign/coating_rooms/laser_rooms/advanced_rooms；levels/designed_rooms.gd保存新增ID51/52/53。章节路由使用稳定ID减一，旧23关地形/机关源码未改。
- scenes/main.gd管菜单/分页/进度/结算及交互，将可选polygons交给门系统。actors/player.gd新增红坡接触/切向分支，world/materials.gd未改；actors/sentry.gd支持可选vertical；portals/system.gd保留旧Rect2及凸多边形路径。
- 地图必需name/spawn/goal/blocks/faces/enemy，可选polygons:Array[PackedVector2Array]、guard/materials/mirrors/emitters/receivers/gates/movers/hazards。polygons仅凸多边形，面与外法线须贴合实体；不添加hint/guide/briefing。
- progress.order_version仍为2，存当前编号unlocked/音量；版本2按1..26限幅，不重复迁移。已有25解锁保持25，完成25后解锁26，不自动修改玩家进度。
- 缺版本的旧50关存档迁移到首个保留原ID≥旧最高解锁ID。旧12→新12（原14）、旧22→新17（原25）、旧49/50→新23，新增ID51/52/53不改变这些映射。
- 测试persistence_enabled=false，不写实际%APPDATA%/Godot/app_userdata/Portal Hop/progress.cfg。

## 验证与运行

本轮tests/run.ps1实时38组通过（final-all-tests.log），重试压力87例通过。slope_boost旧代码实测出口约(277,+30)/红距离196失败，新版坡上加速/松键刹车/再加速自然离坡通过；boost_bounce先确认旧版缺26失败，后5组真实门位完整通关、缺红/缺蓝对照、传送中暂停/R通过。旧25关路线/基础动作/水平红地/蓝反弹/光路/平台/旧存档均继续回归通过。

GPU新关实际节点/落台在docs/boost-bounce-preview，精确轨迹另归档设计目录，与拟合曲线和解析目标速度分开。普通EXE启动退出0，standalone-pack.log确认26关身份/24怪/25图，standalone-boost-bounce.log在该内嵌包实际重跑同组新关检查通过。审阅见boost-bounce-review.log；反向红坡/坡上跳跃/混材未专项覆盖、自由门位巧解未穷尽，未重测显示映射（旧结果仅历史）。所有测试隔离真实进度。

```powershell
./tests/run.ps1
& ./tools/godot-4.7.2/Godot_v4.7.2-stable_win64_console.exe --path . --script tests/boost_bounce.gd -- --capture
& ./tools/godot-4.7.2/Godot_v4.7.2-stable_win64_console.exe --path . --script tests/campaign_preview.gd
& ./tools/godot-4.7.2/Godot_v4.7.2-stable_win64_console.exe --path . --script tests/display.gd
& ./tools/godot-4.7.2/Godot_v4.7.2-stable_win64_console.exe --headless --path . --export-release 'Windows Desktop' builds/PortalHop.exe
```

GPU目录docs/boost-bounce-preview（26关）、docs/double-return-preview（25关）、docs/sloped-preview（24关）及docs/curated-preview（当前新图/选关；其他图有旧版本历史），docs/campaign-preview为旧50关历史。构建大小/SHA256、启动/内嵌包身份统一见docs/build-manifest.txt。tools/builds忽略，新克隆须准备引擎/模板。实时回归不使用--fixed-fps120加速，避免音频线程清理计时失真。

## 创作工具与后续范围

[空白关卡编辑器](docs/关卡编辑器.html)保留14类部件、曲线预设路径、属性、撤销/重做、本机保存及JSON/PNG导入导出。网页只表达布局，不模拟碰撞/激光或自动求解；普通评图先计算并确认再实装，调用portalhop-level-builder则按最新授权自主完成分析至交付。本轮未覆盖浏览器用户布局。

[本地地图批注页](docs/地图批注.html)保留五图A–E逐页批注；94条原始手写意见归档docs/map-review/feedback/2026-10-25-050407.json，R2底图版本50640cab687f。旧五图仍未接入游戏，当前草图01批准不等于它们全部已批准。D/E红实线是加速墙，红坡接触支撑现已补齐并在26验证，但这些草图的具体斜率/接缝/可达性仍未逐图验收。编辑器10项+批注页9项Node检查及浏览器实测属于此前工具版本，本轮未改工具逻辑。

历史交接见docs/新对话交接.md，过程见docs/进度.md。行为/运行/验证变化同步本文件、README、已知问题及构建清单，与代码一起提交。
