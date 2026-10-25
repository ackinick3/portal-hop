'use strict';
const C=ReviewCore,S=MAP_REVIEW_SOURCE,KEY='portal-hop-map-review-v1';
const $=id=>document.getElementById(id),canvas=$('map'),ctx=canvas.getContext('2d');
let doc=C.create(S.revision),page=0,tool='pen',draft=null,images=[],textTarget=null,toastTimer,recovery=null;
function toast(message){$('toast').textContent=message;$('toast').hidden=false;clearTimeout(toastTimer);toastTimer=setTimeout(()=>$('toast').hidden=true,5000);}
try{const state=C.restore(localStorage.getItem(KEY),S.revision);doc=state.document;recovery=state.recovery;if(recovery){$('recover').hidden=false;toast('旧数据无法载入，已禁止自动覆盖。请导出旧数据；当前新意见请用 JSON 备份。');}}catch(e){toast('浏览器存储不可用，请使用 JSON 导出保存。');}
function id(){return C.ids[page];}
function persist(){
 if(recovery!==null){$('save-state').textContent='旧数据受保护 · 当前意见请导出 JSON 保存';return;}
 try{localStorage.setItem(KEY,JSON.stringify(doc));$('save-state').textContent='已保存到当前浏览器 · '+new Date().toLocaleTimeString('zh-CN',{hour:'2-digit',minute:'2-digit'});}catch(e){$('save-state').textContent='自动保存失败，请导出 JSON 备份';toast('浏览器存储不可用或空间不足，请导出全部批注保存。');}
}
function revisionStatus(){ $('revision').textContent=doc.revision===S.revision?'计划图版本 '+S.revision:'计划图已更新；当前批注来自 '+doc.revision+'，请核对旧位置。'; }
function drawItem(g,item,index){
 g.strokeStyle=item.color;g.fillStyle=item.color;g.lineWidth=item.width||3;g.lineCap='round';g.lineJoin='round';
 if(item.kind==='text'){
  const x=Math.min(item.x,925),y=Math.max(28,Math.min(item.y,510));
  g.font='bold 13px "Microsoft YaHei",sans-serif';g.fillStyle='#101e2dee';g.fillRect(x-12,y-16,25,25);g.fillStyle=item.color;g.fillText(String(index+1),x-7,y+1);
  g.font='15px "Microsoft YaHei",sans-serif';const lines=[];
  for(const part of item.text.split('\n')){let line='';for(const char of part){if(g.measureText(line+char).width>Math.min(260,Math.max(90,940-x))){lines.push(line);line='';}line+=char;}lines.push(line);}
  const left=x>650?Math.max(8,x-280):x+20,top=Math.max(25,Math.min(y,530-Math.min(lines.length,8)*21));
  const shown=lines.slice(0,8);if(lines.length>8)shown[7]='…全文见右侧列表 / JSON';g.fillStyle='#0b1624ef';g.fillRect(left-6,top-17,Math.min(280,Math.max(...shown.map(s=>g.measureText(s).width),30))+12,shown.length*21+5);g.fillStyle=item.color;shown.forEach((s,i)=>g.fillText(s,left,top+i*21));
  return;
 }
 const pts=item.points;g.beginPath();g.moveTo(...pts[0]);for(const p of pts.slice(1))g.lineTo(...p);g.stroke();
 if(item.kind==='arrow'){
  const a=pts[0],b=pts[pts.length-1],angle=Math.atan2(b[1]-a[1],b[0]-a[0]);g.beginPath();g.moveTo(b[0]-16*Math.cos(angle-.5),b[1]-16*Math.sin(angle-.5));g.lineTo(...b);g.lineTo(b[0]-16*Math.cos(angle+.5),b[1]-16*Math.sin(angle+.5));g.stroke();
 }
}
function render(){
 ctx.setTransform(2,0,0,2,0,0);ctx.fillStyle='#19283a';ctx.fillRect(0,0,960,540);
 if(images[page])ctx.drawImage(images[page],0,0,960,540);
 doc.pages[id()].forEach((item,i)=>drawItem(ctx,item,i));if(draft)drawItem(ctx,draft,doc.pages[id()].length);
}
function list(){
 const items=doc.pages[id()];$('annotation-count').textContent=items.length+' 条标记';$('undo').disabled=!items.length;$('clear').disabled=!items.length&&!doc.notes[id()];
 $('annotation-list').replaceChildren();
 if(!items.length){const e=document.createElement('div');e.className='empty';e.textContent='还没有图上批注，直接在地图上开始。';$('annotation-list').append(e);}
 items.forEach((item,index)=>{
  const box=document.createElement('div');box.className='annotation';const top=document.createElement('div');top.className='annotation-top';
  const label=document.createElement('span');label.textContent=(index+1)+' · '+({pen:'画笔',arrow:'箭头',text:'文字'}[item.kind]);top.append(label);
  const remove=document.createElement('button');remove.textContent='删除';remove.setAttribute('aria-label','删除第'+(index+1)+'条批注');remove.onclick=()=>{items.splice(index,1);changed();};top.append(remove);box.append(top);
  if(item.kind==='text'){const edit=document.createElement('button');edit.className='edit-text';const p=document.createElement('p');p.textContent=item.text;edit.append(p);edit.onclick=()=>editText(index);box.append(edit);}
  $('annotation-list').append(box);
 });
}
function changed(){persist();render();list();revisionStatus();}
function showPage(n){draft=null;page=Math.max(0,Math.min(4,n));$('map-title').textContent=S.maps[page].title;$('page-count').textContent=(page+1)+' / 5';$('previous').disabled=page===0;$('next').disabled=page===4;$('general-note').value=doc.notes[id()];render();list();revisionStatus();}
function editText(index,point){
 textTarget={id:id(),index,point,color:$('color').value};$('text-dialog-title').textContent=index==null?'添加文字批注':'编辑文字批注';$('text-value').value=index==null?'':doc.pages[id()][index].text;$('text-dialog').showModal();$('text-value').focus();
}
canvas.addEventListener('pointerdown',e=>{
 if(e.button!==0)return;const p=C.point(e.clientX,e.clientY,canvas.getBoundingClientRect());
 if(tool==='text'){editText(null,p);return;}
 canvas.setPointerCapture(e.pointerId);draft={kind:tool,points:[p,p],color:$('color').value,width:Number($('width').value)};render();
});
canvas.addEventListener('pointermove',e=>{if(!draft)return;const p=C.point(e.clientX,e.clientY,canvas.getBoundingClientRect());if(draft.kind==='arrow')draft.points[1]=p;else if(draft.points.length<10000)draft.points.push(p);render();});
canvas.addEventListener('pointerup',e=>{if(!draft)return;C.add(doc,id(),draft);draft=null;if(canvas.hasPointerCapture(e.pointerId))canvas.releasePointerCapture(e.pointerId);changed();});
canvas.addEventListener('pointercancel',()=>{draft=null;render();});
$('text-form').onsubmit=e=>{
 e.preventDefault();const text=$('text-value').value.trim();if(!text)return;
 if(textTarget.index==null)C.add(doc,textTarget.id,{kind:'text',x:textTarget.point[0],y:textTarget.point[1],text,color:textTarget.color});else doc.pages[textTarget.id][textTarget.index].text=text;
 $('text-dialog').close();changed();
};
$('cancel-text').onclick=()=>$('text-dialog').close();
document.querySelectorAll('[data-tool]').forEach(button=>button.onclick=()=>{tool=button.dataset.tool;document.body.dataset.tool=tool;document.querySelectorAll('[data-tool]').forEach(b=>b.setAttribute('aria-pressed',String(b===button)));});
$('previous').onclick=()=>showPage(page-1);$('next').onclick=()=>showPage(page+1);$('undo').onclick=()=>{C.undo(doc,id());changed();};
$('general-note').addEventListener('input',()=>{doc.notes[id()]=$('general-note').value;persist();$('clear').disabled=false;});
function confirmAction(title,detail){return new Promise(resolve=>{const dialog=$('confirm-dialog');$('confirm-title').textContent=title;$('confirm-detail').textContent=detail;dialog.returnValue='cancel';dialog.addEventListener('close',()=>resolve(dialog.returnValue==='ok'),{once:true});dialog.showModal();});}
$('clear').onclick=async()=>{if(await confirmAction('清空本关的批注？','仅清空当前关卡的标记与整体意见，其他关卡保留。')){doc.pages[id()]=[];doc.notes[id()]='';$('general-note').value='';changed();}};
function download(blob,name){const url=URL.createObjectURL(blob),a=document.createElement('a');a.href=url;a.download=name;document.body.append(a);a.click();a.remove();setTimeout(()=>URL.revokeObjectURL(url),30000);}
function stamp(){return new Date().toISOString().replace(/[:.]/g,'-').slice(0,19);}
$('export-json').onclick=()=>{download(new Blob([JSON.stringify(doc,null,2)],{type:'application/json'}),'PortalHop-全部批注-'+stamp()+'.json');toast('已导出全部批注。把 JSON 文件发回对话即可。');};
$('recover').onclick=()=>{download(new Blob([recovery],{type:'application/json'}),'PortalHop-旧数据恢复备份-'+stamp()+'.json');toast('已导出旧数据原文。当前新意见请另用「导出全部批注」保存。');};
$('export-png').onclick=()=>{draft=null;render();canvas.toBlob(blob=>{if(blob){download(blob,'PortalHop-'+id()+'-批注-'+stamp()+'.png');toast('已导出当前地图与图上批注；整体意见请使用 JSON 保存。');}else toast('图片导出失败，请先导出 JSON 保存批注。');},'image/png');};
$('import-json').onclick=()=>$('import-file').click();
$('import-file').onchange=async e=>{
 const file=e.target.files[0];if(!file)return;
 try{
  const next=C.importDocument(await file.text());
  if(await confirmAction('载入这份批注？','将替换网页里五关的当前批注。建议先导出当前内容作为备份。')){doc=next;recovery=null;$('recover').hidden=true;showPage(page);persist();toast('批注已载入。');}
 }catch(error){toast(error.message||'导入失败，现有批注未更改。');}finally{e.target.value='';}
};
$('zoom').onchange=()=>{const value=$('zoom').value;$('canvas-wrap').style.width=value==='fit'?'100%':(960*Number(value))+'px';};
document.addEventListener('keydown',e=>{if(/INPUT|TEXTAREA|SELECT/.test(e.target.tagName)||document.querySelector('dialog[open]'))return;if(e.key==='ArrowRight')showPage(page+1);if(e.key==='ArrowLeft')showPage(page-1);if((e.ctrlKey||e.metaKey)&&e.key==='z'){e.preventDefault();C.undo(doc,id());changed();}});
async function initialize(){
 try{
  images=await Promise.all(S.maps.map(map=>new Promise((resolve,reject)=>{
   const svg=new DOMParser().parseFromString(S.svg,'image/svg+xml').documentElement;svg.setAttribute('viewBox',map.viewBox);svg.setAttribute('width','960');svg.setAttribute('height','540');
   const image=new Image();image.onload=()=>resolve(image);image.onerror=reject;image.src='data:image/svg+xml;charset=utf-8,'+encodeURIComponent(new XMLSerializer().serializeToString(svg));
  })));
  showPage(0);$('save-state').textContent=recovery!==null?'旧数据受保护 · 当前意见请导出 JSON 保存':'本地批注已就绪 · 自动保存到当前浏览器';
 }catch(e){$('save-state').textContent='地图载入失败';toast('底图载入失败，请重新打开完整的地图批注.html。');}
}
initialize();
