# Sound Test V14 — Graphics / VRAM guide

The Sound Test uses the 8x16 large reference font, stored as 83 Mega Drive 4bpp tiles (2656 bytes) and Nemesis-compressed at build time.

- Uncompressed source: `soundtest/data/Sound Test Font Icons.unc`
- Convenience 4bpp copy: `soundtest/data/Sound Test Font Icons 4bpp.bin`
- Nemesis source used by runtime: `soundtest/data/Sound Test Font Icons.nem`
- Tilemap: `soundtest/data/Sound Test Tilemap.bin` (40x28 words)
- Palette: `palette/Sound Test.bin`

`SoundTest_ArtTile = $200`, so the decompressed art begins at VRAM `$4000`. The foreground tilemap remains at `vram_fg = $C000`.

The renderer writes the visible 40-column plane using the native 64-cell stride: one tile row is 128 bytes apart. Runtime text uses the explicit 128-byte character map in `soundtest/data/Sound Test Font Mapping.asm`.

The note separator `-` is generated explicitly; it is not extracted from the alphanumeric reference sheet. This prevents the previous `W`-shaped glyph from appearing in `C-3` and `N-2`.
