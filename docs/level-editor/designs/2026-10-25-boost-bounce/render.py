"""Recreate calibrated room26 JSON and original/real-route comparison artifacts."""
import json
import math
from pathlib import Path

ROOT = Path(__file__).resolve().parent
COLORS = {'wall-gray':'#7b8591','wall-white':'#fff','wall-red':'#e95c68','wall-blue':'#448cdb'}


def point(x, y):
    return {'x':x, 'y':y}


def fit(trace):
    a, b = trace[0], trace[-1]
    sums, total = [0., 0.], 0.
    for index, p in enumerate(trace):
        t = index/(len(trace)-1)
        w = 2*t*(1-t)
        total += w*w
        for axis in range(2):
            sums[axis] += w*(p[axis]-(1-t)**2*a[axis]-t*t*b[axis])
    return point(*a), point(*b), point(max(0,min(960,sums[0]/total)), max(0,min(540,sums[1]/total)))


def svg(doc, actual=None):
    marker = 'calibrated-arrow' if actual else 'original-arrow'
    out = [f'<svg xmlns="http://www.w3.org/2000/svg" width="960" height="540" viewBox="0 0 960 540"><defs><marker id="{marker}" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto"><path d="M0 0L10 5 0 10z" fill="#278b6f"/></marker></defs><rect width="960" height="540" fill="white"/><style>text{{font:14px "Microsoft YaHei",sans-serif}}</style>']
    for i in doc['items']:
        kind = i['type']
        if kind.startswith('wall-'):
            a, b = i['a'], i['b']
            for color, width in [('#5e6a75',i['thickness']+2),(COLORS[kind],i['thickness'])]:
                out.append(f'<line x1="{a["x"]}" y1="{a["y"]}" x2="{b["x"]}" y2="{b["y"]}" stroke="{color}" stroke-width="{width}" stroke-linecap="{"butt" if actual else "round"}"/>')
        elif kind=='spikes':
            a, b = i['a'], i['b']
            length = math.hypot(b['x']-a['x'],b['y']-a['y'])
            tx, ty = (b['x']-a['x'])/length, (b['y']-a['y'])/length
            nx, ny = ty*i['side'], -tx*i['side']
            for start in range(0,math.ceil(length),16):
                end = min(start+16,length)
                pts = [(a['x']+tx*start,a['y']+ty*start),(a['x']+tx*(start+end)/2+nx*i['thickness'],a['y']+ty*(start+end)/2+ny*i['thickness']),(a['x']+tx*end,a['y']+ty*end)]
                out.append('<polygon points="'+' '.join(f'{x},{y}' for x,y in pts)+'" fill="#ff526b"/>')
        elif kind in ('start','goal'):
            x, y = i['x'], i['y']
            if kind=='start':
                out.append(f'<path d="M{x} {y}v-40l28 10-28 10" stroke="#238b69" fill="none" stroke-width="2"/><text x="{x-12}" y="{y+19}" fill="#238b69">起点</text>')
            else:
                out.append(f'<rect x="{x-18}" y="{y-44}" width="36" height="44" fill="#d7e8fa" stroke="#345f8b" stroke-width="2"/><text x="{x-12}" y="{y-51}" fill="#345f8b">终点</text>')
    if actual:
        for trace in actual['paths']:
            pts = ' '.join(f'{x:.2f},{y:.2f}' for x,y in trace)
            out.append(f'<polyline points="{pts}" fill="none" stroke="#278b6f" stroke-width="3" marker-end="url(#{marker})"/>')
        for shot in actual['shots']:
            n = (61/math.hypot(61,94),-94/math.hypot(61,94)) if shot['kind']=='exit' else (-60/math.hypot(60,130),-130/math.hypot(60,130))
            tx, ty = -n[1],n[0]
            x, y = shot['p']
            out.append(f'<line x1="{x-tx*36}" y1="{y-ty*36}" x2="{x+tx*36}" y2="{y+ty*36}" stroke="{"#397de0" if shot["kind"]=="exit" else "#e95c68"}" stroke-width="6"/>')
        for x,y,label in [(160,477,'① 红跑道与红坡'),(510,350,'② 越刺坑进右门'),(210,100,'③ 左斜面出门'),(560,200,'④ 蓝台反弹至终点')]:
            out.append(f'<text x="{x}" y="{y}" fill="#287b67">{label}</text>')
    else:
        for i in doc['items']:
            if i['type']=='path':
                a,b,c = i['a'],i['b'],i['control']
                out.append(f'<path d="M{a["x"]} {a["y"]}Q{c["x"]} {c["y"]} {b["x"]} {b["y"]}" fill="none" stroke="#278b6f" stroke-width="3" marker-end="url(#{marker})"/>')
    return '\n'.join(out+['</svg>'])


