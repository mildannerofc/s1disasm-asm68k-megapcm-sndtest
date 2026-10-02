# Sound Test configuration

Edit `Sound Test Config.asm` to control the Sound Test without hunting through
large source files.

The important settings are:

```asm
SoundTest_MusicID_First:   equ $81
SoundTest_MusicID_Last:    equ $93
SoundTest_InitialID:       equ SoundTest_MusicID_First
SoundTest_SFXID_First:     equ $A0
SoundTest_SFXID_Last:      equ $CF
SoundTest_EnableSFX:       equ 1
SoundTest_SelectionStride: equ 16
```

The **actual number of entries is derived from the table**, not from
`First/Last`. To add music, add `SoundTest_MusicEntry <id>, <name>` to the music
section of `soundtest/data/entries/Sound Test Entries.asm`. The navigator then
sees the added record automatically.

For the standard Sonic 1 set this produces music `$81-$93` followed by SFX
`$A0-$CF`.
