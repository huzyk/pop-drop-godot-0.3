"""Reproducible, text-free native SVG art. All coordinates use a 256px sprite canvas."""
from pathlib import Path
import math
ROOT=Path(__file__).resolve().parents[1]
PALETTES={'coral':('#FFDAD4','#FF718E','#CC3F71','#71344F'), 'mint':('#DCFFE6','#64D9AF','#249E91','#245965'), 'blue':('#DDF4FF','#6FBCFF','#527FD1','#364C80')}
CREAM='#FFF3D7'; INK='#29374C'
def path(d,fill,stroke=None,w=4,extra=''):
 return f'<path d="{d}" fill="{fill}"'+(f' stroke="{stroke}" stroke-width="{w}" stroke-linecap="round" stroke-linejoin="round"' if stroke else '')+f' {extra}/>'
def ellipse(x,y,rx,ry,fill,extra=''):
 return f'<ellipse cx="{x}" cy="{y}" rx="{rx}" ry="{ry}" fill="{fill}" {extra}/>'
def star(x,y,r,fill,n=5):
 pts=[]
 for i in range(n*2):
  a=-math.pi/2+i*math.pi/n;rr=r if i%2==0 else r*.46;pts.append(f'{x+rr*math.cos(a):.1f},{y+rr*math.sin(a):.1f}')
 return f'<polygon points="{" ".join(pts)}" fill="{fill}" stroke-linejoin="round"/>'
def eyes(y=128,dx=34,style='normal'):
 s=''
 for x in [128-dx,128+dx]:
  s+=ellipse(x,y+3,12,16,'#FFFFFF', 'opacity=".92"')
  s+=ellipse(x+1,y,8,12,INK)+ellipse(x-2,y-4,3.2,4.2,'#FFFFFF')
 if style=='sleepy':s+=path(f'M{85} {y-10}q12 6 24 0 M{147} {y-10}q12 6 24 0','none',INK,5)
 return s
def face(y=128,dx=34):
 return eyes(y,dx)+ellipse(75,y+23,13,7,'#FFAEA8','opacity=".55"')+ellipse(181,y+23,13,7,'#FFAEA8','opacity=".55"')+path(f'M113 {y+40}q15 13 30 0','none',INK,4)
