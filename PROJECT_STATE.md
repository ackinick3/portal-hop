# Portal Hop：项目现状与接续指南

最后整理：2026-10-25。先完整读本文件，再读AGENTS.md和README；按最新用户要求继续，不把历史计划当待做任务。

## 最新接续方向

当前开发轮：用户调用portalhop-level-builder，已按最新09-44-35四箭头JSON追加第27关THE WANDERING FINISH（流动终点），稳定ID54。路线为起点跳跃入底门→左白竖门水平跨刺坑/上下怪→红跑道换右竖/斜门→真实落上移动终点。原18个部件ID、nextId21与四箭头顺序保留；此前09-32-09无箭头版另存。原1–26地图和普通人物物理未改。

新图及比例：[对照网页/修订JSON/精确GPU轨迹](docs/level-editor/designs/2026-10-25-wandering-goal/README.md)。最新原件SHA256 38F81B86207D686739C43AFAC272B39982831C7DC6E7C537F13CC6078ED88A3B。红台左沿移至500/台顶350、右白斜面45°并升高、竖白墙留足完整门宽；灰平台宽180、中心380→850/50px/s。原平台开头约5px抖动校准为直线，终点落在台顶90并跟随真实碰撞体。光幕上端接y0，修复实际复现的“起跳绕上端预放斜门单传送过关”捷径。

运行支撑：gun_screens只接公共枪线首碰，挡预览/实际/反射枪线，人/激光不新增碰撞或伤害。goal_mover/goal_offset跟随灰平台，并要求真实站上该平台才可完成。两组机制测试先失败后通过，共线射线和死亡动画跟随也先复现再修。未顺带实现本图没用的蓝/红平台或多折点运动。

当前已核验：7组标准/附近门位/短延迟均0死亡、2传送及实际落台；无红/仅首传送/直放斜门对照不完成。晚出发330帧会在首段碰怪死亡，300帧可踩怪，均沿用旧规则。R、暂停和死亡复位通过。GPU初始、两出口、实际落台已查看；名义落台(527.74,74.93)，首出口速度735，次出口(-459.62,-459.62)，全程身体上沿最高约18.05。独立只读审阅无重要代码问题，指出图稿光幕旧值已重生成并核对。

本轮41组实时完整回归、90例重试/暂停压力通过，无运行错误/退出泄漏；日志docs/wandering-all-tests.log及final-*.log。唯一EXE已导出27关，普通EXE菜单启动退出0，内嵌包27关/旧24怪/25–26地图与新27移动目标身份通过。构建109336672字节，SHA256 CFC1B7527CC21BF129E8A37EE42B87B3B3707FFBAC4574047754BC28ADA580D2。内嵌包同组7条标准/扰动路线及去红/首段/直放斜门/怪物/R/暂停检查通过；最终身份见构建清单。真实进度文件仍45字节/2026-10-24 19:08:28，用户原浏览器file布局未操作。

### 此前第26关版本记录

已按用户通过portalhop-level-builder提交的新草图追加**第26关 THE CRIMSON ARC（赤坡接力），稳定ID53**。四段路线：红跑道与红坡蓄速→自然起飞越刺坑进右白坡门→左白坡出门落蓝台→自动反弹上右终点。红坡校准约16.7°，蓝台外沿y250/x400–550，终点台y100/x650–820；墙段接齐，标记落到台面，原25关地图数据未改。

必要底层支撑：此前只检测向上脚底红材质，实测红坡会掉速。player现在仅在grounded、碰撞法线匹配floor且接触点命中红patch时沿真实切线驱动，仍用目标650/按键1800/松键2300；水平和非红路径、普通参数、蓝反弹和传送公式不改。未扩大可行走坡度，竖直红墙不当作跑道。底层测试先失败后通过，含坡上松键刹车再起步；反向/坡上跳跃/混材边界未专项穷尽。

