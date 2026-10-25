const fs=require('node:fs'),path=require('node:path');const dir=__dirname;let html=fs.readFileSync(path.join(dir,'page.html'),'utf8');
for(const [key,file] of [['STYLE','style.css'],['CORE','core.js'],['APP','app.js']])html=html.replace('/*'+key+'*/',()=>fs.readFileSync(path.join(dir,file),'utf8'));
const target=path.join(dir,'../关卡编辑器.html');fs.writeFileSync(target,html);console.log('Built '+target);