def animal(kind,color):
 light,base,dark,edge=PALETTES[color]
 defs=f'''<defs><radialGradient id="body" cx=".32" cy=".21" r=".85"><stop stop-color="{light}"/><stop offset=".46" stop-color="{base}"/><stop offset=".84" stop-color="{dark}"/><stop offset="1" stop-color="{edge}"/></radialGradient><linearGradient id="cream" x2=".2" y2="1"><stop stop-color="#FFFCF0"/><stop offset="1" stop-color="#F3D6B5"/></linearGradient><linearGradient id="gold" x2=".6" y2="1"><stop stop-color="#FFF7B3"/><stop offset=".5" stop-color="#FFC75F"/><stop offset="1" stop-color="#D78338"/></linearGradient></defs>'''
 s=ellipse(128,224,76,10,edge,'opacity=".16"')
 # Species-specific silhouettes behind the face; no copied animal with just a hat.
 if kind in ['bear','star_bear','monkey','jaguar','lion']:
  for x in [63,193]:s+=ellipse(x,69,30 if kind!='monkey' else 39,32,'url(#body)',f'stroke="{edge}" stroke-width="4"')+ellipse(x,70,17,18,CREAM)
 if kind=='lion':
  s+=path('M128 25L151 38L181 33L196 60L222 73L217 106L235 133L220 157L219 188L190 198L172 222L143 214L118 232L92 216L62 217L49 193L26 178L32 148L20 123L38 98L35 71L64 57L80 33L108 39Z','url(#body)',edge,4)
 if kind in ['fox','owl','jaguar']:
  s+=path('M52 106Q31 56 40 27Q78 37 99 70 M157 70Q182 36 216 27Q226 63 204 106','url(#body)',edge,5)
  s+=path('M52 46L61 87L85 73 M171 73L195 87L204 46',CREAM)
 if kind in ['zebra','giraffe','unicorn']:
  s+=path('M87 93Q38 83 44 38Q83 38 99 74 M157 74Q174 40 211 37Q222 79 170 95','url(#body)',edge,4)
  s+=path('M56 50Q62 74 86 79 M171 79Q198 67 200 49','none',CREAM,10)
 if kind=='giraffe':
  s+=path('M99 80L94 32M157 80L162 32','none',edge,12)+ellipse(93,29,12,13,base)+ellipse(163,29,12,13,base)
 if kind=='elephant':
  s+=path('M84 77Q21 38 14 97Q7 163 55 184L93 164 M172 77Q237 38 243 97Q249 163 203 184L163 164','url(#body)',edge,5)
  s+=path('M55 87Q29 83 31 121Q33 159 63 160 M201 87Q228 83 225 121Q223 159 194 160','none',light,8)
 if kind in ['dragon','griffin','phoenix']:
  s+=path('M65 99Q25 55 14 87L30 110L14 126L40 137L39 160L78 159 M191 99Q232 55 242 87L226 110L242 126L216 137L217 160L178 159','url(#body)',edge,4)
 if kind=='dragon':
  s+=path('M74 84Q47 51 65 23L100 70 M156 70L191 23Q207 54 183 85','url(#gold)',edge,4)
 if kind=='unicorn':s+=path('M111 75L128 9L148 75Z','url(#gold)',edge,4)+path('M119 42L137 50M115 57L143 66','none','#D99246',3)
 if kind=='frog':
  s+=ellipse(75,71,35,34,'url(#body)',f'stroke="{edge}" stroke-width="4"')+ellipse(181,71,35,34,'url(#body)',f'stroke="{edge}" stroke-width="4"')
 head='M128 52C183 48 214 88 218 137C222 184 187 217 128 218C69 219 34 186 38 137C42 88 74 53 128 52Z'
 if kind in ['zebra','giraffe','unicorn']:head='M128 53C166 51 191 78 187 113L200 153C217 197 183 220 128 220C72 220 42 196 56 154L70 113C63 80 88 54 128 53Z'
 if kind=='fox':head='M128 61Q193 45 217 111Q221 160 178 183L128 220L78 183Q34 162 39 111Q62 48 128 61Z'
 if kind=='owl':head='M128 62Q185 43 211 93L215 161Q211 219 128 220Q45 218 41 161L45 93Q71 44 128 62Z'
 if kind in ['parrot','toucan','phoenix','griffin']:head='M129 52Q191 53 207 111Q228 180 176 210Q110 234 62 196Q33 168 48 113Q62 58 129 52Z'
 s+=path(head,'url(#body)',edge,5)
 s+=path('M66 101Q74 70 111 67','none','#FFFFFF',8, 'opacity=".65"')+ellipse(61,112,4,5,'#FFFFFF','opacity=".65"')
 # Faces and characteristic markings.
 if kind in ['bear','star_bear','monkey','lion','jaguar']:
  if kind=='monkey':s+=path('M128 102Q94 69 69 108Q44 146 73 177Q101 204 128 203Q169 204 188 174Q210 137 184 108Q160 79 128 102Z','url(#cream)')
  else:s+=ellipse(128,168,49,34,'url(#cream)')
  if kind=='jaguar':
   for x,y in [(67,100),(188,100),(61,155),(194,155),(90,77),(166,77)]:s+=ellipse(x,y,8,6,edge)+ellipse(x,y,4,3,base)
  s+=eyes()+path('M117 153Q128 147 140 153L128 164Z',INK)+path('M128 164v10m0 0q-15 12-24-2m24 2q15 12 24-2','none',INK,3.5)
  if kind=='star_bear':s+=star(128,87,19,'url(#gold)')
 elif kind=='sloth':
  s+=path('M128 105Q94 77 65 110Q43 157 83 186Q128 214 173 186Q215 156 191 110Q163 77 128 105Z','url(#cream)')
  s+=path('M63 119Q79 94 112 115L96 162Q65 155 63 119 M144 115Q177 95 193 119Q190 155 160 162Z',edge)
  s+=eyes(132,36,'sleepy')+ellipse(128,160,10,7,INK)+path('M114 178Q128 188 142 178','none',INK,3.5)
 elif kind=='fox':
  s+=path('M47 120Q80 129 128 194Q174 131 210 120Q200 173 128 211Q61 178 47 120Z','url(#cream)')
  s+=eyes(123,36)+path('M116 179Q128 171 141 179L129 190Z',INK)
 elif kind=='owl':
  s+=path('M128 109Q102 70 66 99Q38 138 74 171Q106 189 128 153Q152 188 185 171Q219 138 190 99Q155 69 128 109Z','url(#cream)')
  s+=eyes(128,37)+path('M116 154L128 176L141 154Z','url(#gold)')
  for x,y in [(97,190),(128,198),(159,190)]:s+=path(f'M{x-6} {y-3}l6 6 6-6','none',light,4)
 elif kind=='frog':s+=eyes(88,52)+path('M82 153Q128 191 174 153','none',INK,5)+ellipse(70,140,14,8,'#FFA5A2','opacity=".7"')+ellipse(186,140,14,8,'#FFA5A2','opacity=".7"')
 elif kind=='elephant':
  s+=eyes(122,35)+path('M110 151Q109 179 121 193Q133 203 144 192Q153 182 144 174','none',edge,32)+path('M110 151Q109 179 121 193Q133 203 144 192Q153 182 144 174','none',base,23)
  s+=path('M87 155Q79 181 100 181 M166 155Q177 178 155 181',CREAM)
 elif kind in ['zebra','giraffe','unicorn']:
  if kind=='zebra':
   for d in ['M97 67L121 107L116 72','M151 67L135 111L144 72','M73 109L104 124L73 133','M183 109L153 124L184 133','M74 148L101 154L76 167','M182 148L155 154L180 167']:s+=path(d,edge)
  if kind=='giraffe':
   for x,y in [(99,86),(153,89),(79,145),(181,145),(128,114)]:s+=path(f'M{x-8} {y-8}l14 -3 7 12 -11 12 -13 -7Z',dark)
  if kind=='unicorn':s+=path('M109 57Q68 74 67 116Q48 104 64 78Q62 50 94 47Z',CREAM)+path('M150 55Q177 54 188 86L177 112Q172 80 148 75Z','url(#gold)')
  s+=ellipse(128,177,58,35,'url(#cream)')+eyes(127,31)+ellipse(108,178,5,7,edge)+ellipse(148,178,5,7,edge)+path('M111 197Q128 205 145 197','none',edge,3)
 elif kind=='dragon':
  s+=path('M107 62L115 42L129 60L145 42L154 67Z','url(#gold)')+ellipse(128,169,56,32,'url(#cream)')+eyes(121,32)+ellipse(108,166,5,6,edge)+ellipse(149,166,5,6,edge)+path('M103 185Q128 198 154 185','none',INK,4)+path('M108 190l5 9 6-8M142 191l5 8 5-10',CREAM)
 elif kind in ['toucan','parrot','griffin','phoenix']:
  if kind=='phoenix':s+=path('M92 72Q91 33 120 16L120 41Q142 14 166 24L144 54Q176 38 186 59L162 85Z','url(#gold)',edge,3)
  if kind=='griffin':s+=path('M73 89L66 45L100 69M160 70L194 46L186 99','url(#cream)',edge,3)
  s+=ellipse(100,126,37,40,'url(#cream)')+eyes(124,28)
  if kind=='toucan':s+=path('M129 135Q181 105 219 133Q236 148 214 163L152 170Z','url(#gold)',edge,4)+path('M196 126Q226 132 226 146Q226 158 208 162L195 148Z',INK)
  else:s+=path('M112 147Q136 135 154 151Q154 178 129 190Q139 165 112 163Z','url(#gold)',edge,3)
 else:s+=face()
 s+=path('M85 203Q129 223 173 202','none',light,4,'opacity=".4"')
 return f'<svg xmlns="http://www.w3.org/2000/svg" width="256" height="256" viewBox="0 0 256 256">{defs}{s}</svg>'
