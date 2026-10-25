"""Reproduce room25 adjusted sketch and comparison using archived real-input traces."""
import importlib.util
import json
import math
import sys
from pathlib import Path

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('sketch_renderer', ROOT.parent / '2026-10-25-fall-bounce' / 'render.py')
renderer = importlib.util.module_from_spec(spec)
spec.loader.exec_module(renderer)


def point(x, y):
    return {'x': x, 'y': y}


def curve(points):
    a, b = points[0], points[-1]
    numerator, denominator = [0., 0.], 0.
    for index, p in enumerate(points):
        t = index / (len(points) - 1)
        weight = 2*t*(1-t)
        denominator += weight*weight
        for axis in range(2):
            numerator[axis] += weight*(p[axis]-(1-t)**2*a[axis]-t*t*b[axis])
    return point(*a), point(*b), point(max(0, min(960, numerator[0]/denominator)), max(0, min(540, numerator[1]/denominator)))


def main():
    original = json.loads((ROOT / 'input.json').read_text(encoding='utf-8'))
    actual = json.loads((ROOT / 'actual-route.json').read_text(encoding='utf-8'))
    adjusted = json.loads(json.dumps(original))
    adjusted['title'] = '第25关 · 二次蓄势'
    by_id = {i['id']: i for i in adjusted['items']}
    for ident, a, b in [(1, (56,150), (190,150)), (3, (175,150), (278,258)), (4, (278,258), (278,410)), (5, (278,410), (900,410)), (6, (680,90), (930,90))]:
        by_id[ident]['a'], by_id[ident]['b'] = point(*a), point(*b)
    by_id[2].update(x=118, y=140)
    by_id[7].update(x=893, y=80)
    for ident, trace in zip([8,9,10], actual['paths']):
        by_id[ident]['a'], by_id[ident]['b'], by_id[ident]['control'] = curve(trace)
    for ident, a, b in [(11, (0,90), (256,90)), (12, (278,248), (278,258))]:
        adjusted['items'].append({'id':ident, 'type':'wall-gray', 'a':point(*a), 'b':point(*b), 'thickness':20})
    adjusted['nextId'] = 13
    (ROOT / 'adjusted.json').write_text(json.dumps(adjusted, ensure_ascii=False, indent=2)+'\n', encoding='utf-8')
    normal = (108/math.hypot(108,103), -103/math.hypot(108,103))
    calculation = {'method':'Analytical estimate plus separately labelled Godot real-input measurements', 'physics_snapshot':{'gravity':900,'ground_speed':210,'air_release_drag':90,'opposite_air_acceleration':380,'character':[22,30],'hz':120}, 'slope_degrees':math.degrees(math.atan2(108,103)), 'exit_normal':normal, 'estimated_first_entry_speed':math.sqrt(210**2+2*900*(400-125)), 'actual_exit_speeds':[math.hypot(*e['v']) for e in actual['events']], 'actual_events':actual['events'], 'actual_landing':actual['landing'], 'actual_minimum_top_y':actual['minimum_center_y']-15, 'input_source':'input.json', 'measurement_source':'actual-route.json', 'limits':'Recorded finite route and nearby variants; not an exhaustive solver or human acceptance'}
    (ROOT / 'calculation.json').write_text(json.dumps(calculation, ensure_ascii=False, indent=2)+'\n', encoding='utf-8')
    raw = renderer.svg(original)
    terrain = {**adjusted, 'items':[i for i in adjusted['items'] if i['type']!='path']}
    revised = renderer.svg(terrain).replace('original-arrow', 'ascent-arrow')
    overlay = ''
    for index, trace in enumerate(actual['paths'], 1):
        pts = ' '.join(f'{x:.2f},{y:.2f}' for x, y in trace)
        overlay += f'<polyline points="{pts}" fill="none" stroke="#278b6f" stroke-width="3" marker-end="url(#ascent-arrow)"/>'
    for x, y, label in [(300,285,'① 跑下起点'),(480,120,'② 按A收落点并换底门'),(440,25,'③ 松键，二次上升'),(30,70,'低顶限制起跳绕路'),(705,115,'真实落台后走向终点')]:
        overlay += f'<text x="{x}" y="{y}" fill="#287b67">{label}</text>'
    overlay += '<line x1="329" y1="400" x2="401" y2="400" stroke="#e95c68" stroke-width="6"/><line x1="599" y1="400" x2="671" y2="400" stroke="#e95c68" stroke-width="6" stroke-dasharray="7 4"/>'
    p = actual['shots'][0]['p']
    tangent = (-normal[1], normal[0])
    overlay += f'<line x1="{p[0]-36*tangent[0]}" y1="{p[1]-36*tangent[1]}" x2="{p[0]+36*tangent[0]}" y2="{p[1]+36*tangent[1]}" stroke="#397de0" stroke-width="6"/>'
    revised = revised.replace('</svg>', overlay+'</svg>')
    (ROOT / 'original.svg').write_text(raw, encoding='utf-8')
    (ROOT / 'plan.svg').write_text(revised, encoding='utf-8')
    page = '''<!doctype html><html lang="zh-CN"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>第25关 · 二次蓄势</title><style>body{margin:0;background:#14222d;color:#e3eef2;font:15px "Microsoft YaHei",sans-serif}main{max-width:1150px;margin:auto;padding:24px}h1{font-size:25px}button{padding:9px 15px;border:1px solid #537584;border-radius:6px;background:#244452;color:white;cursor:pointer;margin:4px}p{line-height:1.9;color:#bdd2dd}.paper{background:white;border-radius:8px;overflow:hidden}.paper svg{display:block;width:100%;height:auto}a{color:#a8e7cf}</style><main><h1>第25关 · 二次蓄势</h1><p>保留三段箭头与两次白斜面出门。起点台延长、白墙接齐，坡角约46.4°；终点台抬至y80并扩至x680–930。增加起点灰低顶限制额外起跳，防单次直达绕过第二次蓄势，角色物理不改。</p><button id="revised-button">修订与实测路径</button><button id="original-button">原始草图</button><button id="download-json">下载修订JSON</button><div class="paper" id="revised">__REVISED__</div><div class="paper" id="original" hidden>__ORIGINAL__</div><p>绿色折线来自Godot真实输入记录。先在起点右沿放斜面门，跑下平台后向底面约(365,400)放另一门；第一次出门按A收水平速度，转入下落时把底门移到约(635,400)；第二次出门松键，落右台后向右走到终点。红虚线是同一底门的替换位置，非第三扇门，门位仍自由放置。</p><p>名义两次出口速度约736→782px/s，实际落台中心约(706,65)，角色上沿最高约23px。邻近门位、缺换门及已测绕路/暂停/R等真实测试见同目录README和项目构建清单，不代表所有巧解已穷尽。编辑器JSON曲线是实测路径的拟合表达；精确记录另存actual-route.json。</p><a href="../../../关卡编辑器.html">打开编辑器</a></main><script>const revised=document.getElementById('revised'),original=document.getElementById('original');document.getElementById('revised-button').onclick=()=>{revised.hidden=false;original.hidden=true;};document.getElementById('original-button').onclick=()=>{revised.hidden=true;original.hidden=false;};const adjusted=__JSON__;document.getElementById('download-json').onclick=()=>{const u=URL.createObjectURL(new Blob([JSON.stringify(adjusted,null,2)],{type:'application/json'})),a=document.createElement('a');a.href=u;a.download='PortalHop-第25关-二次蓄势.json';document.body.append(a);a.click();a.remove();setTimeout(()=>URL.revokeObjectURL(u),30000);};</script></html>'''
    page = page.replace('__REVISED__', revised).replace('__ORIGINAL__', raw).replace('__JSON__', json.dumps(adjusted, ensure_ascii=False).replace('<', '\\u003c'))
    (ROOT / 'plan.html').write_text(page, encoding='utf-8')
    print('Rendered room25 adjusted JSON, calculation, comparison HTML and SVG')


if __name__ == '__main__':
    main()
