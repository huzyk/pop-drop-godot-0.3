from PIL import Image,ImageDraw,ImageFont,ImageFilter
from pathlib import Path
import math,random
ROOT=Path(__file__).resolve().parents[1]
S=2
img=Image.new('RGB',(720*S,1280*S),'#101b3c')
d=ImageDraw.Draw(img,'RGBA')
font=ROOT/'fonts'/'ClearSans-Regular.ttf'; bold=ROOT/'fonts'/'ClearSans-Bold.ttf'
F=lambda n,bd=True:ImageFont.truetype(str(bold if bd else font),int(n*S))
def rect(box,fill,rad=20,outline=None,ow=1):
    x1,y1,x2,y2=[int(k*S) for k in box]
    d.rounded_rectangle([x1,y1,x2,y2],radius=int(rad*S),fill=fill,outline=outline,width=int(ow*S))
def text(x,y,v,n,color='#ffffff',anchor='ls',bd=True):d.text((x*S,y*S),v,font=F(n,bd),fill=color,anchor=anchor)
def circ(cx,cy,r,fill):d.ellipse(((cx-r)*S,(cy-r)*S,(cx+r)*S,(cy+r)*S),fill=fill)
colors=['#ff749c','#57d7aa','#67aafb','#ffc76c']
def ball(cx,cy,r,c):
    circ(cx,cy+4,r+3,(0,0,0,74));circ(cx,cy,r,colors[c]);circ(cx-8,cy-9,r*.27,(255,255,255,114))
for cx,cy,r,color in [(50,140,240,(73,45,137,47)),(695,780,300,(31,100,165,30)),(355,1190,280,(91,49,138,37))]:circ(cx,cy,r,color)
random.seed(4)
for i in range(56):
    x=random.randrange(720);y=random.randrange(1280);circ(x,y,random.choice([1,1,2]),(255,255,255,32))
rect((40,34,680,128),'#19294f',26,'#455b83',2)
text(73,100,'POP',55);text(205,100,'DROP',55,'#6ee1d3')
rect((502,58,596,102),'#263e68',22);text(550,81,'PL',20,anchor='mm')
rect((607,58,662,102),'#263e68',22);text(634,81,'II',23,anchor='mm')
rect((40,146,348,260),'#18294a',22);rect((366,146,680,260),'#18294a',22)
text(65,184,'WYNIK',17,'#9fb3de');text(65,237,'8 450',43)
text(391,184,'REKORD',17,'#9fb3de');text(391,237,'12 950',43,'#ffda7a')
for i in range(3):text(570+i*33,178,'♥',25,'#ff688d' if i<2 else '#4a5671')
rect((24,270,696,942),'#23345e',28,'#50638f',2)
b=[[None]*8 for _ in range(8)]
board={ (0,7):1,(1,7):0,(2,7):0,(3,7):2,(4,7):0,(5,7):2,(6,7):1,(7,7):0,
(0,6):2,(1,6):2,(2,6):1,(3,6):0,(4,6):1,(5,6):0,(6,6):2,(7,6):1,
(1,5):1,(2,5):1,(3,5):2,(4,5):1,(5,5):2,(6,5):0,
(2,4):0,(3,4):0,(4,4):2,(5,4):1,
(3,3):2,(4,3):1,(5,3):2,(4,2):1}
for y in range(8):
 for x in range(8):
  xx=40+x*80;yy=286+y*80
  rect((xx+3,yy+3,xx+77,yy+77),'#19284c' if (x+y)%2==0 else '#1c2d54',12)
  if (x,y) in board:ball(xx+40,yy+40,30,board[x,y])
# 
rect((160,510,560,616),(12,25,47,227),25)
text(360,570,'GREAT!',49,'#7bebdf',anchor='mm')
for i in range(40):
    a=random.random()*math.tau
    r=random.random()*130
    cx=360+math.cos(a)*r
    cy=558+math.sin(a)*r
    rgb = (255,214,110) if i%2 else (92,227,209)
    circ(cx,cy,random.randrange(2,7),(*rgb,random.randrange(100,255)))
text(360,971,'PRZECIĄGNIJ KSZTAŁT NA PLANSZĘ',18,'#c4d2f1',anchor='mm')
shapes=[[(0,0,1),(1,0,1),(1,1,1)],[(0,0,2),(1,0,2)],[(0,0,0),(1,0,0),(2,0,0)]]
for slot in range(3):
    x=41+slot*218
    rect((x,991,x+200,1098),'#293d6c' if slot==0 else '#192a4d',20,'#64dcc8' if slot==0 else '#415379',3 if slot==0 else 1)
    shape=shapes[slot]
    maxx=max(z[0] for z in shape)
    maxy=max(z[1] for z in shape)
    xx=x+100-(maxx*33)/2
    yy=1044-(maxy*33)/2
    for px,py,c in shape:
        ball(xx+px*33,yy+py*33,14.5,c)
names=['BOMBA','SPIN','MŁOTEK','RAINBOW','LASER','COFNIJ','STAR']
icons=['O','S','T','C','+','<','*']
for i,name in enumerate(names):
    x=28+i*96
    rect((x,1118,x+86,1227),'#1d3055',20,'#364e79',2)
    circ(x+43,1154,26,'#624d7e' if i%2==0 else '#255979')
    text(x+43,1154,icons[i],32,'#ffe18d' if i==6 else '#fff',anchor='mm')
    text(x+43,1201,name,11,'#d3e6f9',anchor='mm')
    rect((x+59,1122,x+83,1144),'#ffb84b',10)
    text(x+71,1133,'1',14,'#312642',anchor='mm')
text(360,1256,'Połącz 3 kulki tego samego koloru',19,'#8ca8d7',anchor='mm',bd=False)
img.resize((720,1280),Image.Resampling.LANCZOS).save(ROOT/'PODGLAD-UI.png')
print(ROOT/'PODGLAD-UI.png')
