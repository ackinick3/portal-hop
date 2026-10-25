'use strict';
const C=LevelCore,$=id=>document.getElementById(id),canvas=$('paper'),ctx=canvas.getContext('2d'),KEY='portal-hop-level-editor-v1';
const names={start:'起点',goal:'终点','wall-gray':'灰墙','wall-white':'白墙','wall-blue':'蓝墙','wall-red':'红墙','wall-green':'绿墙',spikes:'地刺','laser-yellow':'黄色发射器','laser-purple':'紫色发射器','laser-red':'红色发射器',receiver:'激光接收器',enemy:'怪物',path:'曲线箭头'};
const colors={'wall-gray':'#7b8591','wall-white':'#ffffff','wall-blue':'#448cdb','wall-red':'#e95c68','wall-green':'#49a579','laser-yellow':'#e6b82d','laser-purple':'#a571e2','laser-red':'#e95c68'};
let H=C.history(C.create()),selected=null,tool='select',gesture=null,draft=null,recovery=null,toastTimer;
function toast(t){$('toast').textContent=t;$('toast').hidden=false;clearTimeout(toastTimer);toastTimer=setTimeout(()=>$('toast').hidden=true,5500);}
try{const raw=localStorage.getItem(KEY);if(raw){try{H=C.history(C.parse(raw));}catch(e){recovery=raw;$('recover').hidden=false;toast('旧布局无法载入，已保护原数据。新布局请导出 JSON 备份。');}}}catch(e){toast('浏览器存储不可用，请导出 JSON 保存。');}
const chosen=()=>H.doc.items.find(i=>i.id===selected);
function persist(){if(recovery!==null){$('save-state').textContent='旧数据受保护 · 请导出 JSON';return;}try{localStorage.setItem(KEY,JSON.stringify(H.doc));$('save-state').textContent='已保存到当前浏览器';}catch(e){$('save-state').textContent='自动保存失败 · 请导出 JSON';toast('浏览器空间不足或存储受限，请导出 JSON。');}}
function arrow(g,a,b,color,width=2,head=11){const r=Math.atan2(b.y-a.y,b.x-a.x);g.strokeStyle=color;g.lineWidth=width;g.beginPath();g.moveTo(a.x,a.y);g.lineTo(b.x,b.y);g.stroke();g.beginPath();g.moveTo(b.x-head*Math.cos(r-.48),b.y-head*Math.sin(r-.48));g.lineTo(b.x,b.y);g.lineTo(b.x-head*Math.cos(r+.48),b.y-head*Math.sin(r+.48));g.stroke();}
function drawItem(g,i,index){
 g.save();g.lineJoin='round';g.lineCap='round';g.font='12px "Microsoft YaHei",sans-serif';
 if(i.type==='path'){
  g.strokeStyle='#278b6f';g.lineWidth=3;g.beginPath();g.moveTo(i.a.x,i.a.y);g.quadraticCurveTo(i.control.x,i.control.y,i.b.x,i.b.y);g.stroke();arrow(g,C.curve(i,.96),i.b,'#278b6f',3,14);
  g.fillStyle='#207b62';g.fillText('路线 '+index,i.a.x+8,i.a.y-10);
 }else if(C.segment(i.type)){
  const a=i.a,b=i.b,len=C.length(i),dx=(b.x-a.x)/(len||1),dy=(b.y-a.y)/(len||1);
  if(i.type==='spikes'){
   g.strokeStyle='#9e4751';g.fillStyle='#e57983';g.lineWidth=1;const count=Math.max(1,Math.ceil(len/19)),step=len/count,nx=dy*i.side,ny=-dx*i.side;
   for(let n=0;n<count;n++){const x=a.x+dx*n*step,y=a.y+dy*n*step;g.beginPath();g.moveTo(x,y);g.lineTo(x+dx*step/2+nx*i.thickness,y+dy*step/2+ny*i.thickness);g.lineTo(x+dx*step,y+dy*step);g.closePath();g.fill();g.stroke();}
  }else{g.strokeStyle='#5e6a75';g.lineWidth=i.thickness+2;g.beginPath();g.moveTo(a.x,a.y);g.lineTo(b.x,b.y);g.stroke();g.strokeStyle=colors[i.type];g.lineWidth=i.thickness;g.beginPath();g.moveTo(a.x,a.y);g.lineTo(b.x,b.y);g.stroke();}
 }else{
  if(i.type==='enemy'&&i.patrol){g.setLineDash([6,4]);g.strokeStyle='#bc7444';g.lineWidth=2;g.beginPath();g.moveTo(i.patrol.a.x,i.patrol.a.y);g.lineTo(i.patrol.b.x,i.patrol.b.y);g.stroke();g.setLineDash([]);for(const p of [i.patrol.a,i.patrol.b]){g.beginPath();g.arc(p.x,p.y,4,0,Math.PI*2);g.stroke();}}
  g.translate(i.x,i.y);g.strokeStyle='#344b5e';g.lineWidth=2;
  if(i.type==='start'){g.strokeStyle='#238b69';g.beginPath();g.moveTo(0,0);g.lineTo(0,-40);g.lineTo(28,-30);g.lineTo(0,-20);g.stroke();g.fillStyle='#238b69';g.fillText('起点',-10,17);}
  else if(i.type==='goal'){g.fillStyle='#d7e8fa';g.fillRect(-18,-44,36,44);g.strokeRect(-18,-44,36,44);g.fillStyle='#345f8b';g.beginPath();g.arc(9,-20,2,0,Math.PI*2);g.fill();g.fillText('终点',-12,17);}
  else if(i.type.startsWith('laser-')){g.rotate(i.angle*Math.PI/180);g.fillStyle=colors[i.type];g.fillRect(-13,-12,26,24);g.strokeRect(-13,-12,26,24);g.fillStyle='#344b5e';g.fillRect(8,-5,12,10);arrow(g,{x:22,y:0},{x:56,y:0},colors[i.type],3,9);}
  else if(i.type==='receiver'){g.fillStyle='#fff2ce';g.beginPath();g.arc(0,0,16,0,Math.PI*2);g.fill();g.stroke();g.beginPath();g.arc(0,0,8,0,Math.PI*2);g.stroke();g.fillStyle='#9c7928';g.fillText('接收',-12,32);}
  else if(i.type==='enemy'){g.fillStyle='#efb7a3';g.beginPath();g.roundRect(-14,-16,28,30,8);g.fill();g.stroke();g.fillStyle='#344b5e';g.beginPath();g.arc(-5,-4,2,0,Math.PI*2);g.arc(5,-4,2,0,Math.PI*2);g.fill();g.beginPath();g.moveTo(-6,6);g.lineTo(6,6);g.stroke();}
 }
 g.restore();
}
function handles(i){if(!i||!C.segment(i.type))return [];return ['a','b',...(i.type==='path'?['control']:[])].map(key=>({key,p:i[key]}));}
function render(helpers=true){
 ctx.setTransform(2,0,0,2,0,0);ctx.clearRect(0,0,960,540);ctx.fillStyle='#fff';ctx.fillRect(0,0,960,540);
 if(helpers&&$('grid').checked){ctx.lineWidth=.5;ctx.strokeStyle='#e9eef1';ctx.beginPath();for(let x=0;x<960;x+=20){ctx.moveTo(x,0);ctx.lineTo(x,540);}for(let y=0;y<540;y+=20){ctx.moveTo(0,y);ctx.lineTo(960,y);}ctx.stroke();}
 let pathIndex=0;H.doc.items.forEach(i=>drawItem(ctx,i,i.type==='path'?++pathIndex:0));if(draft){if(draft.type==='patrol'){ctx.save();ctx.setLineDash([5,4]);arrow(ctx,draft.a,draft.b,'#bc7444',2);ctx.restore();}else drawItem(ctx,draft,pathIndex+1);}
 const i=chosen();if(!helpers||!i)return;ctx.save();ctx.strokeStyle='#1ca6a0';ctx.lineWidth=1;ctx.setLineDash([4,3]);
 if(C.segment(i.type)){
  ctx.beginPath();ctx.moveTo(i.a.x,i.a.y);if(i.control)ctx.lineTo(i.control.x,i.control.y);ctx.lineTo(i.b.x,i.b.y);ctx.stroke();ctx.setLineDash([]);
  for(const h of handles(i)){ctx.fillStyle=h.key==='control'?'#ffc85d':'#e7fffd';ctx.beginPath();ctx.arc(h.p.x,h.p.y,6,0,Math.PI*2);ctx.fill();ctx.stroke();}
 }else ctx.strokeRect(i.x-25,i.y-(i.type==='start'||i.type==='goal'?49:25),50,i.type==='start'||i.type==='goal'?70:50);
 ctx.restore();
}
function sync(){render();inspector();layers();$('undo').disabled=!H.back.length;$('redo').disabled=!H.forward.length;$('delete').disabled=!chosen();$('count').textContent=H.doc.items.length+' 个部件 · '+H.doc.items.filter(i=>i.type==='path').length+' 条预设路线';}
function changed(){persist();sync();}
function transact(fn){const before=structuredClone(H.doc);try{fn();C.parse(JSON.stringify(H.doc));const after=H.doc;H.doc=before;C.checkpoint(H);H.doc=after;changed();}catch(e){H.doc=before;sync();toast(e.message);}}
function setTool(type){tool=type;document.querySelectorAll('[data-type]').forEach(b=>b.classList.toggle('active',b.dataset.type===type));let hint='';
 if(type==='select')hint='点击部件选中；拖动移动。线段两端可拖动，曲线金色点控制弯曲。';
 else if(type==='patrol')hint='拖出怪物移动范围，怪物会移到范围中点；方向与长度可再改。';
 else if(type==='path')hint='拖出路线起点和终点；完成后自动进入选择模式，拖金色控制点调整曲线。';
 else if(C.segment(type))hint='在白纸上拖动绘制'+names[type]+'；右侧可改长度、角度和粗细。'+(type==='spikes'?' 地刺可在属性中翻转朝向。':'');
 else hint='点击白纸放置'+names[type]+'。'+(type.startsWith('laser-')?'放置后在右侧修改朝向。':'');
 $('tool-hint').textContent=hint;canvas.style.cursor=type==='select'?'default':'crosshair';
}
function field(parent,label,value,min,max,fn){const l=document.createElement('label');l.textContent=label;const input=document.createElement('input');input.type='number';input.min=min;input.max=max;input.step='1';input.value=Math.round(value*10)/10;input.setAttribute('aria-label',label);input.onchange=()=>{const n=Number(input.value);if(!Number.isFinite(n)||n<min||n>max){toast('数值超出允许范围');inspector();return;}transact(()=>fn(chosen(),n));};l.append(input);parent.append(l);}
function action(parent,label,fn){const b=document.createElement('button');b.textContent=label;b.type='button';b.onclick=fn;parent.append(b);}
function inspector(){
 const panel=$('inspector');panel.replaceChildren();const i=chosen();if(!i){const p=document.createElement('p');p.className='muted';p.textContent='选中部件后可改位置、长度与方向。曲线的金色点控制弯曲。';panel.append(p);return;}
 const title=document.createElement('p');title.className='selected-title';title.textContent=names[i.type]+' #'+i.id;panel.append(title);const fields=document.createElement('div');fields.className='fields';panel.append(fields);const origin=C.segment(i.type)?i.a:i;
 field(fields,'位置 X',origin.x,0,960,(v,n)=>C.move(v,n-(C.segment(v.type)?v.a.x:v.x),0));field(fields,'位置 Y',origin.y,0,540,(v,n)=>C.move(v,0,n-(C.segment(v.type)?v.a.y:v.y)));
 if(C.segment(i.type)){
  if(i.type==='path'){
   field(fields,'终点 X',i.b.x,0,960,(v,n)=>v.b.x=n);field(fields,'终点 Y',i.b.y,0,540,(v,n)=>v.b.y=n);field(fields,'控制点 X',i.control.x,0,960,(v,n)=>v.control.x=n);field(fields,'控制点 Y',i.control.y,0,540,(v,n)=>v.control.y=n);
  }else{
   field(fields,'长度',C.length(i),1,1101,(v,n)=>C.resize(v,n,C.angle(v.a,v.b)));field(fields,'线段角度 °',C.angle(i.a,i.b),0,360,(v,n)=>C.resize(v,C.length(v),n));field(fields,i.type==='spikes'?'刺高':'墙厚',i.thickness,1,80,(v,n)=>v.thickness=n);
  }
  if(i.type==='spikes'){const p=document.createElement('p');p.className='direction-note';p.textContent='尖刺朝向 '+Math.round(C.spikeAngle(i))+'°（0右 · 90下 · 180左 · 270上）';panel.append(p);const actions=document.createElement('div');actions.className='property-actions';action(actions,'翻转地刺朝向',()=>transact(()=>chosen().side*=-1));panel.append(actions);}
 }else if(i.type.startsWith('laser-')){
  field(fields,'朝向角度 °',i.angle,0,360,(v,n)=>v.angle=n%360);const actions=document.createElement('div');actions.className='property-actions';for(const [text,n]of [['↑',270],['→',0],['↓',90],['←',180]])action(actions,text,()=>transact(()=>chosen().angle=n));panel.append(actions);
 }else if(i.type==='enemy'){
  const l=document.createElement('label');l.className='check-label';const check=document.createElement('input');check.type='checkbox';check.checked=!!i.patrol;check.onchange=()=>transact(()=>{const v=chosen();if(check.checked)C.patrol(v,[Math.max(0,v.x-80),v.y],[Math.min(960,v.x+80),v.y]);else v.patrol=null;});l.append(check,document.createTextNode('启用移动范围'));panel.append(l);
  if(i.patrol){field(fields,'范围长度',C.length(i.patrol),1,1101,(v,n)=>{const r=C.angle(v.patrol.a,v.patrol.b)*Math.PI/180;C.patrol(v,[v.x-Math.cos(r)*n/2,v.y-Math.sin(r)*n/2],[v.x+Math.cos(r)*n/2,v.y+Math.sin(r)*n/2]);});field(fields,'范围方向 °',C.angle(i.patrol.a,i.patrol.b),0,360,(v,n)=>{const r=n*Math.PI/180,len=C.length(v.patrol);C.patrol(v,[v.x-Math.cos(r)*len/2,v.y-Math.sin(r)*len/2],[v.x+Math.cos(r)*len/2,v.y+Math.sin(r)*len/2]);});}
  const a=document.createElement('div');a.className='property-actions';action(a,'在画布拖动设置范围',()=>setTool('patrol'));panel.append(a);
 }
 const note=document.createElement('p');note.className='direction-note';note.textContent=i.type==='path'?'路线按创建顺序编号。提交后由助手计算比例，不把箭头当作真实物理轨迹。':i.type.startsWith('laser-')?'0°向右，90°向下；短箭头只标朝向，不模拟传播。':'选择模式下可拖动部件；墙/刺可拖两端改变形状。';panel.append(note);
}
function layers(){const list=$('layers');list.replaceChildren();for(const i of H.doc.items){const b=document.createElement('button');b.textContent=names[i.type]+' #'+i.id;b.className=i.id===selected?'selected':'';b.onclick=()=>{selected=i.id;setTool('select');sync();};list.append(b);}}
function point(e){const r=canvas.getBoundingClientRect();return [Math.max(0,Math.min(960,(e.clientX-r.left)/r.width*960)),Math.max(0,Math.min(540,(e.clientY-r.top)/r.height*540))].map(Math.round);}
canvas.onpointerdown=e=>{
 if(e.button!==0)return;const p=point(e);canvas.setPointerCapture(e.pointerId);
 if(tool==='select'){
  const i=chosen(),handle=handles(i).find(h=>Math.hypot(h.p.x-p[0],h.p.y-p[1])<=12);
  if(handle)gesture={mode:'handle',key:handle.key,before:structuredClone(H.doc),start:p};
  else{const item=[...H.doc.items].reverse().find(i=>C.hit(i,p));selected=item?item.id:null;gesture=item?{mode:'move',before:structuredClone(H.doc),original:structuredClone(item),start:p}:null;}
  sync();return;
 }
 if(tool==='patrol'){if(!chosen()||chosen().type!=='enemy'){setTool('select');return;}gesture={mode:'patrol',start:p};draft={type:'patrol',a:{x:p[0],y:p[1]},b:{x:p[0],y:p[1]}};return;}
 if(C.segment(tool)){gesture={mode:'draw',type:tool,start:p};draft=C.place(C.create(),tool,p,p);render();}
 else transact(()=>{selected=C.place(H.doc,tool,p).id;});
};
canvas.onpointermove=e=>{
 const p=point(e);$('cursor').textContent='X '+p[0]+' · Y '+p[1];if(!gesture)return;
 if(gesture.mode==='draw'||gesture.mode==='patrol'){
  draft.b={x:p[0],y:p[1]};if(draft.type==='path')draft.control={x:(draft.a.x+draft.b.x)/2,y:Math.max(0,(draft.a.y+draft.b.y)/2-80)};
 }else if(gesture.mode==='move'){
  const item=structuredClone(gesture.original);C.move(item,p[0]-gesture.start[0],p[1]-gesture.start[1]);H.doc.items[H.doc.items.findIndex(i=>i.id===item.id)]=item;
 }else if(gesture.mode==='handle'){chosen()[gesture.key]={x:p[0],y:p[1]};}
 render();
};
canvas.onpointerup=e=>{
 if(canvas.hasPointerCapture(e.pointerId))canvas.releasePointerCapture(e.pointerId);if(!gesture)return;const g=gesture;gesture=null;
 if(g.mode==='draw'||g.mode==='patrol'){
  const end=draft.b;draft=null;if(Math.hypot(end.x-g.start[0],end.y-g.start[1])<3){render();return;}
  if(g.mode==='patrol'){transact(()=>C.patrol(chosen(),g.start,[end.x,end.y]));setTool('select');}
  else{transact(()=>selected=C.place(H.doc,g.type,g.start,[end.x,end.y]).id);if(g.type==='path')setTool('select');}
 }else{const after=H.doc;if(JSON.stringify(after)!==JSON.stringify(g.before)){H.doc=g.before;C.checkpoint(H);H.doc=after;changed();}else sync();}
};
canvas.onpointercancel=()=>{if(gesture&&gesture.before)H.doc=gesture.before;gesture=null;draft=null;sync();};
document.querySelectorAll('[data-type]').forEach(b=>b.onclick=()=>setTool(b.dataset.type));
function remove(){if(chosen())transact(()=>{H.doc.items=H.doc.items.filter(i=>i.id!==selected);selected=null;});}
$('delete').onclick=remove;$('undo').onclick=()=>{C.undo(H);loadFields();changed();};$('redo').onclick=()=>{C.redo(H);loadFields();changed();};$('grid').onchange=()=>render();
$('zoom').onchange=()=>{$('paper-wrap').style.width=$('zoom').value==='fit'?'100%':960*Number($('zoom').value)+'px';};
$('title').oninput=()=>{H.doc.title=$('title').value;persist();};$('notes').oninput=()=>{H.doc.notes=$('notes').value;persist();};
function download(blob,name){const url=URL.createObjectURL(blob),a=document.createElement('a');a.href=url;a.download=name;document.body.append(a);a.click();a.remove();setTimeout(()=>URL.revokeObjectURL(url),30000);}
const stamp=()=>new Date().toISOString().replace(/[:.]/g,'-').slice(0,19);
$('submit').onclick=()=>{download(new Blob([JSON.stringify(H.doc,null,2)],{type:'application/json'}),'PortalHop-关卡设计-'+stamp()+'.json');toast('已导出部件与曲线路线。请将 JSON 发回对话，我再计算并调整比例。');};
$('png').onclick=()=>{render(false);canvas.toBlob(blob=>{if(blob)download(blob,'PortalHop-关卡草图-'+stamp()+'.png');else toast('导出图片失败，请先导出 JSON 保存');render();},'image/png');};
function confirmAction(title,detail){return new Promise(resolve=>{const d=$('confirm');$('confirm-title').textContent=title;$('confirm-detail').textContent=detail;d.returnValue='cancel';d.addEventListener('close',()=>resolve(d.returnValue==='ok'),{once:true});d.showModal();});}
function loadFields(){$('title').value=H.doc.title;$('notes').value=H.doc.notes;}
$('new').onclick=async()=>{if(await confirmAction('新建空白关卡？','将清空当前画布。请先导出 JSON 保存；新建后仍可撤销。')){transact(()=>{const next=C.create();H.doc=next;selected=null;recovery=null;$('recover').hidden=true;});loadFields();setTool('select');}};
$('import').onclick=()=>$('file').click();$('file').onchange=async e=>{const file=e.target.files[0];if(!file)return;try{const next=C.parse(await file.text());if(await confirmAction('载入这张关卡草图？','会替换当前画布，可撤销。请先导出当前布局作为备份。')){transact(()=>{H.doc=next;selected=null;recovery=null;$('recover').hidden=true;});loadFields();setTool('select');}}catch(error){toast(error.message||'导入失败，当前地图未更改');}finally{e.target.value='';}};
$('recover').onclick=()=>download(new Blob([recovery],{type:'application/json'}),'PortalHop-布局恢复备份-'+stamp()+'.json');
document.addEventListener('keydown',e=>{if(/INPUT|TEXTAREA|SELECT/.test(e.target.tagName)||document.querySelector('dialog[open]'))return;if(e.key==='Delete'||e.key==='Backspace'){e.preventDefault();remove();}if((e.ctrlKey||e.metaKey)&&e.key.toLowerCase()==='z'){e.preventDefault();if(e.shiftKey)C.redo(H);else C.undo(H);loadFields();changed();}if(e.key==='Escape'){if(gesture&&gesture.before)H.doc=gesture.before;gesture=null;draft=null;setTool('select');sync();}});
loadFields();setTool('select');sync();$('save-state').textContent=recovery!==null?'旧数据受保护 · 请导出 JSON':'本地编辑器已就绪';
