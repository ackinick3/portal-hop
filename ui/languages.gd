extends RefCounted

const ZH := {
	"START GAME":"开始游戏", "LEVEL SELECT":"选择关卡", "SETTINGS":"设置",
	"CONTROLS":"键位说明", "QUIT":"退出游戏", "BACK":"返回",
	"LANGUAGE / 语言":"语言 / Language", "LANGUAGE":"语言 / Language",
	"SELECT A ROOM  /  %d":"选择关卡  /  第 %d 页", "  [LOCKED]":"  [未解锁]",
	"PREVIOUS PAGE":"上一页", "NEXT PAGE":"下一页", "MASTER VOLUME":"主音量",
	"TOGGLE WINDOW / FULLSCREEN":"切换窗口 / 全屏", "PAUSED":"已暂停",
	"CONTINUE":"继续游戏", "RESTART ROOM":"重新开始本关", "MAIN MENU":"返回主菜单",
	"ROOM COMPLETE":"关卡完成", "GAME COMPLETE!":"全部通关！",
	"%02d / %s\n\nTIME  %.2f s     DEATHS  %d":"%02d / %s\n\n用时  %.2f 秒     死亡  %d 次",
	"NEXT ROOM":"下一关", "REPLAY ROOM":"重玩本关",
	"Move left / right":"向左 / 向右移动", "Jump":"跳跃", "MOUSE":"鼠标",
	"Aim":"瞄准", "LEFT CLICK":"鼠标左键", "RIGHT CLICK":"鼠标右键",
	"Place red portal":"放置红色传送门", "Place blue portal":"放置蓝色传送门",
	"Retry room (adds one death)":"重试本关（死亡次数加一）",
	"Pause / resume":"暂停 / 继续", "Window / fullscreen":"窗口 / 全屏",
	"THE FIRST CROSSING":"初次跨越", "GRAVITY SLINGSHOT":"重力弹弓",
	"MECHANICAL GUARDIAN":"机械守卫", "THE VECTOR SWITCH":"向量转换",
	"THE FINAL RELAY":"最终接力", "AIRBORNE RELAY":"空中接力",
	"MIDAIR SWITCHBACK":"空中折返", "THE HIGH ROAD":"高空之路",
	"APEX RELAY":"顶点接力", "A SOFT LANDING":"轻盈落地",
	"THE REDLINE SLING":"红线弹射", "SPRING TO SLING":"弹跳接力",
	"RED TO SKY":"红轨升空", "CLIMB THEN SPRINT":"攀升冲刺",
	"FIRST LIGHT":"第一束光", "LIGHT WELL":"光之井", "CIRCUIT EXCHANGE":"光路交换",
	"TWO STAGE RUN":"双阶段疾行", "THE GREEN DETOUR":"绿色迂回",
	"THE GEAR FERRY":"齿轮渡台", "LIGHT THE TRACK":"点亮轨道",
	"TWO GREEN HORIZONS":"双重绿境", "THE COMPLETE CIRCUIT":"完整回路",
	"THE FALLING RETURN":"落差折返", "THE SECOND ASCENT":"二次蓄势",
	"THE CRIMSON ARC":"赤坡接力", "THE WANDERING FINISH":"流动终点",
	"THE KINETIC CHAMBER":"流动密室", "THE BORROWED EXIT":"借来的出口",
}

static func text(source: String, language: String) -> String:
	return ZH.get(source,source) if language == "zh_CN" else source
