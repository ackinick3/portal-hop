'use strict';
const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto');
const base=__dirname,read=name=>JSON.parse(fs.readFileSync(path.join(base,name),'utf8').replace(/^\uFEFF/,''));
const raw=read('input.json'),doc=structuredClone(raw),byId=new Map(doc.items.map(i=>[i.id,i])),point=(x,y)=>({x,y});
const segments={1:[[0,120],[114,120]],3:[[114,128],[114,345]],4:[[114,345],[248,345]],5:[[248,335],[248,448]],6:[[258,448],[490,448]],7:[[500,350],[500,448]],8:[[500,360],[810,360]],10:[[810,220],[810,360]],11:[[810,220],[885,145]],13:[[575,0],[575,330]]};
for(const [id,[a,b]]of Object.entries(segments))Object.assign(byId.get(Number(id)),{a:point(...a),b:point(...b)});
Object.assign(byId.get(2),{x:58,y:110});
Object.assign(byId.get(14),{x:380,y:100,width:180,height:20,track:[point(380,100),point(380,100),point(850,100)]});
Object.assign(byId.get(15),{x:386.5,y:90});
Object.assign(byId.get(16),{x:385,y:265.5,patrol:{a:point(385,133),b:point(385,398)}});
doc.title='第27关 · 流动终点';
doc.notes=raw.notes+'；四段路线保持：起跳落差入底门、左墙水平出门跨坑、红跑道冲右竖门、右斜门回上方移动终点。平台中心水平380→850，速度50px/s，终点固定在平台上。';
const traceFile=path.join(base,'actual-route.json'),actual=fs.existsSync(traceFile)?read('actual-route.json'):null;
function fit(points){
 const a=points[0],b=points.at(-1),s=[0,0];let weight=0;
 points.forEach((p,index)=>{const t=index/(points.length-1),w=2*t*(1-t);weight+=w*w;for(let k=0;k<2;k++)s[k]+=w*(p[k]-(1-t)**2*a[k]-t*t*b[k]);});
 return {a:point(...a),b:point(...b),control:point(Math.max(0,Math.min(960,s[0]/weight)),Math.max(0,Math.min(540,s[1]/weight)))};
}
const guide=[[[58,95],[203,320],[200,0]],[[136,177],[590,335],[365,177]],[[590,335],[789,335],[690,335]],[[814,174],[528,75],[640,0]]];
for(let n=0;n<4;n++)Object.assign(byId.get(17+n),actual?.paths[n]?.length>2?fit(actual.paths[n]):{a:point(...guide[n][0]),b:point(...guide[n][1]),control:point(...guide[n][2])});
const core=require(path.join(base,'../../core.js'));core.parse(JSON.stringify(doc));
fs.writeFileSync(path.join(base,'adjusted.json'),JSON.stringify(doc,null,2)+'\n');
const escape=s=>String(s).replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
function svg(d,record){
 const out=['<svg xmlns="http://www.w3.org/2000/svg" width="960" height="540" viewBox="0 0 960 540"><defs><marker id="arrow" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="6" markerHeight="6" orient="auto"><path d="M0 0L10 5 0 10z" fill="#278b6f"/></marker></defs><rect width="960" height="540" fill="white"/><style>text{font:13px "Microsoft YaHei",sans-serif}</style>'];
 const line=(a,b,color,width,dash='')=>`<line x1="${a.x}" y1="${a.y}" x2="${b.x}" y2="${b.y}" stroke="${color}" stroke-width="${width}" ${dash?'stroke-dasharray="'+dash+'"':''}/>`;
 for(const i of d.items){
  if(i.type.startsWith('wall-')){out.push(line(i.a,i.b,'#5e6a75',i.thickness+2),line(i.a,i.b,{'wall-gray':'#7b8591','wall-white':'white','wall-red':'#e95c68'}[i.type],i.thickness));}
  else if(i.type==='spikes'){for(let x=i.a.x;x<i.b.x;x+=16)out.push(`<path d="M${x} ${i.a.y}l8 -${i.thickness} 8 ${i.thickness}Z" fill="#e57983"/>`);}
  else if(i.type==='gun-screen')out.push(line(i.a,i.b,'#299963',4,'10 7'),`<text x="${i.a.x+8}" y="${i.a.y+16}" fill="#248353">阻枪光幕</text>`);
  else if(i.type==='moving-platform'){const x=record?record.platform[0]:i.x-i.width/2,y=record?record.platform[1]:i.y-i.height/2;out.push(`<polyline points="${i.track.map(p=>p.x+','+p.y).join(' ')}" fill="none" stroke="#657c97" stroke-width="2" stroke-dasharray="7 5"/>`,`<rect x="${x}" y="${y}" width="${i.width}" height="${i.height}" fill="#7b8591" stroke="#344b5e"/>`,`<text x="${x}" y="${y+i.height+22}" fill="#486179">平台与终点一起往返</text>`);}
  else if(i.type==='start')out.push(`<path d="M${i.x} ${i.y}v-40l28 10-28 10" fill="none" stroke="#238b69" stroke-width="2"/>`);
  else if(i.type==='goal')out.push(`<rect x="${record?record.goal[0]:i.x-21}" y="${record?record.goal[1]:i.y-54}" width="42" height="54" rx="8" fill="#d7e8fa" stroke="#345f8b"/>`);
  else if(i.type==='enemy')out.push(line(i.patrol.a,i.patrol.b,'#bc7444',2,'6 4'),`<rect x="${i.x-14}" y="${i.y-16}" width="28" height="30" rx="8" fill="#efb7a3" stroke="#344b5e"/>`);
 }
 const routes=d.items.filter(i=>i.type==='path');routes.forEach((i,n)=>{out.push(record?`<polyline points="${record.paths[n].map(p=>p.join(',')).join(' ')}" fill="none" stroke="#278b6f" stroke-width="2.5" marker-end="url(#arrow)"/>`:`<path d="M${i.a.x} ${i.a.y}Q${i.control.x} ${i.control.y} ${i.b.x} ${i.b.y}" fill="none" stroke="#278b6f" stroke-width="2.5" marker-end="url(#arrow)"/>`,`<text x="${i.a.x+12}" y="${i.a.y-10}" fill="#207b62">路线 ${n+1}</text>`);});
 if(record)for(const shot of record.shots){const n=shot.phase===0?(shot.color===0?[0,-1]:[1,0]):(shot.color===0?[-1,0]:[-Math.SQRT1_2,-Math.SQRT1_2]),t=[-n[1],n[0]],p=shot.p;out.push(line(point(p[0]-t[0]*36,p[1]-t[1]*36),point(p[0]+t[0]*36,p[1]+t[1]*36),shot.color?'#397de0':'#e95c68',5));}
 return out.concat('</svg>').join('\n');
}
const before=svg(raw),after=svg(doc,actual);fs.writeFileSync(path.join(base,'original.svg'),before);fs.writeFileSync(path.join(base,'plan.svg'),after);
fs.writeFileSync(path.join(base,'plan.html'),`<!doctype html><html lang="zh-CN"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>${escape(doc.title)}</title><style>body{margin:0;background:#14222d;color:#e3eef2;font:15px "Microsoft YaHei",sans-serif}main{max-width:1150px;margin:auto;padding:24px}h1{font-size:25px}p{line-height:1.9;color:#bdd2dd}button,a{padding:9px 15px;border:1px solid #537584;border-radius:6px;background:#244452;color:#d9f6ec;cursor:pointer;margin:4px}svg{display:block;width:100%;height:auto;background:white;border-radius:8px}</style><main><h1>${escape(doc.title)}</h1><p>起点跃下入底门 → 左墙出门越刺和上下怪 → 红跑道冲右竖门 → 右斜门飞向移动终点。普通人物物理未改。灰平台加宽至180，中心380→850按50px/s往返；终点跟随真实平台，站上平台才可完成。</p><button id="show-plan">修订与${actual?'实测':'预计'}路线</button><button id="show-original">原始草图</button><button id="download">下载修订JSON</button><section id="plan">${after}</section><section id="original" hidden>${before}</section><p>首段跨坑缩短，光幕上端接到屏幕以阻止起跳预放斜门。右竖门留足72px完整开口，斜面升高并校准45°，修复原图终点悬空。平台开头约5px的抖动拉直为同一直线。绿色虚线只阻枪线，人可穿过；怪物需观察相位。原稿四条曲线保持顺序，修订图${actual?'绿色折线为实际出生输入记录':'路线待实际输入校验'}；可编辑曲线只作拟合表达；平台和终点显示实测落台时刻的位置，JSON保留初始位置。</p><p>完整结果与边界见同目录README、calculation.json及游戏测试日志。手绘箭头与估算不当作碰撞/通关证据。</p><p><a href="../../../关卡编辑器.html">打开编辑器</a></p></main><script>const plan=document.getElementById('plan'),original=document.getElementById('original');document.getElementById('show-plan').onclick=()=>{plan.hidden=false;original.hidden=true};document.getElementById('show-original').onclick=()=>{plan.hidden=true;original.hidden=false};const doc=${JSON.stringify(doc).replace(/</g,'\u003c')};document.getElementById('download').onclick=()=>{const u=URL.createObjectURL(new Blob([JSON.stringify(doc,null,2)],{type:'application/json'})),a=document.createElement('a');a.href=u;a.download='PortalHop-第27关-流动终点.json';a.click();setTimeout(()=>URL.revokeObjectURL(u),30000)};</script></html>`);
const analysis={input_sha256:crypto.createHash('sha256').update(fs.readFileSync(path.join(base,'input.json'))).digest('hex'),physics:{gravity:900,jump:-330,red_target:650,player:[22,30],portal_width:72},geometry:{red_top:350,slope_degrees:45,platform_center:[[380,100],[850,100]],platform_size:[180,20],platform_speed:50},analytical_second_exit_velocity:[-650*Math.SQRT1_2,-650*Math.SQRT1_2],analytical_second_exit_rise:Math.pow(650*Math.SQRT1_2,2)/1800,measured_second_flight_minimum_center_y:actual?Math.min(...actual.paths[3].map(p=>p[1])):null,measured:actual?.result||null,limits:'Finite door and phase samples; no exhaustive shortcut or human-difficulty proof'};
fs.writeFileSync(path.join(base,'calculation.json'),JSON.stringify(analysis,null,2)+'\n');
console.log('Wrote calibrated room27, comparison SVG/HTML and calculation.json; original IDs preserved.');
