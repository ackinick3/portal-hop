# Portal Hop：项目现状与接续指南

最后整理：2026-10-25。先完整读本文件，再读AGENTS.md和README；按最新用户要求继续，不把历史计划当待做任务。

## 最新接续方向

用户已确认首份编辑器草图的比例修订，并要求“符合，开始”。已按批准方案追加**第24关 THE FALLING RETURN（落差折返），稳定ID51**：蓝面约57.4°、右白面约74.5°、底部白带120px，两侧灰地相接。原23关布局和稳定ID顺序保留；角色跑速、跳跃、重力、空中控制、蓝反弹公式及传送速度规则未改。没有加入方块、按钮、新激光或其余四份草图。

原稿与批准方案见[设计目录](docs/level-editor/designs/2026-10-25-fall-bounce/README.md)，input.json原样保留，adjusted.json与原/修订对照网页继续可用。[实施计划](docs/superpowers/plans/2026-10-25-slopes-and-room24.md)记录范围与检查。网页绿色路径仍是模型，真实结果以Godot测试为准。

标准路线：先从出生走到起点右沿放底门和右侧斜面门，再退回助跑；按D下落直到进底门，出门松横向键，碰左蓝面反弹，实际落上右平台后走到终点。R清门回出生，游戏内不添加解法提示。

新增凸多边形斜面实体、首表面射线、自由放门、完整72px真实碰撞开口及关闭复原；斜向出口按22×30直立角色的法线/切线投影留出空间。激光通过斜面门沿用首表面遮挡及出口法线。本轮只需要白斜面与蓝反弹；红斜坡加速仍未实现，不能把斜面碰撞能力当成所有斜坡材质已完成。

**本轮34组实时回归全部通过，81个暂停/R压力案例通过；GPU新关、24张全图、3页选关、窗口/全屏/鼠标映射均已检查，独立审阅无重要问题。唯一EXE已重新导出并通过普通启动（退出0）及内嵌包24关身份检查。** 该内嵌包的9组真实输入新关路线也全部通过（standalone-fall-bounce.log）。构建109332080字节，SHA256为F21D40F7F314E5ED3FC2014C8F040EFE5AF5E8ED168E70DC364F2CECA01B2C02，见docs/build-manifest.txt；待用户实际试玩评价容差。

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

原敌人规则保留，第三关普通跳跃踩踏仍合法。B圆润旗帜/终点门、动作反馈及固定音效池不变。可拿取的惯性方块、压力按钮、挡光及红色致死激光仍未实现。

## 工程与存档接续

- levels/maps.gd唯一数量LEVEL_COUNT=24，get_level接受0..23；ROOM_IDS是稳定ID列表，不是另一套游玩编号，index_for_id用于迁移/测试。
- 原地图仍在maps/campaign/coating_rooms/laser_rooms/advanced_rooms；levels/designed_rooms.gd保存新ID51。章节路由使用稳定ID减一，旧23关地形/机关源码未改。
- scenes/main.gd管菜单/分页/进度/结算及交互，将可选polygons交给门系统。actors/player.gd与world/materials.gd本轮未改；portals/system.gd保留旧Rect2并新增凸多边形路径。
- 地图必需name/spawn/goal/blocks/faces/enemy，可选polygons:Array[PackedVector2Array]、guard/materials/mirrors/emitters/receivers/gates/movers/hazards。polygons仅凸多边形，面与外法线须贴合实体；不添加hint/guide/briefing。
- progress.order_version仍为2，存当前编号unlocked/音量；版本2按1..24限幅，不重复迁移。已有23解锁保持23，完成23后解锁24，不自动修改玩家进度。
- 缺版本的旧50关存档迁移到首个保留原ID≥旧最高解锁ID。旧12→新12（原14）、旧22→新17（原25）、旧49/50→新23，新增ID51不改变这些映射。
- 测试persistence_enabled=false，不写实际%APPDATA%/Godot/app_userdata/Portal Hop/progress.cfg。

## 验证与运行

本轮重新运行原32组基线通过，见docs/baseline-before-slopes.log。新增测试在旧代码先失败：docs/slopes-before.log、fall-bounce-before.log；实现后8法线方向真实开口/门框/复原、射线遮挡/激光、真实角色双向通门通过。第24关9组门位扰动均一传送、蓝反弹、实际落台并零死亡通关；去蓝反弹同输入不通关，120px带拒绝双门，R/暂停通过。最终34组实时回归全部通过，无运行错误或退出泄漏：docs/final-all-tests.log；暂停/R压力81例通过。GPU新关/实际落台及选关第三页已核对，显示测试0失败并恢复原鼠标位置。普通EXE启动退出0，同版本Godot挂载该EXE的内嵌包直接进入全部24关且最后关有2块斜面，见standalone-pack.log。独立只读审阅无重要问题，见slopes-review.log；8方向真实角色测试覆盖中心穿越，未穷尽各角度极限切向偏移。

```powershell
./tests/run.ps1
& ./tools/godot-4.7.2/Godot_v4.7.2-stable_win64_console.exe --path . --script tests/fall_bounce.gd -- --capture
& ./tools/godot-4.7.2/Godot_v4.7.2-stable_win64_console.exe --path . --script tests/campaign_preview.gd
& ./tools/godot-4.7.2/Godot_v4.7.2-stable_win64_console.exe --path . --script tests/display.gd
& ./tools/godot-4.7.2/Godot_v4.7.2-stable_win64_console.exe --headless --path . --export-release 'Windows Desktop' builds/PortalHop.exe
```

GPU目录docs/sloped-preview（新关）和docs/curated-preview（当前全图/选关），docs/campaign-preview为旧50关历史。构建大小/SHA256、启动/内嵌包身份统一见docs/build-manifest.txt。tools/builds忽略，新克隆须准备引擎/模板。实时回归不使用--fixed-fps120加速，避免音频线程清理计时失真。

## 创作工具与后续范围

[空白关卡编辑器](docs/关卡编辑器.html)保留14类部件、曲线预设路径、属性、撤销/重做、本机保存及JSON/PNG导入导出。网页只表达布局，不模拟碰撞/激光或自动求解；提交JSON后助手计算、用户确认再实装。本轮未覆盖浏览器用户布局。

[本地地图批注页](docs/地图批注.html)保留五图A–E逐页批注；94条原始手写意见归档docs/map-review/feedback/2026-10-25-050407.json，R2底图版本50640cab687f。旧五图仍未接入游戏，当前草图01批准不等于它们全部已批准。D/E红实线是加速墙，斜坡加速待另做。编辑器10项+批注页9项Node检查及浏览器实测属于此前工具版本，本轮未改工具逻辑。

历史交接见docs/新对话交接.md，过程见docs/进度.md。行为/运行/验证变化同步本文件、README、已知问题及构建清单，与代码一起提交。
