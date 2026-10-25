# Portal Hop：项目现状与接续指南

最后整理：2026-10-25。先完整读本文件，再读AGENTS.md和README；按最新用户要求继续，不把历史计划当待做任务。

## 最新接续方向

已按用户通过portalhop-level-builder提交的新草图追加**第25关 THE SECOND ASCENT（二次蓄势），稳定ID52**。三段路线为：起点下落入底门→同一白斜面出门、按A收落点并在空中移动底门→第二次斜面出门松键，实际落右上台后走到终点。地形接齐，白坡约46.4°，底面外沿y400，终点台x680–930/y80；增加起点灰低顶限制起跳绕过二次蓄势，延长起点台避免斜面门下框挂角。普通物理/门规则和原24关数据未改，无新机关。

原件、修订JSON、原/修订对照网页、估算与独立标明的真实输入轨迹在[第25关设计目录](docs/level-editor/designs/2026-10-25-double-return/README.md)。原件SHA256为26534f984f16a76611c07f594e190749cfd7d87f65bdc525806a7836fcd8e0fc，ID1–10保留，新增灰低顶11/接缝帽沿12。图上参考门位不是定点吸附；未覆盖用户浏览器布局。

**本次36组实时完整回归、84个R/暂停压力案例通过，无运行错误或退出泄漏。** 新关名义+4组邻近门位均零死亡/两传送/实际落台胜利；不换底门、单次斜面直飞（含起跳）、双底门起跳向上发射等已测对照均未通关。传送中暂停/R清门回出生通过。名义出口总速约736→782px/s，落台约(705.51,64.93)，角色上沿最高约23.13px，无顶屏。独立只读审阅无重要问题，非所有巧解的穷尽证明。

GPU初始/两次出口/实际落台、导出包第3页5关及最终地图已查看。唯一EXE已导出，普通启动退出0，内嵌包25关身份及第25关同组真实路线/对照/R/暂停均通过。构建109332848字节，SHA256 E2129518599CA91CE228B5B7F34261F68F1D21021A263E762435E5D06CB471DE，见docs/build-manifest.txt。待用户评价空中放门/反向收速度的人手难度；未重测显示映射/旧24张图。

第24关上下怪保持x542/y54–363、出生y208.5向下、70px/s；路线②/③有危险相位，等待安全采样后仍可通关，本轮继续回归通过。[第24关小修记录](docs/level-editor/designs/2026-10-25-fall-bounce-guard/README.md)。原23关保留布局，其他五图A–E仍未实装。

已安装技能portalhop-level-builder，版本控制源skills/portalhop-level-builder，安装目录C:/Users/XH/.codex/skills/portalhop-level-builder。调用并提供设计JSON即授权自主校准至实装/测试/导出，普通只评图请求仍只评图，关键玩法语义不明时集中询问。技能封装轮仅做工具/格式/只读试用，未伪称当轮完成游戏端到端验证；本次为实际新关实施，细节见[技能入口](skills/portalhop-level-builder/SKILL.md)。

## 当前版本与约束

- Godot4.7.2/GDScript，Windows x64，单人离线、960×540固定单屏、120Hz、Compatibility。
- 当前源码25关。原50关按用户指令删除27关、保留23关后追加24/25；[编号对照](docs/编号对照.md)中1–24不变，第25追加新作，不复用被删编号。
- 选关3页（10/10/5），选关与NEXT直接入关。第24完成后NEXT到25，第25显示最终结算。无入关说明卡、建议圈、教程/机关说明菜单；准星、放门预览、枪线及机关反馈保留。
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

