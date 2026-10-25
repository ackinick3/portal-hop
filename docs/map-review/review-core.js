(function(root){
 'use strict';
 const ids=['A','B','C','D','E'];
 function create(revision){return {format:'portal-hop-map-review',version:1,revision,pages:Object.fromEntries(ids.map(id=>[id,[]])),notes:Object.fromEntries(ids.map(id=>[id,'']))};}
 function add(doc,id,item){doc.pages[id].push(item);}
 function undo(doc,id){return doc.pages[id].pop();}
 function point(x,y,rect){return [Math.round(Math.max(0,Math.min(960,(x-rect.left)/rect.width*960))),Math.round(Math.max(0,Math.min(540,(y-rect.top)/rect.height*540)))];}
 function importDocument(text){
  const data=JSON.parse(text),fail=()=>{throw new Error('批注文件格式不正确，请选择本网页导出的 JSON。');};
  if(!data||data.format!=='portal-hop-map-review'||data.version!==1||typeof data.revision!=='string'||data.revision.length>100||!data.pages||!data.notes)fail();
  if(Object.keys(data.pages).sort().join('')!==ids.join('')||Object.keys(data.notes).sort().join('')!==ids.join(''))fail();
  const result=create(data.revision);
  const xy=p=>Array.isArray(p)&&p.length===2&&p.every(Number.isFinite)&&p[0]>=0&&p[0]<=960&&p[1]>=0&&p[1]<=540;
  for(const id of ids){
   if(!Array.isArray(data.pages[id])||typeof data.notes[id]!=='string'||data.notes[id].length>5000)fail();
   result.notes[id]=data.notes[id];
   for(const item of data.pages[id]){
    if(!item||!/^#[0-9a-f]{6}$/i.test(item.color))fail();
    if(item.kind==='text'){
     if(!xy([item.x,item.y])||typeof item.text!=='string'||!item.text.trim()||item.text.length>2000)fail();
     result.pages[id].push({kind:'text',x:item.x,y:item.y,text:item.text,color:item.color});
    }else if(item.kind==='pen'||item.kind==='arrow'){
     if(!Array.isArray(item.points)||item.points.length<2||item.points.length>10000||!item.points.every(xy)||!Number.isFinite(item.width)||item.width<1||item.width>12)fail();
     result.pages[id].push({kind:item.kind,points:item.points.map(p=>p.slice()),color:item.color,width:item.width});
    }else fail();
   }
  }
  return result;
 }
 function restore(text,revision){try{return {document:text?importDocument(text):create(revision),recovery:null};}catch(e){return {document:create(revision),recovery:text};}}
 const api={ids,create,add,undo,point,importDocument,restore};
 if(typeof module!=='undefined'&&module.exports)module.exports=api;else root.ReviewCore=api;
})(globalThis);
