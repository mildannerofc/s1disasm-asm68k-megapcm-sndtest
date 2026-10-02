Sound Test render V8

- Palette is loaded through palid_SoundTest into palette line 1 and rendered with Tile_Pal1.
- VDP register 7 is $8700, so the backdrop uses the same palette line/color 0.
- Foreground tilemap is 40x28 and uses tile 0 / palette line 1.
- Sound Test font is 83 tiles: 2 blank + 72 alphanumeric glyph tiles + 6 helper tiles + 3 icons.
- The bundled Nemesis file is 83 tiles and was round-trip validated against the included Sonic 1 Nemesis decompressor.
- The previously uploaded 88-tile Nemesis file is intentionally not used; it decodes to unrelated/noisy graphics and does not match this mapping.