- levels/maps.gd唯一数量LEVEL_COUNT=25，get_level接受0..24；ROOM_IDS是稳定ID列表，不是另一套游玩编号，index_for_id用于迁移/测试。
- 原地图仍在maps/campaign/coating_rooms/laser_rooms/advanced_rooms；levels/designed_rooms.gd保存新增ID51/52。章节路由使用稳定ID减一，旧23关地形/机关源码未改。
- scenes/main.gd管菜单/分页/进度/结算及交互，将可选polygons交给门系统。actors/player.gd与world/materials.gd本轮未改；actors/sentry.gd支持可选vertical；portals/system.gd保留旧Rect2及凸多边形路径。
- 地图必需name/spawn/goal/blocks/faces/enemy，可选polygons:Array[PackedVector2Array]、guard/materials/mirrors/emitters/receivers/gates/movers/hazards。polygons仅凸多边形，面与外法线须贴合实体；不添加hint/guide/briefing。
- progress.order_version仍为2，存当前编号unlocked/音量；版本2按1..25限幅，不重复迁移。已有24解锁保持24，完成24后解锁25，不自动修改玩家进度。
- 缺版本的旧50关存档迁移到首个保留原ID≥旧最高解锁ID。旧12→新12（原14）、旧22→新17（原25）、旧49/50→新23，新增ID51/52不改变这些映射。
- 测试persistence_enabled=false，不写实际%APPDATA%/Godot/app_userdata/Portal Hop/progress.cfg。

## 验证与运行

本轮tests/run.ps1实时运行36组通过，84个重试压力案例通过（docs/final-all-tests.log、final-retry_stress.log）。double_return先确认旧代码缺少25失败；实装后5组真实门位路线、4项对照/绕路、传送中暂停和R通过，见final-double_return.log；旧24上下怪危险/安全相位及第三关踩踏等也继续通过。调试曾发现下落擦斜面门框而清落速，改起点台长度解决，未改碰撞或角色物理。

GPU新关/两次出口/落台记录见docs/double-return-preview，录制轨迹另存在设计目录；图形测试成功不代替导出版。普通EXE启动退出0，standalone-pack.log确认EMBEDDED_PROJECT及25关/最后白斜面，standalone-double-return.log用该内嵌包实际重跑新关全部案例通过。独立审阅见double-return-review.log，未穷尽自由放门/输入巧解，未重测显示映射（之前结果仅历史）。所有测试隔离真实进度。

```powershell
./tests/run.ps1
& ./tools/godot-4.7.2/Godot_v4.7.2-stable_win64_console.exe --path . --script tests/double_return.gd -- --capture
& ./tools/godot-4.7.2/Godot_v4.7.2-stable_win64_console.exe --path . --script tests/campaign_preview.gd
& ./tools/godot-4.7.2/Godot_v4.7.2-stable_win64_console.exe --path . --script tests/display.gd
& ./tools/godot-4.7.2/Godot_v4.7.2-stable_win64_console.exe --headless --path . --export-release 'Windows Desktop' builds/PortalHop.exe
```

GPU目录docs/double-return-preview（25关）、docs/sloped-preview（24关）及docs/curated-preview（当前新图/选关；其他图有旧版本历史），docs/campaign-preview为旧50关历史。构建大小/SHA256、启动/内嵌包身份统一见docs/build-manifest.txt。tools/builds忽略，新克隆须准备引擎/模板。实时回归不使用--fixed-fps120加速，避免音频线程清理计时失真。

## 创作工具与后续范围

[空白关卡编辑器](docs/关卡编辑器.html)保留14类部件、曲线预设路径、属性、撤销/重做、本机保存及JSON/PNG导入导出。网页只表达布局，不模拟碰撞/激光或自动求解；普通评图先计算并确认再实装，调用portalhop-level-builder则按最新授权自主完成分析至交付。本轮未覆盖浏览器用户布局。

[本地地图批注页](docs/地图批注.html)保留五图A–E逐页批注；94条原始手写意见归档docs/map-review/feedback/2026-10-25-050407.json，R2底图版本50640cab687f。旧五图仍未接入游戏，当前草图01批准不等于它们全部已批准。D/E红实线是加速墙，斜坡加速待另做。编辑器10项+批注页9项Node检查及浏览器实测属于此前工具版本，本轮未改工具逻辑。

历史交接见docs/新对话交接.md，过程见docs/进度.md。行为/运行/验证变化同步本文件、README、已知问题及构建清单，与代码一起提交。
