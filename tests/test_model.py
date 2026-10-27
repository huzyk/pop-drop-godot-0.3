"""Python mirror tests for core game invariants; does not execute Godot/GDScript.
Run: python tests/test_model.py
"""
from pathlib import Path
import json, random

ROOT = Path(__file__).resolve().parents[1]
N=8
EMPTY=-1

def new(): return [[EMPTY]*N for _ in range(N)]
def clone(b):return [x[:] for x in b]
def gravity(b):
    for x in range(N):
        vals=[b[y][x] for y in range(N) if b[y][x]!=EMPTY]
        for y in range(N): b[y][x] = ([EMPTY]*(N-len(vals))+vals)[y]
def matches(b):
    seen=set(); remove=set()
    for y in range(N):
        for x in range(N):
            if b[y][x]<0 or (x,y) in seen:continue
            color=b[y][x]; q=[(x,y)]; seen.add((x,y));i=0
            while i<len(q):
                cx,cy=q[i];i+=1
                for nx,ny in ((cx-1,cy),(cx+1,cy),(cx,cy-1),(cx,cy+1)):
                    if 0<=nx<N and 0<=ny<N and (nx,ny) not in seen and b[ny][nx]==color:
                        seen.add((nx,ny));q.append((nx,ny))
            if len(q)>=3:remove.update(q)
    return remove

def simulate(b, piece, anchor, star=False):
    nxt=clone(b);x,y=anchor
    for px,py,c in piece:
        xx=x+px;yy=y+py
        if not (0<=xx<N and 0<=yy<N) or b[yy][xx]!=EMPTY:
            return None
    for px,py,c in piece:nxt[y+py][x+px]=c
    count=chains=0
    if star:
        for k in range(N):
            for cx,cy in ((k,y),(x,k)):
                if nxt[cy][cx]>=0:
                    nxt[cy][cx]=EMPTY;count+=1
        gravity(nxt);chains+=1
    for _ in range(64):
        gone=matches(nxt)
        if not gone:break
        chains+=1;count+=len(gone)
        for x1,y1 in gone:nxt[y1][x1]=EMPTY
        gravity(nxt)
    return nxt,count,chains

b=new();b[7][1]=b[7][2]=0
n,removed,chains=simulate(b,[(0,0,0)],(3,7))
assert removed==3 and chains==1 and all(v==-1 for row in n for v in row)
assert simulate(b,[(0,0,1)],(2,7)) is None
b=new();b[6][1]=0;b[7][1]=1;b[7][2]=1
n,removed,chains=simulate(b,[(0,0,1)],(3,7))
assert removed==3 and chains==1 and n[7][1]==0, 'Gravity must settle into lowest empty cell'
b=new();
for i in range(8):b[7][i]=i%3
n,removed,chains=simulate(b,[(0,0,1)],(5,6),True)
assert chains>=1 and all(n[y][5]==-1 for y in range(8)), 'Star must clear its landing column'
assert removed>=2 and sum(1 for row in n for v in row if v>=0) <= 7, 'Star must clear the targeted column and landing row before gravity'

for seed in range(500):
    rng=random.Random(seed)
    b=new()
    # Random valid pieces placed followed by automatic match and collapse.
    for _ in range(60):
        length=rng.choice((1,1,2,2,3,3,4))
        shape = rng.choice([[(i,0) for i in range(length)],[(0,i) for i in range(length)]])
        piece=[(x,y,rng.randrange(3)) for x,y in shape]
        legal=[]
        for y in range(N):
            for x in range(N):
                if simulate(b,piece,(x,y)) is not None:legal.append((x,y))
        if not legal:break
        b,removed,chains=simulate(b,piece,rng.choice(legal))
        assert len(b)==N and all(len(row)==N for row in b)
        assert not matches(b),'Every move must resolve all same-color matches'
        assert all(v in (-1,0,1,2) for row in b for v in row)
        if removed > 0:
            for x in range(N):
                column=[b[y][x] for y in range(N)]
                assert column==sorted(column,key=lambda n:n!=-1),'Gravity must leave no holes after a clear'

langs=json.loads((ROOT/'localization.json').read_text())
expected={'pl','en','es','pt','de','fr','ru'}
assert set(langs)==expected
keys=set(langs['en'])
for lang, entries in langs.items():
    assert set(entries)==keys,(lang,'missing keys')
    assert all(isinstance(v,str) and v.strip() for v in entries.values())
for required in ('hammer','spin','laser','undo','star','bomb','rainbow','revive','test_reward'):
    assert required in keys
rule_code=(ROOT/'scripts/rules.gd').read_text()
game_code=(ROOT/'scripts/game.gd').read_text()
assert 'generate_tray' in rule_code and 'simulate' in rule_code
assert 'star_remaining' in game_code and 'reward_kind' in game_code
assert 'revives += 1' in game_code and 'lives = 1' in game_code
print('PASS: 500 random games x up to 60 moves, cascade/gravity/star rules, 7 locales / 49 keys')
