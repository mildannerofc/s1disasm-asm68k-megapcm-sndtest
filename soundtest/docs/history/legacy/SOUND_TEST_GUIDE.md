# Sonic 1 Guide — ROM Hacking: Sound Test (V14)

This document describes the Sound Test extension currently integrated into the Sonic 1 ASM68K project.

## Current sound ranges

| Range | Purpose | Current value |
|---|---|---|
| `$81-$93` | Sonic 1 music entries exposed by the Sound Test | 19 entries |
| `$A0-$CF` | Normal Sonic 1 sound effects documented by this project | 48 entries |
| `$D0` | Special sound effect (Waterfall) | intentionally outside the Sound Test SFX ceiling |

The music range starts at `$81`. The current last music ID is `$93`; `SoundTest_MusicID_Last` is derived from the driver's music range so it stays synchronized when the driver is extended.

## How to extend the music Sound Test

1. Add the new `MusicXX` data to `s1.sounddriver.asm` after the existing music block.
2. Add the corresponding pointer/`bgm_...` definition in `_Constants.asm` in the same way as the existing music IDs.
3. Add the new byte to `SoundTest_MusicTable` in `soundtest.asm`.
4. Add the matching name entry to `SoundTest_MusicNames`.

`SoundTest_MusicCount` is calculated from `bgm__First`/`bgm__Last`, and `SoundTest_MusicID_Last` is calculated from `$81 + count - 1`. The source includes a consistency check so the music table cannot silently drift away from the driver's music count.

To change the page step, edit `SoundTest_MusicStride` (default `16`).

## Current controls

`Left/Right` selects one music entry without playing it.

`A` advances by 16 entries.

`B` subtracts 16 entries.

`C` is the explicit Play command. Entering the Sound Test and changing the selection do not automatically play a song.

`START` exits to `SoundTest_ReturnMode`.

## Live channel monitor

FM1-FM5, FM6, PSG1-PSG3 and the Noise monitor are rendered from the existing SMPS track RAM. The note field overwrites the placeholder in place.

The FM frequency table contains the actual Sonic 1 YM2612 frequency values. PSG channels are resolved against the Sonic 1 PSG frequency table.

The sixth visible row is shared:

- DAC active: label is `DAC` and the sample name/ID are shown.
- DAC inactive: label is `FM 6` and the FM6 note/frequency are shown.

The renderer explicitly clears the shared row before switching between DAC and FM6, so stale `6`, DAC names, IDs or frequencies are not left in VRAM.

## DAC sample names

The normal Sonic 1 music DAC sample IDs documented by this build are:

| ID | Name |
|---:|---|
| `$81` | KICK |
| `$82` | SNARE |
| `$83` | TIMPANI |
| `$84` | CLAP |
| `$85` | CYMBAL |
| `$86` | UNUSED |
| `$87` | UNUSED |
| `$88` | HI TIMPANI |
| `$89` | MID TIMPANI |
| `$8A` | LOW TIMPANI |
| `$8B` | VERY LOW TIMPANI |
| `$8C` | SEGACHANT |

The renderer displays the readable sample name and the two-digit sample ID. `$80` is treated as a DAC rest.

The names follow the DAC values already consumed by `DACUpdateTrack`; `$88-$8D` are the timpani-rate variants handled by the existing Sonic 1 driver. This Sound Test labels `$8C` as `SEGACHANT` per the requested Sound Test mapping.

## Noise channel

The Noise row monitors PSG3 when `VoiceControl = $E0`. The screen renders a pseudo-note `N-0` through `N-3` from the noise rate bits and also shows the raw control value as hexadecimal.

## Normal Sonic 1 sound effects through `$CF`

The following table is derived from the SFX pointer table and filenames in `s1.sounddriver.asm`.

| ID | Sound effect |
|---:|---|
| `$A0` | Jump |
| `$A1` | Lamppost |
| `$A2` | Unnamed/`SndA2` |
| `$A3` | Death |
| `$A4` | Skid |
| `$A5` | Unnamed/`SndA5` |
| `$A6` | Hit Spikes |
| `$A7` | Push Block |
| `$A8` | Special Stage Goal |
| `$A9` | Special Stage Item |
| `$AA` | Splash |
| `$AB` | Unnamed/`SndAB` |
| `$AC` | Hit Boss |
| `$AD` | Get Bubble |
| `$AE` | Fireball |
| `$AF` | Shield |
| `$B0` | Saw |
| `$B1` | Electric |
| `$B2` | Drown Death |
| `$B3` | Flamethrower |
| `$B4` | Bumper |
| `$B5` | Ring |
| `$B6` | Spikes Move |
| `$B7` | Rumbling |
| `$B8` | Unnamed/`SndB8` |
| `$B9` | Collapse |
| `$BA` | Special Stage Glass |
| `$BB` | Door |
| `$BC` | Teleport |
| `$BD` | Chain Stomp |
| `$BE` | Roll |
| `$BF` | Get Continue |
| `$C0` | Basaran Flap |
| `$C1` | Break Item |
| `$C2` | Drown Warning |
| `$C3` | Giant Ring |
| `$C4` | Bomb |
| `$C5` | Cash Register |
| `$C6` | Ring Loss |
| `$C7` | Chain Rising |
| `$C8` | Burning |
| `$C9` | Hidden Bonus |
| `$CA` | Enter Special Stage |
| `$CB` | Wall Smash |
| `$CC` | Spring |
| `$CD` | Switch |
| `$CE` | Ring Left Speaker |
| `$CF` | Signpost |

`$D0` is the separate special-sound `Waterfall` entry and is deliberately not included in the normal SFX ceiling requested for this Sound Test.

## Renderer customization constants

All extension-facing constants are grouped in `_Constants.asm`:

```asm
SoundTest_ExtendedMode
SoundTest_MusicID_First
SoundTest_MusicID_Last
SoundTest_MusicStride
SoundTest_SFXID_First
SoundTest_SFXID_Last
SoundTest_MaxID
SoundTest_DACSample_First
SoundTest_DACSample_Last
SoundTest_ChannelX
SoundTest_NoteX
SoundTest_FreqX
SoundTest_DACNameX
SoundTest_DACID_X
SoundTest_FMOctaveBias
SoundTest_PSGOctaveBias
SoundTest_ShowFrequency
SoundTest_ShowDACSampleID
```

For a larger future Sound Test, change the driver/table contents first; the music count and current last music ID will then follow the driver.

## Graphics / VRAM

The Sound Test font is an 8x16 cell font: two 8x8 Mega Drive tiles per character. The current source uses 83 tiles / 2656 bytes and is compressed with Nemesis for runtime use.

`SoundTest_ArtTile = $200` places the decompressed art at VRAM `$4000`.

The foreground tilemap remains at `vram_fg = $C000`.

The tilemap writer uses the 64-cell plane-A stride (128 bytes per tile row) while the visible Sound Test area remains 40 columns by 28 rows.

The Sound Test palette is kept separate at `palette/Sound Test.bin` and the renderer uses `Tile_Pal1` consistently.

## Build

From the project root:

```text
build.bat
```

The bundled build uses the project's `build_tools/asm68k.exe`. The Sound Test source is included from `sonic.asm` through `soundtest.asm`.