def object_skin(kind,color):
 light,base,dark,edge=PALETTES[color]
 defs=f'<defs><radialGradient id="body" cx=".32" cy=".22" r=".8"><stop stop-color="{light}"/><stop offset=".42" stop-color="{base}"/><stop offset=".83" stop-color="{dark}"/><stop offset="1" stop-color="{edge}"/></radialGradient><linearGradient id="gold" x2=".6" y2="1"><stop stop-color="#FFF4AF"/><stop offset=".5" stop-color="#FFC85A"/><stop offset="1" stop-color="#B96A2F"/></linearGradient></defs>'
 s=ellipse(128,222,77,10,edge,'opacity=".17"')
 if kind=='crystal':
  s+=path('M80 39L174 39L218 97L198 183L128 225L58 183L38 97Z','url(#body)',edge,5)
  s+=path('M80 39L96 103L38 97M174 39L159 103L218 97M96 103L128 225L159 103Z',light,base,2, 'opacity=".6"')
  s+=path('M80 39L174 39L159 103L96 103Z',light,None,extra='opacity=".55"')+star(77,77,13,'white')
 elif kind=='donut':
  s+=ellipse(128,137,92,88,'url(#gold)',f'stroke="{edge}" stroke-width="4"')
  s+=path('M44 117Q52 56 113 45Q190 31 215 110Q218 140 198 137Q186 124 178 143Q160 154 149 135Q130 123 117 143Q100 160 87 140Q71 121 59 140Q40 145 44 117Z','url(#body)',edge,3)
  s+=ellipse(128,126,29,27,edge)+ellipse(128,123,23,22,'#E0AB79')
  for x,y,a in [(82,82,20),(129,66,-15),(176,86,40),(65,112,-30),(188,118,15)]:s+=f'<path d="M{x-6} {y}h12" stroke="{CREAM}" stroke-width="6" stroke-linecap="round" transform="rotate({a} {x} {y})"/>'
  s+=eyes(173,28)+path('M116 196q12 9 24 0','none',INK,3)
 else:
  s+=ellipse(128,131,92,92,'url(#body)',f'stroke="{edge}" stroke-width="4"')
  if kind=='gold':s+=ellipse(128,131,91,91,'none','stroke="url(#gold)" stroke-width="14"')+path('M91 66L85 39L110 52L128 26L145 52L171 39L165 66Z','url(#gold)',edge,3)
  elif kind=='neon':s+=ellipse(128,131,84,84,'none',f'stroke="{light}" stroke-width="4"')+path('M59 143Q127 180 203 107','none',light,8, 'opacity=".6"')+star(191,75,16,light)
  else:s+=ellipse(156,178,33,16,light,'opacity=".23"')
  s+=path('M61 110Q70 66 113 59','none','white',10,'opacity=".8"')+ellipse(57,124,5,6,'white','opacity=".7"')
  if kind in ['default','jelly_pals']:s+=face(131,30)
  else:s+=eyes(136,30)+path('M114 168q14 10 28 0','none',INK,4)
 return f'<svg xmlns="http://www.w3.org/2000/svg" width="256" height="256" viewBox="0 0 256 256">{defs}{s}</svg>'
