'use strict';
// Read-only inventory; the project's editor remains the schema authority.
const fs=require('node:fs');
const path=require('node:path');
const crypto=require('node:crypto');

try{
 if(process.argv.length!==4)throw new Error('Usage: node inspect-sketch.cjs <project-root> <sketch.json>');
 const project=path.resolve(process.argv[2]),input=path.resolve(process.argv[3]);
 const core=require(path.join(project,'docs/level-editor/core.js'));
 const bytes=fs.readFileSync(input);
 const doc=core.parse(bytes.toString('utf8').replace(/^\uFEFF/,''));
 const counts={};
 for(const item of doc.items)counts[item.type]=(counts[item.type]||0)+1;
 const start=doc.items.find(i=>i.type==='start')||null;
 const goal=doc.items.find(i=>i.type==='goal')||null;
 const report={
  input,sha256:crypto.createHash('sha256').update(bytes).digest('hex'),
  format:doc.format,version:doc.version,width:doc.width,height:doc.height,
  title:doc.title,notes:doc.notes,itemCount:doc.items.length,counts,
  start,goal,hasBothAnchors:!!(start&&goal),
  walls:doc.items.filter(i=>i.type.startsWith('wall-')).map(i=>({...i,length:core.length(i),angle:core.angle(i.a,i.b)})),
  routes:doc.items.filter(i=>i.type==='path').map((i,index)=>({...i,order:index+1})),
  objects:doc.items.filter(i=>!i.type.startsWith('wall-')&&!['path','start','goal'].includes(i.type)),
  zeroLengthSegments:doc.items.filter(i=>core.segment(i.type)&&core.length(i)<0.001).map(i=>i.id)
 };
 process.stdout.write(JSON.stringify(report,null,2)+'\n');
}catch(error){
 process.stderr.write('SKETCH_ERROR: '+error.message+'\n');
 process.exitCode=1;
}
