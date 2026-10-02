# Sound Test Render V11

V11 fixes the two causes visible in Fusion:

1. The bundled art is an 83-tile Nemesis stream matching the current 2656-byte 4bpp source.
2. The Sound Test explicitly loads its palette into both the fading and active palette buffers, using palette line 1 and `Tile_Pal1`.

Additional renderer fixes:

- 64-cell foreground row stride (128 bytes)
- explicit 128-byte ASCII mapping
- exact reference arrow/row/green icons
- FM6 label renderer preserves the FM6 track pointer
- DAC/FM6 sixth-slot switching remains live