def write(p,s):
 f=ROOT/p;f.parent.mkdir(parents=True,exist_ok=True);f.write_text(s+'\n')
ANIMALS=['bear','star_bear','toucan','parrot','frog','monkey','jaguar','sloth','lion','zebra','elephant','giraffe','fox','owl','dragon','unicorn','phoenix','griffin']
for k in ANIMALS:
 for c in PALETTES:write(f'assets/skins/animals/{k}/{c}.svg',animal(k,c))
for k in ['neon','gold','donut','crystal','jelly_pals']:
 for c in PALETTES:write(f'assets/skins/{k}/{c}.svg',object_skin(k,c))
for c in PALETTES:write(f'assets/skins/default_v24/{c}.svg',object_skin('default',c))
# Scene surfaces are vectors without text. Labels and values belong to Godot.
D='''<defs>
<linearGradient id="sky" x2=".3" y2="1"><stop stop-color="#C7EFF0"/><stop offset=".45" stop-color="#E7F2DE"/><stop offset="1" stop-color="#FFE5C5"/></linearGradient>
<linearGradient id="teal" x2=".7" y2="1"><stop stop-color="#47C5BA"/><stop offset=".45" stop-color="#15998F"/><stop offset="1" stop-color="#086774"/></linearGradient>
<linearGradient id="cream" x2=".3" y2="1"><stop stop-color="#FFFFF5"/><stop offset=".65" stop-color="#FFF0DA"/><stop offset="1" stop-color="#EBD1B7"/></linearGradient>
<linearGradient id="pink" x2=".6" y2="1"><stop stop-color="#FFBDB0"/><stop offset="1" stop-color="#EB728B"/></linearGradient>
<linearGradient id="mint" x2=".5" y2="1"><stop stop-color="#BCF8DC"/><stop offset="1" stop-color="#5BCEB5"/></linearGradient>
<radialGradient id="sun"><stop stop-color="#FFFFFF" stop-opacity=".9"/><stop offset="1" stop-color="#FFFFFF" stop-opacity="0"/></radialGradient>
</defs>'''
def panel(x,y,w,h,r=24,fill='url(#cream)',edge='#FFFFFF'):
 return f'<rect x="{x}" y="{y+5}" width="{w}" height="{h}" rx="{r}" fill="#36585B" opacity=".16"/><rect x="{x}" y="{y}" width="{w}" height="{h}" rx="{r}" fill="{fill}" stroke="{edge}" stroke-width="3"/>'+path(f'M{x+r} {y+7}H{x+w-r}','none','#FFFFFF',3,'opacity=".40"')
