#!/usr/bin/env python3
from pathlib import Path
from PIL import Image
import numpy as np

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / 'data'
PREVIEW_DIR = ROOT / 'preview'
REF = Path('/mnt/data/user_font_4x.png')
OUT = DATA / 'Sound Test Font Icons.unc'
MAP = DATA / 'Sound Test Font Mapping.asm'
PREVIEW = PREVIEW_DIR / 'Sound Test Graphics Preview.png'

ref4 = Image.open(REF).convert('RGB')
ref = ref4.resize((ref4.width // 4, ref4.height // 4), Image.Resampling.NEAREST)
ra = np.array(ref)
row_y = [0, 24, 47]
chars = list('0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ')

# Palette indices are deliberate and compact. Black in the source sheet is treated as
# transparent; visible source colors map to the matching Sound Test palette slots.
COLOR_TO_INDEX = {
    (0, 0, 0): 0,        # transparent/background in the source sheet
    (64, 0, 0): 1,       # dark outline -> black in the ROM palette
    (224, 224, 224): 2,  # white
    (224, 192, 0): 3,    # yellow
    (192, 128, 192): 4,  # purple highlight -> magenta
    (96, 32, 96): 4,    # dark purple highlight -> magenta
    (160, 64, 0): 4,    # brown/orange shadow -> magenta
    (0, 224, 0): 7,     # green status color
}

def extract_glyph(row, col):
    x, y = col * 16, row_y[row]
    cell = ra[y:y+16, x:x+8]  # the actual 8-pixel glyph column inside each 16-pixel reference slot
    g = np.zeros((16, 8), dtype=np.uint8)
    h, w = cell.shape[:2]
    for yy in range(h):
        for xx in range(w):
            g[yy, xx] = COLOR_TO_INDEX.get(tuple(map(int, cell[yy, xx])), 0)
    return g

glyphs = {}
for i, ch in enumerate(chars):
    row = 0 if i < 16 else 1 if i < 32 else 2
    col = i if i < 16 else i - 16 if i < 32 else i - 32
    glyphs[ch] = extract_glyph(row, col)

glyphs[' '] = np.zeros((16, 8), dtype=np.uint8)

def custom_minus():
    # The reference sheet supplied for this Sound Test contains only 0-9/A-Z,
    # so the dash used by note names is drawn explicitly in the same chunky style.
    g = np.zeros((16,8), dtype=np.uint8)
    g[7:9, 1:7] = 3
    return g

glyphs['-'] = custom_minus()

def custom_plus():
    g = np.zeros((16,8), dtype=np.uint8)
    g[4:12,2:4] = 5
    g[7:9,0:6] = 5
    g[4:10,1:3] = 3
    g[6:8,0:5] = 3
    g[8:10,1:3] = 7
    g[7:9,3:5] = 7
    return g

def custom_hash():
    g=np.zeros((16,8),dtype=np.uint8)
    g[3:12,1:3]=5
    g[3:12,4:6]=5
    g[5:11,0:2]=3
    g[5:11,3:5]=3
    g[6:8,0:6]=3
    g[9:11,0:6]=3
    g[4:6,4:6]=7
    g[10:12,4:6]=7
    return g

glyphs['+'] = custom_plus()
glyphs['#'] = custom_hash()

order = [' '] + chars + ['+','-','#']
assert len(order)==40

def tile_bytes(block):
    out=bytearray()
    for y in range(8):
        for x in range(0,8,2):
            out.append((int(block[y,x])<<4)|int(block[y,x+1]))
    return bytes(out)

raw=bytearray()
for ch in order:
    g=glyphs[ch]
    raw += tile_bytes(g[0:8])
    raw += tile_bytes(g[8:16])

# 3 8x8 helper icons after the font.
def icon_arrow():
    # Exact 8x8 pattern recovered from the target Sound Test screen.
    # 3 = yellow, 0 = transparent/background.
    pattern = [
        '........',
        '..3.....',
        '..33....',
        '..333...',
        '..33....',
        '..3.....',
        '........',
        '........',
    ]
    return np.array([[0 if ch == '.' else int(ch) for ch in row] for row in pattern], dtype=np.uint8)

def icon_diamond():
    # Exact 8x8 reference row-marker icon.
    # 1 = black, 4 = magenta, 6 = gray, 2 = white.
    pattern = [
        '11111111',
        '44444446',
        '44444462',
        '44444622',
        '64446222',
        '26462222',
        '26462226',
        '26462226',
    ]
    return np.array([[int(ch) for ch in row] for row in pattern], dtype=np.uint8)

def icon_meter():
    # Exact 8x8 reference status icon: magenta field with a green/black marker.
    pattern = [
        '44444444',
        '44444444',
        '44446144',
        '44446144',
        '44446144',
        '44446144',
        '44446144',
        '44446144',
    ]
    return np.array([[int(ch) for ch in row] for row in pattern], dtype=np.uint8)
for icon in (icon_arrow(),icon_diamond(),icon_meter()):
    raw += tile_bytes(icon)

assert len(raw)==83*32
OUT.write_bytes(raw)

base={ch:i*2 for i,ch in enumerate(order)}
lines=['; Sound Test 8x16 font mapping.', '; Order: blank, 0-9, A-Z, +, -, #. Each glyph uses 2 tiles (top, bottom).', 'SoundTest_FontMap:']
vals=[]
for code in range(128):
    ch=chr(code)
    if 'a'<=ch<='z': ch=ch.upper()
    vals.append(base.get(ch,0))
for i in range(0,128,16):
    lines.append('\t\tdc.b '+','.join(f'${v:02X}' for v in vals[i:i+16]))
lines.append('')
for ch in order: lines.append(f'; {ch!r:>4}: ${base[ch]:02X}')
MAP.write_text('\n'.join(lines)+'\n', encoding='utf-8')

pal={0:(36,0,0),1:(0,0,0),2:(255,255,255),3:(255,219,36),4:(219,0,146),5:(73,0,73),6:(146,146,146),7:(0,219,0)}
tiles=[]
for i in range(len(raw)//32):
    b=raw[i*32:(i+1)*32]
    arr=np.zeros((8,8),dtype=np.uint8)
    for y in range(8):
        for j,byte in enumerate(b[y*4:y*4+4]):
            arr[y,2*j]=byte>>4; arr[y,2*j+1]=byte&15
    tiles.append(arr)
# Build a compact 16-column preview matching the reference sheet layout.
preview_rows = [chars[:16], chars[16:32], chars[32:]]
preview_rows[-1] = preview_rows[-1] + [' ', ' ', ' ', ' ', ' ', ' ']
preview_order = preview_rows[0] + preview_rows[1] + preview_rows[2] + ['+','-','#']
font=Image.new('RGB',(16*8, 4*16),(32,0,16))
px=font.load()
for i,ch in enumerate(preview_order):
    ti=order.index(ch)
    g=np.vstack([tiles[ti*2],tiles[ti*2+1]])
    ox=(i%16)*8; oy=(i//16)*16
    for yy in range(16):
        for xx in range(8):
            px[ox+xx,oy+yy]=pal[int(g[yy,xx])]
font.resize((16*8*4,4*16*4),Image.Resampling.NEAREST).save(PREVIEW)
print(f'{OUT} {len(raw)} bytes / 83 tiles')
print(MAP)
