# Portal Hop：项目现状与接续指南

最后整理：2026-10-25。新对话先完整读本文件、AGENTS.md和README，再按用户当前要求继续。历史计划不是待做任务清单。

## 当前状态与本轮授权

- 工程：`D:\常用文件\codex_project\pop_Mario开发`；Godot4.7.2/GDScript，Windows x64、单人离线、960×540固定单屏。
- 用户明确要求自主设计、解决问题并一路开发到第五十关，无需再等待设计确认。本轮已接入全部五十张地图；**33组最终全量回归通过，唯一EXE已同步为五十关；构建身份见docs/build-manifest.txt**。
- 原前八关地图保持不变。第七关上一轮已提高自然落差并避开高台底面，标准上冲后立即D；第八关预放双门后持续D。旧物理与难度认可不代表本轮新增内容已获人手验收。
- 第九关：刺海上三次地板门接力；上冲高点用真实视线窗口打到下一平台。第十关蓝色弹性教学，第十一关红色加速＋传送门。第十二至十四仅蓝材质、第十五至十七仅红材质，第十八至十九混合。
- 用户已明确回复：单材质关仍可使用传送门。蓝面自动反弹由自主设计授权选定；加速材质按后续指令采用红色，覆盖最初粉色称呼。
- 最新指令将第二十关改为激光教学；二十至二十五激光解谜，二十六至三十五每关混用蓝弹性、红加速和激光，三十六至五十引入绿色枪线反射、带齿轮/轨道的真实移动平台并组合旧机关。第50关串联反射、双接收器、渡台、蓝反弹、红跑道及末段跳跃。
- 保留B圆润科技旗帜/拱门、程序化音效。关内无顶部HUD和文字标签，只有图形建议圈、预览、射击轨迹和机关线路；菜单、说明卡与结算为英文。
- 下一步等待用户试玩与提出修改意见，不自动开发第51关。自动路线证明实际可通，不等于人手难度认可。
- 持续交付同一个`builds/PortalHop.exe`，桌面`C:\Users\XH\Desktop\Portal Hop.lnk`指向它。不并列产生版本EXE；历史用Git保留。若试玩占用文件，等待关闭后替换，不擅自终止用户游戏。

## 规则和参数

| 项目 | 当前实现 |
|---|---|
| 视野/物理 | 960×540，默认1280×720，异比例留边，Compatibility，120Hz |
| 普通地面 | 跑速210，起跑/反向1400，松键减速2300；满速滑行约8.71px |
| 普通跳跃 | -330，重力900；土狼/缓冲0.1秒；按住跳得更高 |
| 空中 | 按键380有限调整；松水平键仅横向90向0减速，竖直不阻尼，不截断高速 |
| 门 | 72px真实碰撞开口；有效浅色面自由放置，同色替换；射线首个实体遮挡 |
| 传送速度 | `v_out=length(v_in)*n_out`，出口只保留总速度并沿外法线，清除切向速度 |
| 边缘 | 整扇门沿同一面向内贴齐，再验净空/间距；短面、堵塞或重叠拒绝且保留旧门 |
| 蓝弹性面 | 接触自动反弹，采用碰撞前速度，保留切向分量；地板最低法向580、其他面420，法向最高900；不是普通跳跃参数改变 |
| 红加速面 | 地板上按住A/D以1800加速到650；松键2300刹车；离面保留高速，普通地面恢复普通规则 |
| 绿色反射面 | 按等角反射枪线，最多8次；仅实际首个绿色实体面可反射。预览/射击同源，不能穿墙；绿色不反射激光 |
| 激光 | 持续琥珀色光束，经已激活双门的真实开口转向，从出口法线射出；保留入射横向位置，边缘留2px，最多16跳/4000px，单门/实墙阻挡 |
| 接收器 | 实际光束命中且无遮挡才点亮，锁存至R/重启；联动门或平台，多信号要求全部点亮。激光是非致命解谜工具 |
| 移动平台 | AnimatableBody2D实体承载，恒速往返、扫掠避碰/防挤压；齿轮转动，两轮各自的背景凹槽显示真实轨迹；本版不在平台上放门 |
| 敌人 | 巡逻70，侧碰即死；上方下落踩踏击败并以-300反弹；第三关普通跳跃路线仍合法 |
| 重试 | R计死亡，回出生、清门/阶段/材质计数、清接收器锁存、关门、平台归起始相位；暂停RESTART另清计时/死亡 |

普通移动/跳跃/重力未为新关暗改。材料只在地图明确涂层范围生效。彩色面不放门，浅色面放门。移动物体也阻挡枪线/激光；若已放门的出口后来被移动物体占据，拒绝穿越、把角色留在入口安全侧并保留切向速度，不传送进实体。

操作：A/D、Space、左右鼠标红/蓝门、R、Esc、F11。主菜单HOW TO PLAY另有MATERIALS & MACHINES图例。选关5页，每页10关，锁定状态保留；第6–50关均有各自说明卡，R/暂停重启直接重试。

## 从哪里接着开发