s='<rect width="720" height="1280" fill="url(#sky)"/>'+ellipse(310,160,440,440,'url(#sun)')
s+=path('M0 840Q54 799 54 731Q18 734 0 769M720 489Q675 443 670 367Q716 381 720 418M0 189Q40 174 63 141Q21 130 0 155','#69BBA7',None,extra='opacity=".22"')
for x,y,rad in [(27,396,24),(693,748,31),(29,1170,42),(677,1250,65),(649,25,35)]:s+=ellipse(x,y,rad,rad,'#FFFFFF','opacity=".27"')+ellipse(x-6,y-8,rad*.22,rad*.13,'#FFFFFF','opacity=".55"')
s+=panel(414,18,173,57,27,'url(#teal)')
for x in [414,505,595]:s+=panel(x,88,71,66,25)
s+=panel(38,197,638,78,24,'url(#teal)','#7CDCD0')
for x,w in [(49,154),(210,125),(342,97),(446,105),(558,108)]:s+=f'<rect x="{x}" y="208" width="{w}" height="56" rx="15" fill="#075A69" opacity=".65"/>'
s+=panel(60,282,592,566,35,'url(#teal)','#9AF1D8')+panel(82,286,548,548,23,'#DBDDC9','#CCF5DF')
for y in range(8):
 for x in range(8):
  xx=88+x*67;yy=292+y*67
  s+=f'<rect x="{xx+1}" y="{yy+1}" width="65" height="65" rx="15" fill="url(#cream)" stroke="#FFFFFF" stroke-opacity=".85" stroke-width="1.5"/>'+ellipse(xx+33.5,yy+34,2,2,'#CEBA9B','opacity=".5"')
