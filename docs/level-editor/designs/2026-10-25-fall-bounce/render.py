"""Render original/revised planning figures; does not edit the live editor."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent


def svg(data, calculation=None):
    out = ['<svg xmlns="http://www.w3.org/2000/svg" width="960" height="540" viewBox="0 0 960 540" role="img" aria-label="关卡布局与路线"><defs><marker id="arrow" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse"><path d="M 0 0 L 10 5 L 0 10 z" fill="#24866d"/></marker></defs><rect width="960" height="540" fill="white"/>']
    colors = {'wall-gray': '#7b8591', 'wall-white': '#fff', 'wall-blue': '#448cdb'}
    walls = [i for i in data['items'] if i['type'].startswith('wall-')]
    for i in walls:
        a, b = i['a'], i['b']
        cap = 'butt' if calculation else 'round'
        for color, width in [('#5e6a75', i['thickness'] + 2), (colors[i['type']], i['thickness'])]:
            out.append(f'<line x1="{a["x"]}" y1="{a["y"]}" x2="{b["x"]}" y2="{b["y"]}" stroke="{color}" stroke-width="{width}" stroke-linecap="{cap}"/>')
    for i in data['items']:
        if i['type'] not in ('start', 'goal'):
            continue
        x, y = i['x'], i['y']
        if i['type'] == 'start':
            out.append(f'<path d="M{x} {y}v-40l28 10-28 10" stroke="#238b69" fill="none" stroke-width="2"/><text x="{x-12}" y="{y+18}" fill="#238b69">起点</text>')
        else:
            out.append(f'<rect x="{x-18}" y="{y-44}" width="36" height="44" fill="#d7e8fa" stroke="#345f8b" stroke-width="2"/><text x="{x-12}" y="{y+20}" fill="#345f8b">终点</text>')
    if calculation:
        for index, path in enumerate(calculation['paths'], 1):
            points = ' '.join(f'{x:.2f},{y:.2f}' for x, y in path)
            out.append(f'<polyline points="{points}" fill="none" stroke="#24866d" stroke-width="3" marker-end="url(#arrow)"/>')
        out.append('<line x1="384" y1="500" x2="456" y2="500" stroke="#e95c68" stroke-width="6"/>')
        norm = calculation['exit_normal']
        tangent = (-norm[1], norm[0])
        p = (640 + norm[0]*10, 302 + norm[1]*10)
        a, b = [(p[0]+sign*36*tangent[0], p[1]+sign*36*tangent[1]) for sign in (-1, 1)]
        out.append(f'<line x1="{a[0]}" y1="{a[1]}" x2="{b[0]}" y2="{b[1]}" stroke="#397de0" stroke-width="6"/>')
        for x, y, label in [(275, 240, '1 下落入门'), (445, 265, '2 出门向左'), (440, 120, '3 蓝面折返'), (90, 140, '先到右沿放门，再后退助跑'), (88, 355, '蓝面 57.4°'), (686, 345, '白面 74.5°'), (490, 485, '白带 120px'), (690, 245, '落台后走向终点')]:
            out.append(f'<text x="{x}" y="{y}" fill="#287b67">{label}</text>')
        out.append('<circle cx="235" cy="185" r="5" fill="#d8a72d"/><path d="M690 185h90" stroke="#24866d" stroke-dasharray="5 5" marker-end="url(#arrow)"/>')
    else:
        for index, item in enumerate([i for i in data['items'] if i['type'] == 'path'], 1):
            a, b, c = item['a'], item['b'], item['control']
            out.append(f'<path d="M{a["x"]} {a["y"]} Q{c["x"]} {c["y"]} {b["x"]} {b["y"]}" fill="none" stroke="#24866d" stroke-width="3" marker-end="url(#arrow)"/>')
            out.append(f'<text x="{a["x"]+8}" y="{a["y"]-10}" fill="#24866d">路线 {index}</text>')
    out.append('<style>text{font:14px "Microsoft YaHei",sans-serif}</style></svg>')
    marker = 'model-arrow' if calculation else 'original-arrow'
    return '\n'.join(out).replace('id="arrow"', f'id="{marker}"').replace('url(#arrow)', f'url(#{marker})')


def main():
    original = json.loads((ROOT / 'input.json').read_text(encoding='utf-8'))
    adjusted = json.loads((ROOT / 'adjusted.json').read_text(encoding='utf-8'))
    calc = json.loads((ROOT / 'calculation.json').read_text(encoding='utf-8'))
    raw, revised = svg(original), svg(adjusted, calc)
    (ROOT / 'original.svg').write_text(raw, encoding='utf-8')
    (ROOT / 'plan.svg').write_text(revised, encoding='utf-8')
    page = '''<!doctype html><html lang="zh-CN"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>落差折返 · 比例修订计划</title><style>
*{box-sizing:border-box}body{margin:0;font:14px "Segoe UI","Microsoft YaHei",sans-serif;background:#14222d;color:#e3eef2}main{max-width:1160px;margin:auto;padding:28px}header{display:flex;justify-content:space-between;align-items:center;gap:15px;flex-wrap:wrap}h1{font-weight:550;font-size:25px;margin:6px 0}small,.muted{color:#9eb5c4}.tag{color:#e8d79f;border:1px solid #7e704a;padding:7px 12px;border-radius:20px;font-size:12px}.tabs{display:flex;gap:8px;margin:25px 0 13px;flex-wrap:wrap}button,a.action{font:inherit;background:#223b4a;color:#e0edf3;border:1px solid #486675;border-radius:7px;padding:9px 13px;cursor:pointer;text-decoration:none}button.active{background:#95e2c1;color:#15372a;border-color:#95e2c1}.paper{border-radius:10px;overflow:hidden;background:white;box-shadow:0 10px 40px #0004}.paper svg{display:block;width:100%;height:auto}.caption{font-size:12px;color:#a5bfcd;line-height:1.8}.metrics{display:grid;grid-template-columns:repeat(4,1fr);gap:12px;margin:22px 0}.metrics article{background:#1d3342;padding:17px;border:1px solid #345262;border-radius:9px}.metrics b{display:block;color:#a8e7cf;font-size:23px;font-weight:550;margin:6px 0}.metrics small{font-size:11px}.columns{display:grid;grid-template-columns:1fr 1fr;gap:30px;margin-top:25px}h2{font-size:17px;font-weight:550}p,li{line-height:1.9;color:#b5cbd6}ul,ol{padding-left:22px}details{border-top:1px solid #3a5362;padding:19px 0;margin-top:20px}summary{cursor:pointer;color:#b9d2df}a{color:#a8e7cf}.notice{background:#473f2b50;border-left:3px solid #ccb277;padding:12px 16px;color:#e4d7b7;line-height:1.8}footer{padding:20px 0;color:#8fa9b8;font-size:12px}@media(max-width:800px){main{padding:18px}.metrics{grid-template-columns:1fr 1fr}.columns{grid-template-columns:1fr;gap:10px}}
</style></head><body><main><header><div><small>PORTAL HOP / 用户草图 01</small><h1>落差折返 · 比例修订计划</h1></div><span class="tag">已确认 · 第24关已实装</span></header>
<div class="tabs"><button id="revised-button" class="active">调整后的计划图</button><button id="original-button">查看你的原始草图</button><button id="download-json">下载调整版 JSON</button><a class="action" href="../../../关卡编辑器.html">打开关卡编辑器</a></div>
<div class="paper" id="revised">__REVISED__</div><div class="paper" id="original" hidden>__ORIGINAL__</div>
<p class="caption" id="caption">绿色为计算模型路径；红/蓝短线标出两扇门的参考位置。门色可对调。开始先站到右沿放门，再退回助跑。</p>
<h2>修订计划的模型估算</h2><div class="metrics"><article><small>底部入门速度</small><b>__SPEED__ px/s</b><small>由现有重力和助跑得到</small></article><article><small>右侧落台位置</small><b>x ≈ __LANDING__</b><small>平台范围 x650–900</small></article><article><small>门位偏移检查</small><b>__PASS__ / __TOTAL__</b><small>入口与出口各 ±8px</small></article><article><small>最高点距屏幕顶</small><b>约__MARGIN__ px</b><small>按角色上沿计算</small></article></div>
<div class="columns"><section><h2>我调整了什么</h2><ul><li>接齐墙段并拉平上下地面，让起点、蓝面、底部与右侧平台保持连通关系。</li><li>蓝面改为约57.4°，右侧白面改为约74.5°，让两次转向衔接。</li><li>起点、终点对齐平台；反弹后先落台，再走到终点。</li><li><strong>底部白带收短到120px，两侧补灰地。</strong>整条白底允许同时放两门，会绕过蓝面直接弹上终点。</li></ul></section><section><h2>标准路线</h2><ol><li>向右走到平台边沿，放好底部门和右侧斜面门；再退回约x160。</li><li>按D助跑出平台，保持D直到落入底部门。</li><li>出门后松开横向键，向左碰蓝面，再自动折返向右。</li><li>落到右侧平台后，向右走到终点。失误沿用R重试。</li></ol></section></div>
<div class="notice">本方案已获确认并实装为第24关。Godot真实输入9组±8px门位偏差均经蓝面反弹、实际落台并通关；角色物理参数未改。此页绿色曲线仍展示原计算模型，实际画面与构建验证见设计目录README。</div>
<details><summary>计算依据与目前的边界</summary><p>采用现有重力900、普通跑速210、松键空中横向减速90、22×30角色和120Hz时间步；使用扫掠碰撞估算20px墙带。蓝面的反弹公式取自当前源码，斜面门的开口与安全偏移已在游戏实现；此处保留先前模型估算。0.83秒入底门，出门约0.49秒接蓝面，再约0.90秒落台。</p><p>出生点射线会先碰起点地面；平台右沿能直接看到两处白面。参考门位分别为底面(420,500)、右侧白面外沿约(630,299)。9组门位扰动都落台，移除蓝面反弹的对照未到达终点台；表中数值仍为模型估算，Godot实测已另行通过；不等于人手难度验收。</p><p>调整版JSON保留原部件ID、三条路线顺序，增加两条补灰地。曲线控制点拟合计算路径，可载入编辑器继续修改。原始文件另存，不覆盖你的浏览器布局。</p></details>
<footer>把“adjusted.json”载入关卡编辑器即可继续改。用户确认后已完成游戏实现与真实路线验证，接下来按试玩反馈调整。</footer></main><script>
const rb=document.getElementById('revised-button'),ob=document.getElementById('original-button');function show(revised){document.getElementById('revised').hidden=!revised;document.getElementById('original').hidden=revised;rb.classList.toggle('active',revised);ob.classList.toggle('active',!revised);document.getElementById('caption').textContent=revised?'绿色为计算模型路径；红/蓝短线标出两扇门的参考位置。门色可对调。开始先站到右沿放门，再退回助跑。':'这是你提交的原始坐标与三条曲线，未做比例调整。';}rb.onclick=()=>show(true);ob.onclick=()=>show(false);
const adjusted=__JSON__;document.getElementById('download-json').onclick=()=>{const url=URL.createObjectURL(new Blob([JSON.stringify(adjusted,null,2)],{type:'application/json'})),a=document.createElement('a');a.href=url;a.download='PortalHop-落差折返-比例修订.json';document.body.append(a);a.click();a.remove();setTimeout(()=>URL.revokeObjectURL(url),30000);};
</script></body></html>'''
    page = page.replace('__REVISED__', revised).replace('__ORIGINAL__', raw).replace('__JSON__', json.dumps(adjusted, ensure_ascii=False).replace('<', '\\u003c'))
    for key, value in {'SPEED': round(calc['entry_speed']), 'LANDING': round(calc['events'][-1]['p'][0]), 'PASS': sum(v['success'] for v in calc['tolerance']), 'TOTAL': len(calc['tolerance']), 'MARGIN': round(calc['minimum_center_y'] - 15)}.items():
        page = page.replace('__' + key + '__', str(value))
    (ROOT / 'plan.html').write_text(page, encoding='utf-8')
    print('Rendered original.svg, plan.svg and plan.html')


if __name__ == '__main__':
    main()
