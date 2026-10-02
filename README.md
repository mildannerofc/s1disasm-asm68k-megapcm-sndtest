# Sonic the Hedgehog (16-bit) Disassembly

For an overview of the folder structure, [refer to this page](https://info.sonicretro.org/SCHG_How-to:Disassembly_Folder_Structure#Sonic_1).

Also See: http://info.sonicretro.org/Disassemblies

# DISCLAIMER
Any and all content presented in this repository is presented for informational and educational purposes only.
Commercial usage is expressly prohibited. Sonic Retro claims no ownership of any code in these repositories.
You assume any and all responsibility for using this content responsibly. Sonic Retro claims no responsibility or warranty.

## Sound Test

The Sound Test source and its dedicated data/docs/tools are grouped under `soundtest/`.
Start with `soundtest/docs/SOUND_TEST_V15_GUIDE.md` for the current ROM-hacking instructions.

## Sound Test V20 configuration

User-editable Sound Test constants are now in:

`soundtest/config/Sound Test Config.asm`

Playable music/SFX entries are in:

`soundtest/data/entries/Sound Test Entries.asm`

The table count is derived from its actual records, so adding a music or SFX
record no longer requires changing a hard-coded count.

MegaPCM 2.1 integration is enabled by default through `MegaPCM2_Enable = 1` in
`sonic.asm`. `build.bat` checks for the official ASM68K MegaPCM files and runs
the bundled setup script automatically when they are missing.


V26 MegaPCM note: this tree follows the official ASM68K MegaPCM 2.x Sonic 1 integration. Use only the official `asm68k` bundle; do not mix AS files.
