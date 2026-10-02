# MegaPCM 2.1-compatible integration for Sonic 1 Sound Test

This fork contains an enabled by default MegaPCM 2.x integration layer following the
official Sonic 1 ASM68K installation path.

## Enable

1. Run `megapcm2/tools/setup_megapcm2_1.bat` from Windows.
2. Check that `MegaPCM.Macros.asm`, `MegaPCM.asm`, `SampleTable.asm`, and the
   Sonic 1 sample-table assets were installed at the ROM root.
3. Change this at the top of `sonic.asm`:

```asm
MegaPCM2_Enable = 1
```

The project keeps the switch at `1` by default because the official
MegaPCM/sample-table files are external release assets and are not fabricated
inside this fork.

## Integrated path

When enabled, the fork:

- loads `MegaPCM_LoadDriver` and `MegaPCM_LoadSampleTable` during boot;
- routes SMPS DAC playback through `MPCM_play`;
- routes the Sega chant through `MPCM_play #dacSega.id`;
- uses MegaPCM's Z80/YM synchronization helpers for FM writes;
- excludes the old Sonic 1 DAC/Sega PCM blobs from the build;
- extends the Sega-screen wait for asynchronous playback.

The Sound Test itself continues to use Sonic 1's SMPS channel RAM for the live
FM/PSG/DAC/Noise monitor. Sound Test IDs `$A0-$CF` remain SMPS sound-effect
commands; they are not MegaPCM sample-table IDs.

The official MegaPCM API identifies `MegaPCM_LoadDriver`,
`MegaPCM_LoadSampleTable`, and `MPCM_play` as the minimum integration path, and
notes that `MPCM_play` is part of the 2.1 macro set.
