# Portal Hop：项目现状与接续指南

最后整理：2026-10-25。先完整读本文件，再读AGENTS.md和README；按最新用户要求继续，不把历史计划当待做任务。

## 最新接续方向

用户最新要求“小修24关，增加一个上下移动的怪，让路线二三可能碰到”。已按新JSON增加本关guard：x542、y54–363上下往返，出生y208.5向下，速度沿用70px/s。地形、普通物理、编号/存档不变；旧怪默认水平巡逻。原稿/修订稿及对照图在docs/level-editor/designs/2026-10-25-fall-bounce-guard。新原稿怪物ID15与旧修订补灰地冲突，修订稿使用ID17，旧地形ID保留。

本轮35组实时回归全部通过，81个重试案例通过，无运行错误/退出泄漏。安全出发采样下9组门位偏差及两个邻近出发时机均零死亡通关；另两个真实输入时机分别在路线②/③碰撞死亡。暂停/R/死亡与旧第三关水平/踩踏回归通过，独立审阅无重要问题。GPU画面、普通EXE启动（退出0）、内嵌包24关/新怪身份与同组真实路线全部验证。唯一EXE已更新：109332384字节，SHA256 A28B44DD243D5A0E48B3BB3527F331E2D50CF81E2C8EC60CFB1A4EE7E9501337，见docs/build-manifest.txt。原无怪版相同出发时机的容差保证已被动态障碍取代；待用户试玩评价观察/等待难度。

已按用户要求封装并安装`portalhop-level-builder`技能；版本控制源在skills/portalhop-level-builder，安装于C:/Users/XH/.codex/skills/portalhop-level-builder。调用时提交设计器JSON，授权保持原思路自主分析/调整比例、实装、真实通关/容差/重试/回归、更新唯一EXE并汇报，不默认停在比例确认。仅评图的请求仍只评图；关键玩法语义不明时集中询问，继续其余分析。原稿保留、普通物理与真实存档保护不变，不给未定义激光颜色发明玩法。

此前技能封装轮只改技能/文档，3项工具测试、格式与只读试用通过；游戏状态以本次怪物版35组结果为准。技能细节见[技能入口](skills/portalhop-level-builder/SKILL.md)。

用户已确认首份编辑器草图的比例修订，并要求“符合，开始”。已按批准方案追加**第24关 THE FALLING RETURN（落差折返），稳定ID51**：蓝面约57.4°、右白面约74.5°、底部白带120px，两侧灰地相接。原23关布局和稳定ID顺序保留；角色跑速、跳跃、重力、空中控制、蓝反弹公式及传送速度规则未改。没有加入方块、按钮、新激光或其余四份草图。

原稿与批准方案见[设计目录](docs/level-editor/designs/2026-10-25-fall-bounce/README.md)，input.json原样保留，adjusted.json与原/修订对照网页继续可用。[实施计划](docs/superpowers/plans/2026-10-25-slopes-and-room24.md)记录范围与检查。网页绿色路径仍是模型，真实结果以Godot测试为准。

标准路线：先从出生走到起点右沿放底门和右侧斜面门，再退回助跑；按D下落直到进底门，出门松横向键，碰左蓝面反弹，实际落上右平台后走到终点。新增上下怪后可先观察巡逻时机再助跑；R清门回出生并复位怪物，游戏内不添加解法提示。

新增凸多边形斜面实体、首表面射线、自由放门、完整72px真实碰撞开口及关闭复原；斜向出口按22×30直立角色的法线/切线投影留出空间。激光通过斜面门沿用首表面遮挡及出口法线。本轮只需要白斜面与蓝反弹；红斜坡加速仍未实现，不能把斜面碰撞能力当成所有斜坡材质已完成。

首次无怪版曾通过34组/81例及GPU/显示/导出；该轮构建109332080字节，SHA256为F21D40F7F314E5ED3FC2014C8F040EFE5AF5E8ED168E70DC364F2CECA01B2C02，属于历史身份。本次怪物版的检查和构建身份在顶部及build-manifest单独更新，不沿用无怪版结论。

## 当前版本与约束

- Godot4.7.2/GDScript，Windows x64，单人离线、960×540固定单屏、120Hz、Compatibility。
- 当前源码24关。原50关按用户指令删除27关、保留23关后追加本关；[编号对照](docs/编号对照.md)中1–23不变，第24为新作，不复用被删编号。
- 选关3页（10/10/4），选关与NEXT直接入关。第23完成后NEXT到24，第24才显示最终结算。无入关说明卡、建议圈、教程/机关说明菜单；准星、放门预览、枪线及机关反馈保留。
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
| 红材质 | 水平脚下按住A/D以1800加速至650，松键2300；离面保留高速，普通地面恢复原规则 |
| 绿材质 | 枪线等角反射最多8次，共用首实体路径；不反射激光；本轮未扩展绿色斜面 |
| 激光/接收器 | 真实双门转向沿出口法线，2px边缘余量，最多16跳/4000px；真实无遮挡照射后锁存至R |
| 门锁/平台 | 所需信号全亮动作；真实碰撞、往返/齿轮双轨、承载及扫掠避碰；平台不放门 |
| 重试/暂停 | R计死亡并清门/阶段/材质计数/接收器，门关闭、平台复位；暂停冻结，RESTART另清计时/死亡 |

