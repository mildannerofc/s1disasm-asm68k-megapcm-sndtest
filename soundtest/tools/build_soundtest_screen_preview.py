#!/usr/bin/env python3
from pathlib import Path
from PIL import Image

ROOT=Path(__file__).resolve().parents[1]
RAW=(ROOT/'data'/'Sound Test Font Icons.unc').read_bytes()
OUT=ROOT/'preview'/'Sound Test Screen Preview.png'

# Visual reference colors used by the supplied/target mockup.
PAL=[(32,0,16),(0,0,0),(238,238,238),(238,224,0),(224,0,160),(96,0,96),(136,136,136),(0,224,0)]

def tile(raw, idx):
    b=raw[idx*32:(idx+1)*32]
    return [[(byte>>4 if x%2==0 else byte&15) for x in range(8) for byte in []] for y in range(8)]

def decode_tile(raw, idx):
    b=raw[idx*32:(idx+1)*32]
    out=[]
    for y in range(8):
        row=[]
        for byte in b[y*4:y*4+4]:
            row += [byte>>4, byte&15]
        out.append(row)
    return out

tiles=[decode_tile(RAW,i) for i in range(len(RAW)//32)]
font_map={" ":0}
order=[' ']+list('0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ')+['+','-','#']
for i,ch in enumerate(order): font_map[ch]=i*2

def draw_text(im,x,y,s):
    # x is 8-pixel character column, y is 8-pixel tile row.
    ox=x*8; oy=y*8
    for ch in s:
        if ch.islower(): ch=ch.upper()
        ti=font_map.get(ch,0)
        top=tiles[ti]; bot=tiles[min(ti+1,len(tiles)-1)]
        for yy,row in enumerate(top+bot):
            for xx,ci in enumerate(row):
                if ci < len(PAL): im.putpixel((ox+xx,oy+yy),PAL[ci])
        ox += 8

def draw_icon(im,x,y,idx):
    t=tiles[80+idx]
    for yy,row in enumerate(t):
        for xx,ci in enumerate(row):
            if ci < len(PAL): im.putpixel((x*8+xx,y*8+yy),PAL[ci])

im=Image.new('RGB',(320,224),PAL[0])
# Static layout mirrors SoundTest_DrawStatic.
draw_text(im,4,1,'SOUND TEST')
draw_text(im,4,4,'MUSIC')
draw_text(im,10,4,'81')
draw_text(im,14,4,'GREEN HILL')
draw_text(im,4,6,'A+16 B-16 C PLAY')
draw_text(im,27,6,'START MENU')
for row,txt in zip(range(8,28,2),['FM 1','FM 2','FM 3','FM 4','FM 5','DAC','PSG 1','PSG 2','PSG 3','NOISE']):
    draw_text(im,4,row,txt)
# Reference motifs.
draw_icon(im,1,4,0)
draw_icon(im,34,4,2)
for row in range(8,28,2): draw_icon(im,1,row,1)
# Example live note/frequency state; runtime replaces these from SMPS RAM.
for row,note,freq in [(8,'C-4','0248'),(10,'D-4','0264'),(12,'E-4','0280'),(14,'G-4','02A8'),(16,'A-4','02C0'),(18,'PCM','----'),(20,'C-4','0356'),(22,'D-4','02F9'),(24,'E-4','0231'),(26,'ON ','    ')]:
    draw_text(im,18,row,note)
    draw_text(im,24,row,freq)
# Enlarge only for easier visual comparison with the supplied screenshot.
im.resize((800,560),Image.Resampling.NEAREST).save(OUT)
print(OUT)
