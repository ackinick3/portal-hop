"""Render the room24 guard revision without changing the original sketch/editor."""
import importlib.util
import json
import sys
from pathlib import Path

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parent
BASE = ROOT.parent / '2026-10-25-fall-bounce'
spec = importlib.util.spec_from_file_location('fall_bounce_renderer', BASE / 'render.py')
renderer = importlib.util.module_from_spec(spec)
spec.loader.exec_module(renderer)


def scene(doc, calculation=None):
    drawing = renderer.svg(doc, calculation)
    enemy = next(i for i in doc['items'] if i['type'] == 'enemy')
    a, b = enemy['patrol']['a'], enemy['patrol']['b']
    x, y = enemy['x'], enemy['y']
    overlay = f'''<line x1="{a['x']}" y1="{a['y']}" x2="{b['x']}" y2="{b['y']}" stroke="#c8794a" stroke-width="3" stroke-dasharray="7 5"/>
<circle cx="{a['x']}" cy="{a['y']}" r="5" fill="#c8794a"/><circle cx="{b['x']}" cy="{b['y']}" r="5" fill="#c8794a"/>
<rect x="{x-20}" y="{y-17}" width="40" height="34" rx="3" fill="#d77470"/><rect x="{x-15}" y="{y-10}" width="30" height="10" fill="#131b2b"/>
<text x="565" y="65" fill="#a3582e">上下巡逻怪</text><text x="565" y="85" fill="#a3582e">70 px/s · 范围 y54–363</text>'''
    return drawing.replace('</svg>', overlay + '</svg>')


def main():
    original = json.loads((ROOT / 'input.json').read_text(encoding='utf-8'))
    adjusted = json.loads((ROOT / 'adjusted.json').read_text(encoding='utf-8'))
    calc = json.loads((BASE / 'calculation.json').read_text(encoding='utf-8'))
    raw, revised = scene(original), scene(adjusted, calc)
    (ROOT / 'original.svg').write_text(raw, encoding='utf-8')
    (ROOT / 'plan.svg').write_text(revised, encoding='utf-8')
    page = '''<!doctype html><html lang="zh-CN"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>第24关 · 上下巡逻怪小修</title>
<style>body{margin:0;background:#14222d;color:#e3eef2;font:15px "Microsoft YaHei",sans-serif}main{max-width:1150px;margin:auto;padding:24px}h1{font-size:25px}button{padding:9px 15px;border:1px solid #537584;border-radius:6px;background:#244452;color:white;cursor:pointer;margin:4px}p{line-height:1.9;color:#bdd2dd}.paper{background:white;border-radius:8px;overflow:hidden}.paper svg{display:block;width:100%;height:auto}a{color:#a8e7cf}</style>
<main><h1>第24关 · 增加上下巡逻怪</h1><p>地形、门位和角色手感沿用已实装版本。新增怪物位于x542，在y54–363上下往返；原稿略倾斜的巡逻线拉直，速度沿用现有70px/s。路线②、③都可能碰到它，也保留等待时机后通关的空间。</p>
<button id="revised-button">游戏小修图</button><button id="original-button">本次原始草图</button><button id="download-json">下载修订JSON</button>
<div class="paper" id="revised">__REVISED__</div><div class="paper" id="original" hidden>__ORIGINAL__</div>
<p>橙色虚线是怪物巡逻范围，绿色是原有计算模型路径，不能直接代表动态碰撞结果。没有修改坡角、白带或物理参数。修订JSON中的怪物使用ID17，保留旧修订图ID15/16的两块补灰地；原稿仍原样保存。</p>
<p>真实输入测试分别验证路线②/③的碰撞时机与安全出发窗口，详见同目录README及项目构建清单。<a href="../../../关卡编辑器.html">打开编辑器</a></p></main>
<script>const revised=document.getElementById('revised'),original=document.getElementById('original');document.getElementById('revised-button').onclick=()=>{revised.hidden=false;original.hidden=true;};document.getElementById('original-button').onclick=()=>{revised.hidden=true;original.hidden=false;};const adjusted=__JSON__;document.getElementById('download-json').onclick=()=>{const u=URL.createObjectURL(new Blob([JSON.stringify(adjusted,null,2)],{type:'application/json'})),a=document.createElement('a');a.href=u;a.download='PortalHop-第24关-上下巡逻怪.json';document.body.append(a);a.click();a.remove();setTimeout(()=>URL.revokeObjectURL(u),30000);};</script></html>'''
    page = page.replace('__REVISED__', revised).replace('__ORIGINAL__', raw).replace('__JSON__', json.dumps(adjusted, ensure_ascii=False).replace('<', '\\u003c'))
    (ROOT / 'plan.html').write_text(page, encoding='utf-8')
    print('Rendered guard original/plan SVG and comparison HTML')


if __name__ == '__main__':
    main()