def main():
    raw = json.loads((ROOT/'input.json').read_text(encoding='utf-8'))
    actual = json.loads((ROOT/'actual-route.json').read_text(encoding='utf-8'))
    adjusted = json.loads(json.dumps(raw))
    adjusted['title'] = '第26关 · 赤坡接力'
    by_id = {i['id']:i for i in adjusted['items']}
    segments = {1:((38,440),(140,440)),3:((140,440),(340,440)),4:((340,440),(440,410)),5:((440,410),(440,450)),6:((450,450),(670,450)),7:((680,440),(810,380)),8:((810,100),(810,390)),9:((40,201),(134,262)),10:((400,260),(550,260)),11:((650,110),(820,110)),17:((40,201),(40,450))}
    for ident,(a,b) in segments.items(): by_id[ident].update(a=point(*a),b=point(*b))
    by_id[2].update(x=89,y=430)
    by_id[12].update(x=779,y=100)
    for ident,trace in zip([13,14,15,16],actual['paths']):
        by_id[ident]['a'],by_id[ident]['b'],by_id[ident]['control'] = fit(trace)
    (ROOT/'adjusted.json').write_text(json.dumps(adjusted,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    analysis = {'method':'Geometry calibration; analytical launch target separate from recorded Godot measurements','physics_snapshot':{'hz':120,'gravity':900,'ordinary_speed':210,'boost_target':650,'boost_acceleration':1800,'released_ground_braking':2300,'released_air_drag':90,'character':[22,30]},'red_ramp_degrees':math.degrees(math.atan2(30,100)),'nominal_tangent_target':[650*100/math.hypot(100,30),-650*30/math.hypot(100,30)],'actual_launch_after_edge':actual['events'][0],'actual_exit':actual['events'][1],'actual_bounce':actual['events'][2],'actual_portal_exit_speed':math.hypot(*actual['events'][1]['v']),'actual_landing':actual['landing'],'actual_minimum_top_y':actual['minimum_center_y']-15,'actual_boost_horizontal_distance':actual['boost_distance'],'input_sha256':'b59347f2cef8bf34fda51685165d3ce19a59baa6937d3da7140c2bdeae25c5ab','measurement_source':'actual-route.json','limits':'Finite actual inputs; no exhaustive shortcut solver or human acceptance'}
    (ROOT/'calculation.json').write_text(json.dumps(analysis,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    before,after = svg(raw),svg(adjusted,actual)
    (ROOT/'original.svg').write_text(before,encoding='utf-8')
    (ROOT/'plan.svg').write_text(after,encoding='utf-8')
    page = '''<!doctype html><html lang="zh-CN"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>第26关 · 赤坡接力</title><style>body{margin:0;background:#14222d;color:#e3eef2;font:15px "Microsoft YaHei",sans-serif}main{max-width:1150px;margin:auto;padding:24px}h1{font-size:25px}button{padding:9px 15px;border:1px solid #537584;border-radius:6px;background:#244452;color:white;cursor:pointer;margin:4px}p{line-height:1.9;color:#bdd2dd}.paper{background:white;border-radius:8px;overflow:hidden}.paper svg{display:block;width:100%;height:auto}a{color:#a8e7cf}</style><main><h1>第26关 · 赤坡接力</h1><p>红跑道/红坡加速越刺坑，右白坡入门，左白坡出门，蓝台自动反弹上终点。红坡改为约16.7°，蓝台下移到外沿y250并右移；墙段接齐，标记落在台面。原有物理参数不变，只补齐红斜面接触与切向驱动。</p><button id="revised-button">修订与实测路径</button><button id="original-button">原始草图</button><button id="download-json">下载修订JSON</button><div class="paper" id="revised">__AFTER__</div><div class="paper" id="original" hidden>__BEFORE__</div><p>绿色折线是Godot真实输入轨迹，门短线是自由放置的参考位置。按D蓄速上坡，在坡上正常射击放好两门；出门后松开横向键，蓝台自动接力，实际落终点台后继续向右。红坡没有额外起飞奖励，目标650、加速度1800及松键2300沿用。</p><p>名义1次传送/1次蓝反弹/零死亡，实际落台约(712,85)，角色上沿最高约16px；邻近门位、缺红/缺蓝、R/暂停测试见同目录README及本次构建清单。曲线是实测拟合表达，精确路径在actual-route.json；不声称所有巧解已穷尽。</p><a href="../../../关卡编辑器.html">打开编辑器</a></main><script>const revised=document.getElementById('revised'),original=document.getElementById('original');document.getElementById('revised-button').onclick=()=>{revised.hidden=false;original.hidden=true;};document.getElementById('original-button').onclick=()=>{revised.hidden=true;original.hidden=false;};const adjusted=__JSON__;document.getElementById('download-json').onclick=()=>{const u=URL.createObjectURL(new Blob([JSON.stringify(adjusted,null,2)],{type:'application/json'})),a=document.createElement('a');a.href=u;a.download='PortalHop-第26关-赤坡接力.json';document.body.append(a);a.click();a.remove();setTimeout(()=>URL.revokeObjectURL(u),30000);};</script></html>'''
    page = page.replace('__BEFORE__',before).replace('__AFTER__',after).replace('__JSON__',json.dumps(adjusted,ensure_ascii=False).replace('<','\\u003c'))
    (ROOT/'plan.html').write_text(page,encoding='utf-8')
    print('Rendered calibrated26 JSON, analysis, SVG and local comparison page')


if __name__=='__main__':
    main()
