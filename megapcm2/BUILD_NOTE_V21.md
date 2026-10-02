# MegaPCM 2.1 build note

This project now sets `MegaPCM2_Enable = 1` by default.

`build.bat` checks for the official ASM68K MegaPCM files and, if they are
missing, runs `megapcm2/tools/setup_megapcm2_1.ps1` before invoking asm68k.

The setup script follows the official Sonic 1 installation flow: download
`megapcm.zip` and `sample-tables.zip` from the current MegaPCM release, copy
the ASM68K `MegaPCM.Macros.asm` / `MegaPCM.asm`, and install the Sonic 1
`SampleTable.asm` and sample assets.
