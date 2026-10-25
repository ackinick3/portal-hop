const {test} = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
test('generated standalone page embeds the original SVG losslessly',()=>{
 const html=fs.readFileSync(path.join(__dirname,'../地图批注.html'),'utf8');
 const data=html.match(/<script>(const MAP_REVIEW_SOURCE = [\s\S]*?)<\/script>/)[1];
 const embedded=vm.runInNewContext(data+';MAP_REVIEW_SOURCE');
 assert.equal(embedded.svg,fs.readFileSync(path.join(__dirname,'../五关布局示意.svg'),'utf8'));
 assert.equal(embedded.maps.length,5);
});
test('review core exists',()=>assert.ok(fs.existsSync(path.join(__dirname,'review-core.js')),'missing annotation implementation'));
if(fs.existsSync(path.join(__dirname,'review-core.js'))){
 const C=require('./review-core.js');
 test('long-lived review exports over 1000 comments and 5MB remain importable',()=>{
  const d=C.create('r1');for(let i=0;i<3000;i++)C.add(d,'A',{kind:'text',x:20,y:20,text:'x'.repeat(2000),color:'#ffffff'});
  const json=JSON.stringify(d);assert.ok(json.length>5*1024*1024);assert.equal(C.importDocument(json).pages.A.length,3000);
 });
 test('unreadable browser storage is retained for recovery rather than discarded',()=>{
  const raw='{partial invalid backup';const state=C.restore(raw,'r1');assert.equal(state.recovery,raw);assert.equal(state.document.pages.A.length,0);
  const good=C.restore(JSON.stringify(C.create('old')),'new');assert.equal(good.recovery,null);assert.equal(good.document.revision,'old');
 });
 test('pages remain isolated and undo affects only the selected map',()=>{
  const d=C.create('r1'); C.add(d,'A',{kind:'text',x:30,y:50,text:'连接这里',color:'#ff0000'});
  C.add(d,'B',{kind:'arrow',points:[[10,20],[80,90]],color:'#ffffff',width:3});
  C.undo(d,'B');assert.equal(d.pages.A.length,1);assert.equal(d.pages.B.length,0);
 });
 test('JSON round trip keeps map identity, strokes, text and general notes',()=>{
  const d=C.create('r1');d.notes.E='下方连成地面';C.add(d,'E',{kind:'pen',points:[[0,0],[960,540]],color:'#aabbcc',width:4});
  C.add(d,'C',{kind:'text',x:120,y:90,text:'<script>test</script>',color:'#ffffff'});
  assert.deepEqual(C.importDocument(JSON.stringify(d),'r1'),d);
 });
 test('malformed/unknown/out of bounds imports reject without mutating current annotations',()=>{
  const d=C.create('r1');C.add(d,'A',{kind:'text',x:20,y:20,text:'保留',color:'#ffffff'});const before=JSON.stringify(d);
  for(const bad of ['{',JSON.stringify({...d,format:'wrong'}),JSON.stringify({...d,pages:{...d.pages,Z:[]}}),JSON.stringify({...d,pages:{...d.pages,A:[{kind:'text',x:1e12,y:20,text:'bad',color:'#ffffff'}]}})])assert.throws(()=>C.importDocument(bad,'r1'));
  assert.equal(JSON.stringify(d),before);
 });
 test('revised base map preserves earlier comments and their revision identity',()=>{
  const d=C.create('old');C.add(d,'D',{kind:'text',x:4,y:8,text:'加速坡',color:'#ffffff'});
  const loaded=C.importDocument(JSON.stringify(d),'new');assert.equal(loaded.revision,'old');assert.equal(loaded.pages.D[0].text,'加速坡');
 });
 test('screen coordinates map into the same 960x540 space at different zooms',()=>{
  assert.deepEqual(C.point(500,300,{left:20,top:30,width:960,height:540}),[480,270]);
  assert.deepEqual(C.point(260,165,{left:20,top:30,width:480,height:270}),[480,270]);
 });
}
