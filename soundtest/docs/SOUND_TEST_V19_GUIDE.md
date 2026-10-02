# Sonic 1 Sound Test V19

## User configuration

Edit the block in `_Constants.asm`:

```asm
SoundTest_EnableSFX:       equ 1
SoundTest_MusicID_First:   equ $81
SoundTest_MusicID_Last:    equ $93
SoundTest_SFXID_First:     equ $A0
SoundTest_SFXID_Last:      equ $CF
SoundTest_SelectionStride: equ 16
```

The current selection is a unified list:

- Music `$81-$93` (19 entries)
- Normal SFX `$A0-$CF` (48 entries) when `SoundTest_EnableSFX = 1`

Changing `SoundTest_MusicID_Last` or `SoundTest_SFXID_Last` changes the derived
range count. When adding actual new driver entries, also add their 8-byte
records and names in `soundtest/data/entries/Sound Test Entries.asm`.

## Controls

```text
LEFT / RIGHT  = previous / next entry
A             = +16 entries
B             = -16 entries
C             = play selected ID
START         = exit
```

Navigation does not queue audio. Only C calls `QueueSound2`.

## SFX names

The V19 table exposes every normal SFX ID `$A0-$CF`. Names are documented in
`SOUND_TEST_SFX_LIST.md`. Entries whose original driver name is not known from
the disassembly are intentionally displayed as `SFX A2`, `SFX A5`, `SFX AB` and
`SFX B8` rather than inventing a description.

## Notes

The live channel monitor remains independent of the selection list. The shared
FM6/DAC slot continues to prefer DAC while the DAC track is actually playing.
The note renderer uses the one-semitone correction required by the current FM
frequency table:

```asm
SoundTest_NoteSemitoneAdjust: equ -1
```

The visible note order is:

```text
C C# D D# E F F# G G# A A# B
```
