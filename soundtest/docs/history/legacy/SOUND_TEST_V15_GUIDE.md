# Sonic 1 Sound Test — V15 ROM Hacking Guide

## Build fix

V14 used an ASM68K `if`/`fatal` check after the SoundTest music table:

```asm
if (SoundTest_MusicTable_End-SoundTest_MusicTable)<>SoundTest_MusicCount
    fatal "SoundTest_MusicTable count does not match the Sonic 1 music pointer range."
endif
```

That expression is not accepted by the user's ASM68K build as written. V15 removes the fragile assertion and makes the selectable range explicit in `_Constants.asm`:

```asm
SoundTest_MusicID_First: equ $81
SoundTest_MusicID_Last:  equ $93
SoundTest_MusicCount:    equ SoundTest_MusicID_Last-SoundTest_MusicID_First+1
```

To extend the Sound Test, change `SoundTest_MusicID_Last` and add exactly the same number of music IDs and name pointers to `SoundTest_MusicTable` and `SoundTest_MusicNames`.

## Folder organization

```text
soundtest/
  src/
    Sound Test.asm
  data/
    Sound Test Font Icons.nem
    Sound Test Font Icons.unc
    Sound Test Font Icons 4bpp.bin
    Sound Test Font Mapping.asm
    Sound Test Tilemap.bin
    SOUND_TEST_DAC_IDS.asm
  preview/
    Sound Test Graphics Preview.png
    Sound Test Screen Preview.png
  tools/
    build_soundtest_font.py
    build_soundtest_screen_preview.py
    nemesis_compress.py
  docs/
    SOUND_TEST_V15_GUIDE.md
    ...
```

The Sound Test palette remains in the project's normal `palette/` directory as `palette/Sound Test.bin`.

## Current music range

`$81-$93` (19 entries), matching the original Sonic 1 music pointer range in this source.

## DAC display

The shared FM6/DAC slot uses these sample names:

- `$81` KICK
- `$82` SNARE
- `$83` TIMPANI
- `$84` CLAP
- `$85` CYMBAL
- `$86-$87` UNUSED / reserved entries
- `$88` HI TIMPANI
- `$89` MID TIMPANI
- `$8A` LOW TIMPANI
- `$8B` VERY LOW TIMPANI
- `$8C` SEGACHANT

When DAC is active, the slot is rendered as `DAC`; otherwise it renders `FM 6`.

## Controls

- LEFT / RIGHT: select entry only
- A: +16 entries
- B: -16 entries
- C: play the selected music
- START: return to the previous game mode

LEFT/RIGHT/A/B do not start audio.

## Channel monitor

The renderer reads the SMPS track state already present in RAM. FM and PSG entries render note + raw frequency when enabled. The noise row reads the PSG3 noise state and renders a pseudo-note (`N-0`..`N-3`) plus the raw value.
