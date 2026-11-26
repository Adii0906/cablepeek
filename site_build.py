import os
os.chdir('/Users/diegobrugger/kabeltempo/site')
wall='''<svg class="wall" viewBox="0 0 1600 1020" preserveAspectRatio="none" aria-hidden="true"><defs><linearGradient id="s" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#8fb4cf"/><stop offset=".55" stop-color="#e9d9c6"/><stop offset=".7" stop-color="#f0c9a6"/></linearGradient></defs><rect width="1600" height="1020" fill="url(#s)"/><path d="M0 600C260 600 420 470 700 480S1180 640 1600 520V1020H0z" fill="#d9a988"/><path d="M0 720C260 560 520 620 760 700S1260 720 1600 610V1020H0z" fill="#b97f64"/><path d="M0 800C300 820 520 690 820 740S1300 860 1600 740V1020H0z" fill="#8e5a4a"/><path d="M0 930C260 800 520 830 800 890S1340 930 1600 850V1020H0z" fill="#5c3936"/></svg>'''
mac=f'''<div class="mw"><div class="mac" aria-hidden="true"><div class="scr">{wall}
<div class="pill p1"><b>10 Gb/s</b>Footage · 100 GB in about 2 min</div><div class="pill p2"><b>480 Mb/s</b>Bottleneck: cable, plug or device<br>Backup · 100 GB in about 42 min</div><div class="pill p3"><b>10 Gb/s</b>T7 Shield · 100 GB in about 2 min</div></div>
<div class="base"><i class="c l"></i><i class="c l b" style="top:1.2cqw"></i><i class="c r"></i></div></div></div>'''.replace(' style="top:1.2cqw"','')
fav="<link rel=\"icon\" href=\"data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24'%3E%3Crect width='24' height='24' rx='6' fill='%23111'/%3E%3Crect x='4' y='8.5' width='16' height='7' rx='3.5' fill='none' stroke='%23fff' stroke-width='1.7'/%3E%3Crect x='8' y='11.2' width='8' height='1.6' rx='.8' fill='%23fff'/%3E%3C/svg%3E\">"
L=[('At the port','Plug in on the left and it shows on the left. Your Mac knows where its ports are.'),
('Back on hover','Rest the pointer at the screen edge next to a port. The speed returns, with an eject button for drives. An eject is never forced.'),
('The slow part','Speed depends on cable, plug and device. If the cable has a chip, CablePeek reads it. If it cannot tell, it says so.'),
('Every port','The menu bar icon lists ports, devices and cable chips. It gets a dot when a drive runs at USB 2 speed.'),
('Charging','With only a charger on the port, CablePeek shows the negotiated watts, for USB-C and MagSafe.'),
('SD cards','Insert a card and CablePeek shows the speed of the slot connection, for example 100 MB/s, with a card icon so you can tell it from a cable.'),
('Thunderbolt','For Thunderbolt drives and docks it shows the negotiated link speed, for example 40 Gb/s, when macOS reports it. This is new, reports are welcome.'),
('Your files','It reads port information and drive names. It does not open your files. Its only network use is checking GitHub for updates and installing them, which you can turn off in the menu.'),
('Your Mac','Apple Silicon, macOS 14 or later, Liquid Glass on macOS 26. Tested on a MacBook Pro with M2 Pro. One user reported it working on a Mac mini with M4 Pro.'),
('First launch','The app is not notarized by Apple yet, so macOS warns you. If you still want to run it, open it once, then choose Open Anyway in System Settings under Privacy &amp; Security.'),
('WhatCable','Also free, with far more detail. CablePeek is only the quick look when you plug in.')]
# Buy Me a Coffee: leer = Zeile erscheint nirgends. Sobald das Konto steht, hier z. B. 'https://buymeacoffee.com/cablepeek' eintragen.
BMC='https://buymeacoffee.com/diegoespresso'
pop_c=f'<p class="cf">CablePeek is free. If it helps, you can <a class="bmc" href="{BMC}" target="_blank" rel="noopener">buy me a coffee</a>.</p>' if BMC else ''
foot_c=f'CablePeek is free. If it helps, you can <a class="bmc" href="{BMC}" target="_blank" rel="noopener">buy me a coffee</a>.<br>' if BMC else ''
D='https://github.com/diegobruegger-prog/cablepeek/releases/latest/download/CablePeek.zip'
open('index.html','w').write(f'''<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>CablePeek for Mac</title><link rel="stylesheet" href="styles.css?v=17">
<meta name="description" content="See the USB-C link speed next to the port when you plug in. Free for Mac."><meta property="og:title" content="CablePeek for Mac"><meta property="og:description" content="See the USB-C link speed next to the port when you plug in."><meta property="og:image" content="https://cablepeek.pages.dev/og.png?v=5"><meta name="twitter:card" content="summary_large_image">{fav}</head><body>
<nav><div class="w"><b>CablePeek</b><a class="btn" href="{D}">Download</a></div></nav>
<header class="hero"><div class="w"><h1>How fast is that cable?</h1><p>Plug it in. CablePeek shows the link speed<br class="d"> next to the port for four seconds.</p><a class="btn" href="{D}">Download for Mac</a><div class="g">Free for Apple Silicon. macOS 14 or later.</div></div>{mac}</header>
<section><div class="w"><h2>100 GB, two cables.</h2><p>Some USB-C cables only do USB 2. From the outside you often cannot tell.</p>
<div class="bar"><div><span>10 Gb/s</span><span>about 2 min</span></div><i style="width:4%"></i><div><span>480 Mb/s</span><span>about 42 min</span></div><i style="width:100%"></i></div><div class="g" style="margin:0">Best case, estimated from the link speed. Real drives can be slower.</div></div></section>
<section><div class="w"><h2>Details</h2><div class="list">{"".join(f"<div><b>{a}</b><span>{b}</span></div>" for a,b in L)}</div></div></section>
<section class="end"><div class="w"><h2>CablePeek for Mac</h2><p>Free. No account, no email.</p><a class="btn" href="{D}">Download</a><div class="g brew">Or with Homebrew: <code>brew install --cask diegobruegger-prog/tap/cablepeek</code></div></div></section>
<div class="w"><footer>{foot_c}Made in Switzerland. Not affiliated with Apple. This site counts visits and downloads without cookies or personal data.</footer></div>
<dialog id="dl" aria-labelledby="dlh"><h3 id="dlh">Your download has started.</h3><p>CablePeek is not notarized by Apple yet, so macOS warns you on first launch. To run it anyway:</p>
<ol><li>Unzip it and open CablePeek once.</li><li>Go to System Settings, Privacy &amp; Security.</li><li>Choose Open Anyway.</li></ol>{pop_c}<form method="dialog"><button class="btn" autofocus>Done</button></form></dialog>
<script>(function(){{var d=document.getElementById("dl");if(!d.showModal)return;document.querySelectorAll('a[href$="CablePeek.zip"]').forEach(function(a){{a.addEventListener("click",function(){{if(!d.open)setTimeout(function(){{d.showModal()}},300)}})}});d.addEventListener("click",function(e){{if(e.target==d)d.close()}})}})();
if(location.search=="?still")document.body.className="still";
(function(){{if(location.protocol!="https:"||location.search=="?still")return;var r="";try{{r=document.referrer?new URL(document.referrer).hostname:""}}catch(e){{}}if(r==location.hostname)r="";
var t=new URLSearchParams(location.search).get("ref")||"";function h(e){{navigator.sendBeacon("/api/hit",JSON.stringify({{e:e,ref:r.slice(0,100),tag:t.slice(0,20)}}))}}
h("view");document.querySelectorAll('a[href$="CablePeek.zip"]').forEach(function(a){{a.addEventListener("click",function(){{h("download")}})}});document.querySelectorAll("a.bmc").forEach(function(a){{a.addEventListener("click",function(){{h("coffee")}})}})}})()</script></body></html>''')
def g(n,b): open(f'graphics/{n}.html','w').write(f'<!doctype html><meta charset="utf-8"><link rel="stylesheet" href="../styles.css"><style>body{{overflow:hidden}}.mw{{width:100%;margin:0}}</style><body class="still">{b}')
g('og',f'<div style="width:1200px;height:630px;text-align:center;padding-top:56px"><h1 style="font-size:62px">How fast is that cable?</h1><div style="width:860px;margin:44px auto 0">{mac}</div></div>')
g('reddit',f'<div style="width:1600px;height:1200px;text-align:center;padding:84px 150px 0"><h1 style="font-size:92px">How fast is that cable?</h1><p style="font-size:30px;color:#d2d2d7;margin:20px 0 64px">CablePeek shows it at the port when you plug in.</p>{mac}</div>')
g('square',f'<div style="width:1080px;height:1080px;text-align:center;padding:110px 70px 0"><h1 style="font-size:76px;margin-bottom:80px">How fast is<br>that cable?</h1>{mac}<p style="font-size:26px;color:#d2d2d7;margin-top:70px">CablePeek for Mac</p></div>')
