# MegaPCM 2.x / 2.1 integration notes

The implementation in this fork is conditional. It follows the official Sonic
1 Github ASM68K installation path: install `MegaPCM.Macros.asm`, `MegaPCM.asm`
and the Sonic 1 `SampleTable.asm`, load the driver/sample table at boot, route
SMPS DAC playback to `MPCM_play`, replace the blocking Sega chant implementation,
and remove the old Sonic 1 DAC/Sega PCM ownership when MegaPCM is enabled.

The switch lives at the top of `sonic.asm`:

```asm
MegaPCM2_Enable = 0
```

Set it to `1` only after running the setup script and verifying the installed
files match the ASM68K bundle.

The official MegaPCM API documents `MegaPCM_LoadDriver`,
`MegaPCM_LoadSampleTable`, and `MPCM_play`; the 2.1 macro set is the supported
API generation used by this integration.
