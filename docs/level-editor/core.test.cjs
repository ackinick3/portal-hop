const {test}=require('node:test'),assert=require('node:assert/strict'),fs=require('node:fs'),path=require('node:path');
test('standalone HTML contains inline resources and parseable scripts',()=>{
 const html=fs.readFileSync(path.join(__dirname,'../关卡编辑器.html'),'utf8');
 assert.ok(!/\/\*(STYLE|CORE|APP)\*\//.test(html));assert.ok(!/<script[^>]+src=/.test(html));
 const scripts=[...html.matchAll(/<script>([\s\S]*?)<\/script>/g)];assert.equal(scripts.length,2);
 for(const s of scripts)new (require('node:vm').Script)(s[1]);
});
test('editor data implementation exists',()=>assert.ok(fs.existsSync(path.join(__dirname,'core.js')),'missing level editor implementation'));
if(fs.existsSync(path.join(__dirname,'core.js'))){
 const C=require('./core.js');
 test('moving platforms preserve rectangle, material and ordered center track across edits',()=>{
  const d=C.create(),p=C.place(d,'moving-platform',[100,200],[220,224]);
  assert.deepEqual([p.x,p.y,p.width,p.height,p.material],[160,212,120,24,'gray']);
  C.trackPoint(p,1,[450,350]);C.trackPoint(p,2,[450,100]);p.material='red';
  assert.deepEqual(C.parse(JSON.stringify(d)),d);
  assert.equal(C.hit(p,[210,220]),true);assert.equal(C.hit(p,[230,220]),false);
  const old=structuredClone(p);C.move(p,2000,2000);
  assert.equal(p.track[1].x-p.track[0].x,old.track[1].x-old.track[0].x);
  for(const q of p.track){assert.ok(q.x+p.width/2<=960);assert.ok(q.y+p.height/2<=540);}
  C.trackPoint(p,0,[0,0]);assert.equal(p.x,60);assert.equal(p.y,12);assert.deepEqual(p.track[0],{x:p.x,y:p.y});
 });
 test('platform imports reject invalid sizes, materials, tracks and extra track fields on other parts',()=>{
  const d=C.create();C.place(d,'moving-platform',[100,100],[200,120]);
  for(const mutate of [p=>p.width=0,p=>p.height=541,p=>p.material='white',p=>p.track=[],p=>p.track=[{x:0,y:0}],p=>p.track.push({x:959,y:200}),p=>p.track[0].x+=1]){
   const bad=structuredClone(d);mutate(bad.items[0]);assert.throws(()=>C.parse(JSON.stringify(bad)));
  }
  const old=C.create();C.place(old,'start',[50,60]);assert.deepEqual(C.parse(JSON.stringify(old)),old);old.items[0].track=[{x:50,y:60}];assert.throws(()=>C.parse(JSON.stringify(old)));
 });
 test('gun screen is editable segment and new parts survive undo redo',()=>{
  const h=C.history(C.create());C.checkpoint(h);const s=C.place(h.doc,'gun-screen',[100,50],[100,250]);
  assert.equal(C.segment(s.type),true);assert.equal(C.hit(s,[105,150]),true);C.resize(s,300,0);assert.equal(s.b.x,400);
  C.checkpoint(h);C.place(h.doc,'moving-platform',[300,300],[400,320]);const saved=structuredClone(h.doc);C.undo(h);assert.equal(h.doc.items.length,1);C.redo(h);assert.deepEqual(C.parse(JSON.stringify(h.doc)),saved);
 });
 test('imports reject unrelated geometry fields that would break moving a part',()=>{
  const d=C.create();C.place(d,'start',[50,60]);C.place(d,'wall-gray',[100,100],[200,100]);
  const badStart=structuredClone(d);badStart.items[0].patrol={a:null,b:null};assert.throws(()=>C.parse(JSON.stringify(badStart)));
  const badWall=structuredClone(d);badWall.items[1].control='bad';assert.throws(()=>C.parse(JSON.stringify(badWall)));
 });
 test('all requested parts and curved paths round trip without losing settings',()=>{
  const d=C.create();for(const type of C.types)C.place(d,type,[200,220],[360,260]);
  const emitter=d.items.find(i=>i.type==='laser-purple');emitter.angle=135;
  const enemy=d.items.find(i=>i.type==='enemy');C.patrol(enemy,[100,200],[300,300]);
  const path=d.items.find(i=>i.type==='path');path.control={x:240,y:80};
  assert.deepEqual(C.parse(JSON.stringify(d)),d);
 });
 test('only one start and goal exist and a new click relocates them',()=>{
  const d=C.create();C.place(d,'start',[20,30]);C.place(d,'start',[80,90]);C.place(d,'goal',[200,210]);C.place(d,'goal',[300,310]);
  assert.equal(d.items.length,2);assert.equal(d.items[0].x,80);assert.equal(d.items[1].x,300);
 });
 test('wall and spike length/angle edits and normals are explicit',()=>{
  const d=C.create(),w=C.place(d,'wall-white',[100,100],[200,100]);C.resize(w,200,90);
  assert.ok(Math.abs(w.b.x-100)<1e-6);assert.ok(Math.abs(w.b.y-300)<1e-6);
  const s=C.place(d,'spikes',[10,30],[110,30]);assert.equal(C.spikeAngle(s),270);s.side=-1;assert.equal(C.spikeAngle(s),90);
 });
 test('dragging a complete part preserves geometry and stays within the paper',()=>{
  const d=C.create(),p=C.place(d,'path',[800,400],[900,500]);const old=structuredClone(p);C.move(p,900,900);
  assert.ok(p.b.x<=960&&p.b.y<=540);assert.equal(p.b.x-p.a.x,old.b.x-old.a.x);assert.equal(p.control.y-p.a.y,old.control.y-old.a.y);
  const enemy=C.place(d,'enemy',[400,300]);C.patrol(enemy,[300,300],[500,300]);C.move(enemy,20,-20);assert.equal(enemy.patrol.a.x,320);assert.equal(enemy.y,280);
 });
 test('curved path hit test follows the bend instead of its straight chord',()=>{
  const d=C.create(),p=C.place(d,'path',[100,300],[500,300]);p.control={x:300,y:100};assert.equal(C.hit(p,[300,200]),true);assert.equal(C.hit(p,[300,300]),false);
 });
 test('invalid coordinates, unknown parts and duplicate identifiers reject imports',()=>{
  const d=C.create();C.place(d,'start',[10,20]);C.place(d,'wall-gray',[50,50],[150,50]);const before=JSON.stringify(d);
  for(const mutate of [x=>x.items[0].x=NaN,x=>x.items[0].type='unknown',x=>x.items[1].id=x.items[0].id,x=>x.items[1].a.x=961]){const bad=structuredClone(d);mutate(bad);assert.throws(()=>C.parse(JSON.stringify(bad)));}
  assert.equal(JSON.stringify(d),before);
 });
 test('history undo and redo restore complete drawings including curves and patrols',()=>{
  const history=C.history(C.create());C.checkpoint(history);C.place(history.doc,'path',[10,20],[100,200]);C.checkpoint(history);C.place(history.doc,'enemy',[300,300]);
  C.undo(history);assert.equal(history.doc.items.length,1);C.undo(history);assert.equal(history.doc.items.length,0);C.redo(history);assert.equal(history.doc.items[0].type,'path');
 });
}