原件/修订JSON/对照网页/实测轨迹与计算分列摘要见[第26关设计目录](docs/level-editor/designs/2026-10-25-boost-bounce/README.md)。原件SHA256 b59347f2cef8bf34fda51685165d3ce19a59baa6937d3da7140c2bdeae25c5ab，17部件ID1–17和nextId18保留，未覆盖用户浏览器布局。标准按D蓄速，在坡上放两门，传送后松横向键，蓝台自动反弹，实际落台后向右到终点，无需跳跃键。

**本次38组实时完整回归、87例R/暂停压力通过，无运行错误或退出泄漏。** 新关名义+4附近门位均0死亡/1传送/1蓝反弹/真实落台胜利；缺红同输入死于刺坑，缺蓝只留中台，暂停/R复位通过。名义落台约(712.26,84.93)，最高身体上沿约16.4px，无顶屏。独立只读审阅无重要问题，不代表全部巧解或人手难度认可。

GPU起点/离坡/出门/反弹/落台与内嵌包第三页6关已查看。唯一EXE已更新，普通启动退出0，内嵌包26关/保留24怪与25地图/最后3斜面身份及新关同组真实输入全部通过。构建109334176字节，SHA256 4D4D7D28A3844E5FFAC4B39E339E1B5EA42DFC2C59375DCF55DCBED870FC023D，详见docs/build-manifest.txt。真实存档未写；未重测显示映射/旧25张图，坡上快速放门的人手容差待反馈。

第24关上下怪与危险/安全相位、第25关二次蓄势/灰低顶/空中换底门保持，本轮继续回归通过。[24记录](docs/level-editor/designs/2026-10-25-fall-bounce-guard/README.md)、[25记录](docs/level-editor/designs/2026-10-25-double-return/README.md)。原五图A–E仍未实装，红坡支撑不等于它们已验收。

技能portalhop-level-builder已安装，版本控制源skills/portalhop-level-builder，安装目录C:/Users/XH/.codex/skills/portalhop-level-builder。提供JSON调用即授权保持思路自主校准/实装/测试/导出；仅评图仍只评图，关键玩法语义不明时询问。[技能入口](skills/portalhop-level-builder/SKILL.md)。

## 当前版本与约束

- Godot4.7.2/GDScript，Windows x64，单人离线、960×540固定单屏、120Hz、Compatibility。
- 当前源码27关。原50关按用户指令删除27关、保留23关后追加24/25/26/27；[编号对照](docs/编号对照.md)保留原顺序，新增稳定ID54，不复用被删编号。
- 选关3页（10/10/7），选关与NEXT直接入关。第26完成后NEXT到27，第27显示最终结算。无入关说明卡、建议圈、教程/机关说明菜单；准星、放门预览、枪线及机关反馈保留。
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
| 阻枪光幕/移动终点 | 光幕只挡枪线（含反射），人/激光沿用原规则；移动终点跟随真实灰平台，实际落台后才可完成 |
| 重试/暂停 | R计死亡并清门/阶段/材质计数/接收器，门关闭、平台复位；暂停冻结，RESTART另清计时/死亡 |

怪物沿用70px/s及原侧碰死亡/向下踩踏规则；guard.vertical默认为false，24/27关开启上下巡逻，第三关普通跳跃踩踏仍合法。B圆润旗帜/终点门、动作反馈及固定音效池不变。可拿取的惯性方块、压力按钮、用于连续激光的挡光和红色致死激光仍未实现。

## 工程与存档接续

- levels/maps.gd唯一数量LEVEL_COUNT=27，get_level接受0..26；ROOM_IDS是稳定ID列表，不是另一套游玩编号，index_for_id用于迁移/测试。
- 原地图仍在maps/campaign/coating_rooms/laser_rooms/advanced_rooms；levels/designed_rooms.gd保存新增ID51/52/53/54。章节路由使用稳定ID减一，旧26关地图数据未改。
- scenes/main.gd管菜单/分页/进度/结算及交互，将可选polygons交给门系统。actors/player.gd新增红坡接触/切向分支，world/materials.gd未改；actors/sentry.gd支持可选vertical；portals/system.gd保留旧Rect2及凸多边形路径。
- 地图必需name/spawn/goal/blocks/faces/enemy，可选polygons:Array[PackedVector2Array]、guard/materials/mirrors/emitters/receivers/gates/movers/hazards/gun_screens。移动终点用goal_mover（movers索引）及goal_offset（相对平台左上角）绑定；polygons仅凸多边形，面与外法线须贴合实体；不添加hint/guide/briefing。
- progress.order_version仍为2，存当前编号unlocked/音量；版本2按1..27限幅，不重复迁移。已有26解锁保持26，完成26后解锁27，不自动修改玩家进度。
- 缺版本的旧50关存档迁移到首个保留原ID≥旧最高解锁ID。旧12→新12（原14）、旧22→新17（原25）、旧49/50→新23，新增ID51/52/53/54不改变这些映射。
- 测试persistence_enabled=false，不写实际%APPDATA%/Godot/app_userdata/Portal Hop/progress.cfg。

