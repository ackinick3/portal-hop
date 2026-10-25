# 工程接口与可复用证据

这是定位参考，不是当前状态快照。先读目标工程PROJECT_STATE.md及源码；数量、引擎位置和已支持机制可能已变化。

## JSON与几何

`docs/level-editor/core.js`导出的parse(text)是设计JSON权威校验器。当前格式portal-hop-level-sketch、version1、960×540，字段title/notes/nextId/items；不要把地图批注JSON当设计图。

| 部件 | 数据与转换注意 |
|---|---|
| start/goal | x/y为旗杆脚或门底；按实际台顶和角色半高布置spawn，goal为实际区域 |
| wall-* | a/b是墙带中线端点，thickness为全厚；实际外沿须偏移半厚。网页圆端不等于实际实体圆角 |
| path | a/control/b为二次贝塞尔；items中出现顺序即箭头顺序，仅设计表达 |
| spikes | a/b基线，thickness为刺高，side决定朝向；用core.spikeAngle并核对实际碰撞，不盲目换成轴向矩形 |
| laser-* | x/y/angle，0向右、90向下；颜色不自行定义伤害/穿透/接收规则 |
| receiver | x/y/angle；草图本身未编码机关连接关系，需结合说明与既有机制 |
| enemy | x/y/angle、patrol=null或{a,b}；保留可选移动范围，核查游戏是否支持该范围方向 |

屏幕x向右、y向下；斜面有两个法线候选，以意图及实体外沿确定可用侧。矩形墙、斜面多边形与可放门/材料面必须贴合，连续墙接缝不能产生假洞。

## 现场代码入口

| 路径 | 用途 |
|---|---|
| levels/maps.gd | LEVEL_COUNT、ROOM_IDS、get_level/index_for_id与稳定ID路由 |
| levels/designed_rooms.gd | 用户草图关卡；保持已有静态方法及路由，不覆盖旧图 |
| scenes/main.gd | start_level、gun_origin、NEXT、分页/结算、进度恢复、死亡与危险区 |
| actors/player.gd | 普通移动、重力、反弹触发、输入、实际角色尺寸 |
| world/materials.gd | 蓝反弹/红加速接触匹配；绿色枪线在门户系统 |
| portals/system.gd | configure(blocks,faces,polygons=[])、candidate/shoot、ray_hit/beam_path、真实裁洞/出门 |
| world/mechanisms.gd、moving_platform.gd | 接收器/门/平台/承载与复位 |
| tests/run.ps1 | 当前全量实时回归入口及实际组数 |
| tests/curation.gd、export_smoke.gd | 精确关序/进度/分页/最终关与内嵌包数量断言 |

地图必需name/spawn/goal/blocks/faces/enemy；polygons仅凸多边形，其他可选字段从已有地图读取。白faces与材料/mirrors使用外沿a/b及单位外法线。门系统仍支持轴向Rect2旧路径；禁止把普通矩形碰撞换成假斜面出口。

旧存档order_version迁移、当前解锁与稳定ID不是同一概念。新增ID取现场未用的新值，通常max(ROOM_IDS)+1；旧缺版本迁移及已存在版本均须回归，新关不能让原已解锁状态被错误当成新关已完成。不要假设任何用户已有“全解锁”。

## 可参考的完整实例

`docs/level-editor/designs/2026-10-25-fall-bounce/`包含input/adjusted/calculation JSON、calibrate.py、render.py与对照网页。只借鉴计算/呈现方法，不能把坡角、白带长度或其路径直接套到新图。

`tests/fall_bounce.gd`展示出生走位、真实gun_origin射击、输入下落、传送/蓝反弹/实际落台与终点，以及扰动/对照/R/暂停。`tests/slopes.gd`展示斜面实体/框/遮挡和真实双向穿越测试；中心通过不等于所有切向偏移已覆盖。机制测试夹具和真实路线测试要分别标识。

## 执行与证据

在工程根目录PowerShell运行；下列Godot路径为当前工程约定，先验证文件与export_presets.cfg。不要下载安装或切换引擎来代替检查现有环境。

```powershell
$engine = './tools/godot-4.7.2/Godot_v4.7.2-stable_win64_console.exe'
./tests/run.ps1
& $engine --path . --script tests/campaign_preview.gd
& $engine --headless --path . --export-release 'Windows Desktop' builds/PortalHop.exe
```

新关测试按上述模式加到当前runner，并使用本次独立日志。真实时间运行可避免--fixed-fps加速与音频清理计时失真；读取stdout/stderr和退出码。PowerShell启动GUI EXE可能立即返回，应使用Start-Process -PassThru -Wait读取其ExitCode；用于后台验证时采用-WindowStyle Hidden。

内嵌包验证使用同版本Godot，外部测试脚本需绝对路径，否则容易误测散装源码：

```powershell
& $engine --main-pack '<绝对工程路径>/builds/PortalHop.exe' --script '<绝对工程路径>/tests/export_smoke.gd'
& $engine --headless --main-pack '<绝对工程路径>/builds/PortalHop.exe' --script '<绝对工程路径>/tests/<本次真实路线测试>.gd'
```

export_smoke检查res://project.binary及当前数量；真实路线脚本应加载包内res://地图/场景，不再次指向源码工程。导出前查看PortalHop进程和文件占用；不杀用户游戏、不制造第二EXE绕过占用。

构建清单记录Bytes、SHA256、版本/关数、实际通过的检查与未测项。截图应查看解码后的图，不只检查文件存在。正式进度一般在`%APPDATA%/Godot/app_userdata/Portal Hop/progress.cfg`，测试场景加入树前将persistence_enabled=false；普通启动检查只进菜单，避免通过试玩意外保存进度。

## 维护此技能

工程内skills/portalhop-level-builder为版本控制源，安装目录为用户Codex skills下的同名文件夹。修改源后重新验证并同步安装副本；不写入memories。

从目标工程根目录运行工具测试：

```powershell
node --test '<skill-dir>/scripts/inspect-sketch.test.cjs'
```

测试使用工程现有示例与临时目录，验证读取/几何/顺序、错误格式及输入不被修改；不是游戏通关测试。