| 文件 | 职责 |
|---|---|
| `levels/maps.gd` | `LEVEL_COUNT=50`唯一数量来源；原索引0..7明确保留，其他委托章节；无效索引空字典 |
| `levels/campaign.gd` | 第9及26–35关 |
| `levels/coating_rooms.gd` | 第10–19关 |
| `levels/laser_rooms.gd` | 第20–25关 |
| `levels/advanced_rooms.gd` | 第36–50关 |
| `scenes/main.gd` | 菜单/5页选关、说明卡、存档、关卡启动与结算、重试、无文字建议圈/尖刺 |
| `actors/player.gd` / `world/materials.gd` | 普通移动及局部涂层碰撞/绘制；materials默认空保持旧路径 |
| `portals/system.gd` | 原真实门洞/速度、首个实体ray_hit、绿色shot_path/candidate、激光beam_path、动态occluders |
| `world/mechanisms.gd` | 光源、实际光束、接收器、门、平台/线路绘制、复位及动态射线阻挡 |
| `world/moving_platform.gd` | 平台实体/承载/扫掠、相位复位、齿轮及轨道 |
| `ui/tutorial.gd` / `ui/landmarks.gd` | 原关建议圈与B风格；新关建议圈来自地图guide |
| `assets/sounds.gd` | 固定10个合成音效播放器，退出停止/释放后等300ms混音清理 |
| `tests/run.ps1` | 33组完整回归，捕获stdout/stderr，错误/泄漏也使失败 |
| `tests/campaign_preview.gd` | 50关GPU、42张新说明卡、5页选关、帮助与锁定页截图 |

地图基础字段name/spawn/goal/blocks/faces/hint/enemy。可选materials[{a,b,n,kind:bounce或boost}]、mirrors[{a,b,n}]、emitters[{p,d}]、receivers[{p,id}]、gates[{rect,requires:[id]}]、movers[{rect,to,speed,requires:[id]}]、hazards:[Rect2]、briefing:[String]、guide:[{p,color,normal,after?,before?}]；guard仍可指定spawn/low/high。平台rect/to为父节点本地左上角，bounds返回世界矩形。

真实碰撞：完整静态矩形用于射线，激活双门只切承载实体的对应开口，门外保留碰撞；外部门/移动平台自带碰撞，由occluders加入射线而不重复重建静态地形。动态阻挡与地形同距离时优先阻挡，避免贴面漏光。

关卡数量/最终页/存档上限统一用Maps.LEVEL_COUNT。存档仅保存unlocked及音量，旧8不代表已通关8，不自动解锁9；完成8后才进9，旧3/4/5/6/7同理，不清空或补解锁。测试persistence_enabled=false，不触碰正式进度。

## 标准通关路线与验证方式

- 第1–8关：README试玩路线与原tests/game、ceiling_route、level4至level8。
- 第9及26–35关：docs/campaign-routes.md，对应tests/relay9.gd、mixed_routes.gd。
- 第10–19关：docs/coating-routes.md，对应tests/coating_routes.gd。
- 第20–25关：docs/laser-routes.md，对应tests/laser_routes.gd。
- 第36–50关：docs/advanced-routes.md，对应tests/advanced_routes.gd，可用`-- --room=50`定位。
- 新路线只用真实输入及实际枪口射击，不赋玩家位置/速度、接收器状态或强制过关；导航测试为检查UI可以明确调用complete，不能把它当通关证据。

```powershell
./tests/run.ps1
& ./tools/godot-4.7.2/Godot_v4.7.2-stable_win64_console.exe --path . --script tests/display.gd
& ./tools/godot-4.7.2/Godot_v4.7.2-stable_win64_console.exe --path . --script tests/campaign_preview.gd
& ./tools/godot-4.7.2/Godot_v4.7.2-stable_win64_console.exe --headless --path . --export-release 'Windows Desktop' builds/PortalHop.exe
```

快速开发可用--fixed-fps120，时间步仍1/120但不等墙钟；音频混音线程仍用墙钟，所以快速测试退出额外等350ms，生产drain_audio不改。最终全量使用普通实时运行。tools/builds被Git忽略，新克隆须准备相同引擎和Windows模板。正式存档在`%APPDATA%/Godot/app_userdata/Portal Hop/progress.cfg`。

## 本轮验证与交付记录

最终33组完整实时回归全部通过，所有50关均有真实输入路线通过；全部stdout/stderr未见运行错误或退出泄漏。5页选关/旧进度/8→9至50最终页及42张新说明卡宽高均通过。独立早期审查复现并修复三项：动态出口占据、贴面阻挡光线穿透、薄墙后接收器误触发，均先红后绿。最终独立审查未发现重要问题；37/41重试实际可继续，41自动升降台重生首帧短暂相交后引擎下一帧安全推出，不死循环。

GPU最终重拍全部50关、42张新卡片、5页选关、锁定页及帮助；检查总览和代表性画面，齿轮与双轨凹槽可见。三种窗口/全屏/真实鼠标映射及光标恢复通过。另修复31张长说明卡超宽问题，先失败再换行通过，GPU卡片20/50读回正确。唯一EXE正常GPU启动退出0；同版本Godot挂载EXE内嵌包逐一构造50关成功并拍到第50关，EMBEDDED_PROJECT=true。自动输入及截图不等同完整人手试玩，未做小时级内存/全部刷新率/穷尽巧解测试。

当前构建：builds/PortalHop.exe，109351192字节，SHA-256：42E023A67E1C56142FA79A3E2F943846ADBF27503D90459DE1DCEE5F4D923EB1。桌面快捷方式目标正确，builds仅1个EXE；详见docs/build-manifest.txt。修改后必须同步本文件、README操作、已知问题、进度及实际构建清单，与代码一起提交。docs/campaign-execution.md记录本次取舍/阶段；旧路线图或计划只作历史，不能据此恢复旧布局或扩大任务。

> 先读PROJECT_STATE.md和AGENTS.md，确认当前构建及验证记录，再根据我对五十关版的试玩反馈修改。沿用现有普通手感、真实自由传送门和B美术，维护唯一PortalHop.exe与接续文档。
