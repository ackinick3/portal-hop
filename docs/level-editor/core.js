(function(root){
 'use strict';
 const types=['start','goal','wall-gray','wall-white','wall-blue','wall-red','wall-green','spikes','laser-yellow','laser-purple','laser-red','receiver','enemy','path','moving-platform','gun-screen'];
 const segment=t=>t.startsWith('wall-')||t==='spikes'||t==='path'||t==='gun-screen';
 const clamp=(n,a,b)=>Math.max(a,Math.min(b,n));
 const angle=(a,b)=>(Math.atan2(b.y-a.y,b.x-a.x)*180/Math.PI+360)%360;
 const length=i=>Math.hypot(i.b.x-i.a.x,i.b.y-i.a.y);
 const validPoint=p=>p&&Number.isFinite(p.x)&&Number.isFinite(p.y)&&p.x>=0&&p.x<=960&&p.y>=0&&p.y<=540;
 function create(){return {format:'portal-hop-level-sketch',version:1,width:960,height:540,title:'未命名关卡',notes:'',nextId:1,items:[]};}
 function place(doc,type,a,b){
  if(!types.includes(type))throw new Error('未知部件');
  const p={x:clamp(a[0],0,960),y:clamp(a[1],0,540)};
  if(type==='start'||type==='goal'){const old=doc.items.find(i=>i.type===type);if(old){old.x=p.x;old.y=p.y;return old;}}
  const item={id:doc.nextId++,type};
  if(type==='moving-platform'){
   const q=b?{x:clamp(b[0],0,960),y:clamp(b[1],0,540)}:{x:clamp(p.x+100,0,960),y:clamp(p.y+20,0,540)};
   item.width=Math.max(4,Math.abs(q.x-p.x));item.height=Math.max(4,Math.abs(q.y-p.y));
   item.x=clamp((p.x+q.x)/2,item.width/2,960-item.width/2);item.y=clamp((p.y+q.y)/2,item.height/2,540-item.height/2);
   item.material='gray';item.track=[{x:item.x,y:item.y}];
  }else if(segment(type)){
   item.a=p;item.b=b?{x:clamp(b[0],0,960),y:clamp(b[1],0,540)}:{x:clamp(p.x+100,0,960),y:p.y};
   if(type==='path')item.control={x:(item.a.x+item.b.x)/2,y:clamp((item.a.y+item.b.y)/2-80,0,540)};
   else item.thickness=type==='spikes'?22:type==='gun-screen'?4:20;
   if(type==='spikes')item.side=1;
  }else{item.x=p.x;item.y=p.y;item.angle=0;if(type==='enemy')item.patrol=null;}
  doc.items.push(item);return item;
 }
 function points(item){
  if(item.type==='moving-platform')return item.track.flatMap(p=>[{x:p.x-item.width/2,y:p.y-item.height/2},{x:p.x+item.width/2,y:p.y+item.height/2}]);
  return segment(item.type)?[item.a,item.b,...(item.control?[item.control]:[])]:[{x:item.x,y:item.y},...(item.patrol?[item.patrol.a,item.patrol.b]:[])];
 }
 function move(item,dx,dy){
  const pts=points(item);dx=clamp(dx,-Math.min(...pts.map(p=>p.x)),960-Math.max(...pts.map(p=>p.x)));dy=clamp(dy,-Math.min(...pts.map(p=>p.y)),540-Math.max(...pts.map(p=>p.y)));
  if(segment(item.type)){for(const p of pts){p.x+=dx;p.y+=dy;}}
  else{item.x+=dx;item.y+=dy;for(const p of item.track||(item.patrol?[item.patrol.a,item.patrol.b]:[])){p.x+=dx;p.y+=dy;}}
 }
 function trackPoint(item,index,p){
  if(item.type!=='moving-platform'||!Number.isInteger(index)||index<0||index>item.track.length||!p.every(Number.isFinite))throw new Error('无效的平台轨迹点');
  const q={x:clamp(p[0],item.width/2,960-item.width/2),y:clamp(p[1],item.height/2,540-item.height/2)};
  item.track[index]=q;if(index===0){item.x=q.x;item.y=q.y;}
 }
 function resize(item,size,degrees){
  if(!Number.isFinite(size)||size<1||!Number.isFinite(degrees))throw new Error('请输入有效长度和角度');
  const r=degrees*Math.PI/180,b={x:item.a.x+size*Math.cos(r),y:item.a.y+size*Math.sin(r)};
  b.x=Math.abs(b.x)<1e-8?0:b.x;b.y=Math.abs(b.y)<1e-8?0:b.y;
  if(!validPoint(b))throw new Error('线段超出白纸，请先移动起点或缩短长度');item.b=b;
 }
 function patrol(item,a,b){item.patrol={a:{x:clamp(a[0],0,960),y:clamp(a[1],0,540)},b:{x:clamp(b[0],0,960),y:clamp(b[1],0,540)}};item.x=(item.patrol.a.x+item.patrol.b.x)/2;item.y=(item.patrol.a.y+item.patrol.b.y)/2;}
 function curve(item,t){const u=1-t;return {x:u*u*item.a.x+2*u*t*item.control.x+t*t*item.b.x,y:u*u*item.a.y+2*u*t*item.control.y+t*t*item.b.y};}
 function distance(p,a,b){const dx=b.x-a.x,dy=b.y-a.y,t=clamp(((p.x-a.x)*dx+(p.y-a.y)*dy)/(dx*dx+dy*dy||1),0,1);return Math.hypot(p.x-a.x-t*dx,p.y-a.y-t*dy);}
 function hit(item,p){
  const q={x:p[0],y:p[1]};
  if(item.type==='moving-platform')return Math.abs(q.x-item.x)<=item.width/2&&Math.abs(q.y-item.y)<=item.height/2;
  if(item.type==='path'){let a=item.a;for(let j=1;j<=40;j++){const b=curve(item,j/40);if(distance(q,a,b)<10)return true;a=b;}return false;}
  if(segment(item.type))return distance(q,item.a,item.b)<Math.max(9,item.thickness/2+(item.type==='spikes'?item.thickness/2:3));
  if(item.type==='start')return q.x>=item.x-8&&q.x<=item.x+33&&q.y>=item.y-45&&q.y<=item.y+8;
  if(item.type==='goal')return Math.abs(q.x-item.x)<22&&q.y>=item.y-48&&q.y<=item.y+8;
  return Math.hypot(q.x-item.x,q.y-item.y)<22;
 }
 function parse(text){
  const d=JSON.parse(text),fail=()=>{throw new Error('不是有效的关卡设计 JSON，现有地图未更改');};
  if(!d||d.format!=='portal-hop-level-sketch'||d.version!==1||d.width!==960||d.height!==540||typeof d.title!=='string'||d.title.length>120||typeof d.notes!=='string'||d.notes.length>5000||!Array.isArray(d.items)||!Number.isSafeInteger(d.nextId)||d.nextId<1)fail();
  const ids=new Set();let starts=0,goals=0;
  for(const i of d.items){
   if(!i||!types.includes(i.type)||!Number.isSafeInteger(i.id)||i.id<1||i.id>=d.nextId||ids.has(i.id))fail();ids.add(i.id);
   if(i.type!=='path'&&Object.hasOwn(i,'control')||i.type!=='enemy'&&Object.hasOwn(i,'patrol')||i.type!=='moving-platform'&&Object.hasOwn(i,'track'))fail();
   if(i.type==='start'&&++starts>1||i.type==='goal'&&++goals>1)fail();
   if(i.type==='moving-platform'){
    if(!validPoint(i)||!Number.isFinite(i.width)||i.width<4||i.width>960||!Number.isFinite(i.height)||i.height<4||i.height>540||!['gray','blue','red'].includes(i.material)||!Array.isArray(i.track)||i.track.length<1||!i.track.every(validPoint))fail();
    if(i.track[0].x!==i.x||i.track[0].y!==i.y||!points(i).every(validPoint))fail();
   }else if(segment(i.type)){
    if(!validPoint(i.a)||!validPoint(i.b))fail();
    if(i.type==='path'){if(!validPoint(i.control))fail();}
    else if(!Number.isFinite(i.thickness)||i.thickness<1||i.thickness>80)fail();
    if(i.type==='spikes'&&i.side!==1&&i.side!==-1)fail();
   }else{
    if(!validPoint(i)||!Number.isFinite(i.angle)||i.angle<0||i.angle>=360)fail();
    if(i.type==='enemy'&&i.patrol!==null&&(!i.patrol||!validPoint(i.patrol.a)||!validPoint(i.patrol.b)))fail();
   }
  }
  return structuredClone(d);
 }
 function history(doc){return {doc,back:[],forward:[]};}
 function checkpoint(h){h.back.push(structuredClone(h.doc));if(h.back.length>80)h.back.shift();h.forward=[];}
 function undo(h){if(h.back.length){h.forward.push(structuredClone(h.doc));h.doc=h.back.pop();}}
 function redo(h){if(h.forward.length){h.back.push(structuredClone(h.doc));h.doc=h.forward.pop();}}
 const api={types,segment,create,place,move,resize,patrol,trackPoint,curve,hit,parse,history,checkpoint,undo,redo,angle,length,points,validPoint,spikeAngle:i=>(angle(i.a,i.b)+(i.side===1?270:90))%360};
 if(typeof module!=='undefined'&&module.exports)module.exports=api;else root.LevelCore=api;
})(globalThis);