s+=panel(58,880,596,48,22,'url(#teal)','#9CE3D4')
for x in [60,263,466]:s+=panel(x,935,191,137,26)
s+=panel(30,1085,160,127,32,'url(#teal)','#95E8CE')+panel(522,1085,160,127,32,'url(#teal)','#95E8CE')
s+=panel(203,1100,154,113,29,'url(#pink)')+panel(364,1100,154,113,29,'url(#mint)')
write('assets/ui/v24/game_shell.svg',f'<svg xmlns="http://www.w3.org/2000/svg" width="720" height="1280" viewBox="0 0 720 1280">{D}{s}</svg>')
# Consistent translucent backdrop and cream/teal panels for every modal.
for name,(x,y,w,h,title_h) in {'shop':(54,225,612,863,120),'profile':(54,224,612,906,120),'settings':(72,342,576,735,120),'over':(70,420,580,625,0),'tutorial':(74,280,572,770,160)}.items():
 m='<rect width="720" height="1280" fill="#123C49" opacity=".79"/>'+ellipse(360,570,380,520,'url(#sun)')+panel(x,y,w,h,38)
 if title_h:m+=panel(x+8,y+8,w-16,title_h,32,'url(#teal)','#A3E8D3')
 if name=='tutorial':
  for yy in [510,651,792]:m+=panel(108,yy,504,114,25,'#EDF4E5','#FFFFFF')+ellipse(153,yy+60,29,29,'url(#mint)')
  m+=panel(140,943,440,80,28,'url(#mint)')
 write(f'assets/ui/modals/{name}.svg',f'<svg xmlns="http://www.w3.org/2000/svg" width="720" height="1280" viewBox="0 0 720 1280">{D}{m}</svg>')
print('Updated 23 catalog skins (69 sprites), base assets and 6 interface surfaces')
# Six coherent habitats. Keep decorations in gutters, away from touch targets.
worlds={'jungle':('#305F55','#F0EFD6','#B4D3AA'),'forest':('#486E6B','#F2EEDA','#BDD6BC'),'safari':('#996C46','#F9ECD4','#E7C38F'),'wetlands':('#3C7A79','#E4F4DE','#A8D5C8'),'aviary':('#64739A','#F1EDFA','#C4D2E9'),'fantasy':('#82649B','#F3EAF4','#D9BCE4')}
for world,(rim,tile,accent) in worlds.items():
 board=f'<rect width="536" height="536" rx="18" fill="{accent}"/>'
 for y in range(8):
  for x in range(8):
   board+=f'<rect x="{x*67+1}" y="{y*67+1}" width="65" height="65" rx="15" fill="{tile}" stroke="#FFFFFF" stroke-width="1.3"/>'+ellipse(x*67+33.5,y*67+34,2,2,rim,'opacity=".14"')
 write(f'assets/themes/{world}.svg',f'<svg xmlns="http://www.w3.org/2000/svg" width="536" height="536" viewBox="0 0 536 536">{board}</svg>')
 frame=f'<rect x="59" y="281" width="594" height="568" rx="36" fill="none" stroke="{rim}" stroke-width="5" opacity=".7"/>'
 for x,y,sign in [(27,450,1),(696,640,-1),(25,795,1)]:
  if world=='fantasy':frame+=star(x,y,13,accent)+star(x+sign*14,y+28,6,rim)
  else:frame+=path(f'M{x} {y+48}Q{x+sign*7} {y+17} {x} {y-12}','none',rim,3)+path(f'M{x} {y+10}Q{x+sign*34} {y-10} {x+sign*23} {y-30}Q{x} {y-27} {x} {y+10}M{x} {y+33}Q{x-sign*25} {y+12} {x-sign*20} {y-3}Q{x} {y} {x} {y+33}',accent,rim,1.5)
 write(f'assets/themes/{world}_frame.svg',f'<svg xmlns="http://www.w3.org/2000/svg" width="720" height="1280" viewBox="0 0 720 1280">{frame}</svg>')