## 验证与运行

最新第27关轮：tests/run.ps1实际41组通过，90例压力通过；新gun_screen、moving_goal先失败后通过，真实wandering_goal含7组完整路线、危险相位、去红/首段/直放斜门对照与R/暂停。GPU全组通过，并单独捕获无遮挡落台画面，截图已解码查看；对照页原/修订切换及实际下载JSON与修订稿一致。输入两版SHA、18IDs/nextId21、4条实际路径、HTML脚本/JSON、SVG/链接、41组runner及22项工具回归通过。

普通EXE菜单启动（--quit-after120）退出0，包内27关身份与第三页7关图已查看；包内同组新关实际路线与对照/R/暂停均通过，退出0且无运行错误/泄漏。最新GPU在docs/wandering-goal-preview，设计/实测在2026-10-25-wandering-goal，具体源/包内/导出/审阅日志统一见docs/build-manifest.txt。以下第26关38组/87例和对应旧构建结果为此前版本，不替代本轮检查。未重跑显示映射、未逐张重拍旧26图，有限门位/相位不代表所有巧解或人手难度认可。

第26关实现轮tests/run.ps1实时38组通过（final-all-tests.log），重试压力87例通过。slope_boost旧代码实测出口约(277,+30)/红距离196失败，新版坡上加速/松键刹车/再加速自然离坡通过；boost_bounce先确认旧版缺26失败，后5组真实门位完整通关、缺红/缺蓝对照、传送中暂停/R通过。旧25关路线/基础动作/水平红地/蓝反弹/光路/平台/旧存档均继续回归通过。

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

[空白关卡编辑器](docs/关卡编辑器.html)现有16类部件；移动平台与阻枪光幕支持JSON/绘制/属性/轨迹编辑，保留曲线预设路径、撤销/重做、本机保存及JSON/PNG导入导出。网页只表达布局，不模拟运动/碰撞/激光或自动求解；普通评图先计算并确认再实装，调用portalhop-level-builder则按最新授权自主完成分析至交付。第27关已接灰色线性平台/移动终点/阻枪光幕；蓝红平台和多折点运行支撑未在本图实现，不能从编辑器支持推断游戏已支持。

此前工具轮编辑器13项+旧批注页9项Node检查及新部件浏览器放置/属性/轨迹/存储/导出实测通过，工具轮当时游戏未变。第27关轮上述22项工具检查再次通过，未改编辑器网页或用户原file布局；新的对照网页独立测试原/修订切换与下载，并比对修订JSON。游戏本轮验证与新EXE身份见最新接续和构建清单，不混用此前工具轮“不改游戏”的结论。

[本地地图批注页](docs/地图批注.html)保留五图A–E逐页批注；94条原始手写意见归档docs/map-review/feedback/2026-10-25-050407.json，R2底图版本50640cab687f。旧五图仍未接入游戏，当前草图01批准不等于它们全部已批准。D/E红实线是加速墙，红坡接触支撑现已补齐并在26验证，但这些草图的具体斜率/接缝/可达性仍未逐图验收。原14类部件的完整浏览器实测属于首版工具；本轮旧数据兼容和批注页Node回归通过，未改批注工具逻辑。

历史交接见docs/新对话交接.md，过程见docs/进度.md。行为/运行/验证变化同步本文件、README、已知问题及构建清单，与代码一起提交。
