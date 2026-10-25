const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto');
const dir=__dirname,docs=path.dirname(dir),svg=fs.readFileSync(path.join(docs,'五关布局示意.svg'),'utf8');
const titles=['A · 折返弹射','B · 二次落点','C · 刺坑折返','D · 跃坑接弹','E · 双侧接力'];
const source={revision:crypto.createHash('sha256').update(svg).digest('hex').slice(0,12),svg,maps:titles.map((title,i)=>({id:'ABCDE'[i],title,viewBox:`${i%2*960} ${Math.floor(i/2)*580+40} 960 540`}))};
let html=fs.readFileSync(path.join(dir,'page.html'),'utf8');
const replacements={STYLE:fs.readFileSync(path.join(dir,'style.css'),'utf8'),DATA:'const MAP_REVIEW_SOURCE = '+JSON.stringify(source).replace(/</g,'\\u003c')+';',CORE:fs.readFileSync(path.join(dir,'review-core.js'),'utf8'),APP:fs.readFileSync(path.join(dir,'app.js'),'utf8')};
for(const [key,value]of Object.entries(replacements))html=html.replace('/*'+key+'*/',()=>value);
const target=path.join(docs,'地图批注.html');fs.writeFileSync(target,html);console.log('Built '+target+' · revision '+source.revision);