怪物沿用70px/s及原侧碰死亡/向下踩踏规则；guard.vertical默认为false，只有24关开启上下巡逻，第三关普通跳跃踩踏仍合法。B圆润旗帜/终点门、动作反馈及固定音效池不变。可拿取的惯性方块、压力按钮、挡光及红色致死激光仍未实现。

## 工程与存档接续

- levels/maps.gd唯一数量LEVEL_COUNT=24，get_level接受0..23；ROOM_IDS是稳定ID列表，不是另一套游玩编号，index_for_id用于迁移/测试。
- 原地图仍在maps/campaign/coating_rooms/laser_rooms/advanced_rooms；levels/designed_rooms.gd保存新ID51。章节路由使用稳定ID减一，旧23关地形/机关源码未改。
- scenes/main.gd管菜单/分页/进度/结算及交互，将可选polygons交给门系统。actors/player.gd与world/materials.gd本轮未改；actors/sentry.gd支持可选vertical；portals/system.gd保留旧Rect2及凸多边形路径。
- 地图必需name/spawn/goal/blocks/faces/enemy，可选polygons:Array[PackedVector2Array]、guard/materials/mirrors/emitters/receivers/gates/movers/hazards。polygons仅凸多边形，面与外法线须贴合实体；不添加hint/guide/briefing。
- progress.order_version仍为2，存当前编号unlocked/音量；版本2按1..24限幅，不重复迁移。已有23解锁保持23，完成23后解锁24，不自动修改玩家进度。
- 缺版本的旧50关存档迁移到首个保留原ID≥旧最高解锁ID。旧12→新12（原14）、旧22→新17（原25）、旧49/50→新23，新增ID51不改变这些映射。
- 测试persistence_enabled=false，不写实际%APPDATA%/Godot/app_userdata/Portal Hop/progress.cfg。

## 验证与运行

本次35组实时全回归通过（docs/final-all-tests.log），81个R/暂停压力案例通过。新vertical_guard检查上下折返/范围、暂停、死亡复位及第三关仍水平；fall_bounce从出生真实输入验证9门位在安全相位下零死亡通关，290/350帧邻近安全采样也通关，80/200帧分别在路线②/③碰撞死亡。上述等待值为准备门和退回助跑位置后的开发夹具，非关内提示或保证所有连续相位安全。

GPU新怪、反弹、实际落台已查看；普通EXE启动退出0，内嵌包24关/最后2斜面及新怪身份检查通过，内嵌包同组真实路线也通过。独立审阅无重要问题，详见vertical-guard-review.log。未重测显示/其他23张图；旧显示测试属于首次实装轮。真实存档未写入。首次斜面基线和无怪版结果留于进度/计划，不替代本次结果；当前8方向斜面回归仍通过，极限切向偏移及全部巧解未穷尽。
```powershell
./tests/run.ps1
& ./tools/godot-4.7.2/Godot_v4.7.2-stable_win64_console.exe --path . --script tests/fall_bounce.gd -- --capture
& ./tools/godot-4.7.2/Godot_v4.7.2-stable_win64_console.exe --path . --script tests/campaign_preview.gd
& ./tools/godot-4.7.2/Godot_v4.7.2-stable_win64_console.exe --path . --script tests/display.gd
& ./tools/godot-4.7.2/Godot_v4.7.2-stable_win64_console.exe --headless --path . --export-release 'Windows Desktop' builds/PortalHop.exe
```

GPU目录docs/sloped-preview（新关）和docs/curated-preview（当前全图/选关），docs/campaign-preview为旧50关历史。构建大小/SHA256、启动/内嵌包身份统一见docs/build-manifest.txt。tools/builds忽略，新克隆须准备引擎/模板。实时回归不使用--fixed-fps120加速，避免音频线程清理计时失真。

## 创作工具与后续范围

[空白关卡编辑器](docs/关卡编辑器.html)保留14类部件、曲线预设路径、属性、撤销/重做、本机保存及JSON/PNG导入导出。网页只表达布局，不模拟碰撞/激光或自动求解；普通评图先计算并确认再实装，调用portalhop-level-builder则按最新授权自主完成分析至交付。本轮未覆盖浏览器用户布局。

[本地地图批注页](docs/地图批注.html)保留五图A–E逐页批注；94条原始手写意见归档docs/map-review/feedback/2026-10-25-050407.json，R2底图版本50640cab687f。旧五图仍未接入游戏，当前草图01批准不等于它们全部已批准。D/E红实线是加速墙，斜坡加速待另做。编辑器10项+批注页9项Node检查及浏览器实测属于此前工具版本，本轮未改工具逻辑。

历史交接见docs/新对话交接.md，过程见docs/进度.md。行为/运行/验证变化同步本文件、README、已知问题及构建清单，与代码一起提交。
