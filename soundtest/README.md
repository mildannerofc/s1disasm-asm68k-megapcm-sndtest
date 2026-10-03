# Sonic 1 Sound Test

## Source

- `src/Sound Test.asm` — Sound Test game mode and live channel renderer.
- `data/Sound Test Font Mapping.asm` — authoritative ASCII-to-tile mapping.
- `data/entries/Sound Test Entries.asm` — unified music/SFX selection table and names.
- `data/Sound Test Font Icons.nem` — Nemesis art used by the screen.
- `data/Sound Test Tilemap.bin` — 40x28 foreground base map.

## Configuration

Edit the Sound Test constants in `_Constants.asm`:

```asm
SoundTest_EnableSFX:       equ 1
SoundTest_MusicID_First:   equ $81
SoundTest_MusicID_Last:    equ $93
SoundTest_SFXID_First:     equ $A0
SoundTest_SFXID_Last:      equ $CF
SoundTest_SelectionStride: equ 16
```

## Input

`LEFT/RIGHT` select, `A/B` jump by 16 entries, `C` plays, `START` exits.
