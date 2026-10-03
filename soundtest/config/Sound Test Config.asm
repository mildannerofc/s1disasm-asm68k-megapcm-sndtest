; ===========================================================================
; Sonic 1 Sound Test - USER CONFIGURATION
; ---------------------------------------------------------------------------
; Edit this file to change the range/behaviour of the Sound Test.
;
; IMPORTANT:
; - The numeric IDs below describe the range you want exposed.
; - The actual playable entries live in:
;     soundtest/data/entries/Sound Test Entries.asm
; - Music/SFX counts are derived from the entry table, not from First/Last.
;   This means adding a new record to the table automatically changes the
;   selection count without requiring another hard-coded count.
;
; Example:
;   SoundTest_MusicID_First equ $81
;   SoundTest_MusicID_Last  equ $93
; is the current Sonic 1 music set.
;
; To add a NEW music entry, add a SoundTest_MusicEntry record to the music
; section of Sound Test Entries.asm and update the First/Last documentation
; values if the range changes.
; ===========================================================================

; ---------------------------------------------------------------------------
; Sound Test mode
; ---------------------------------------------------------------------------
SoundTest_ExtendedMode:     equ 1       ; 0 = music only, 1 = expose extended entries
SoundTest_EnableSFX:         equ 1       ; 0 = hide the A0-CF SFX section

; ---------------------------------------------------------------------------
; User-visible ID ranges
; ---------------------------------------------------------------------------
SoundTest_MusicID_First:     equ $81    ; first music ID currently documented
SoundTest_MusicID_Last:      equ $93    ; last music ID currently documented
SoundTest_InitialID:         equ SoundTest_MusicID_First
SoundTest_ReturnMode:        equ $04    ; id_Title / return to the Sonic 1 title menu

SoundTest_SFXID_First:       equ $A0    ; first normal Sonic 1 SFX
SoundTest_SFXID_Last:        equ $CF    ; last normal Sonic 1 SFX

; A/B moves this many entries. Left/Right moves by one entry.
SoundTest_SelectionStride:   equ 16

; ---------------------------------------------------------------------------
; Record/table definitions
; ---------------------------------------------------------------------------
SoundTest_EntryRecordSize:   equ 8
SoundTest_EntryType_Music:   equ 0
SoundTest_EntryType_SFX:     equ 1

; These are derived from the actual entry table.  They are deliberately NOT
; derived from First/Last, so adding/removing records cannot desynchronise the
; navigator from the table.
SoundTest_MusicCount:        equ (SoundTest_MusicTable_End-SoundTest_MusicTable)/SoundTest_EntryRecordSize
SoundTest_SFXCount:          equ (SoundTest_SFXTable_End-SoundTest_SFXTable)/SoundTest_EntryRecordSize
SoundTest_SelectionCount:    equ SoundTest_MusicCount+(SoundTest_EnableSFX*SoundTest_SFXCount)
SoundTest_SelectionLast:     equ SoundTest_SelectionCount-1

; Backwards-compatible names used by older Sound Test code.
SoundTest_MusicStride:       equ SoundTest_SelectionStride
SoundTest_MaxID:             equ SoundTest_SFXID_Last

; ---------------------------------------------------------------------------
; DAC sample IDs used by the normal Sonic 1 SMPS stream
; ---------------------------------------------------------------------------
SoundTest_DACSample_First:   equ $81
SoundTest_DACSample_Last:    equ $8C

; ---------------------------------------------------------------------------
; Graphics / layout
; ---------------------------------------------------------------------------
SoundTest_ArtTile:           equ $200
SoundTest_TilesPerChar:      equ 2
SoundTest_FontCharCount:     equ 40
SoundTest_FontTileCount:     equ SoundTest_TilesPerChar*SoundTest_FontCharCount
SoundTest_IconTile:          equ SoundTest_ArtTile+SoundTest_FontTileCount
SoundTest_ArtTileCount:      equ SoundTest_FontTileCount+3
SoundTest_ArtDecompressedSize:equ SoundTest_ArtTileCount*tile_size

SoundTest_TitleX:            equ 4
SoundTest_TitleY:            equ 1
SoundTest_MusicLabelX:       equ 4
SoundTest_MusicLabelY:       equ 4
SoundTest_MusicID_X:         equ 10
SoundTest_MusicNameX:        equ 14
SoundTest_HelpX:             equ 4
SoundTest_HelpY:             equ 6
SoundTest_StartMenuX:        equ 27
SoundTest_StartMenuY:        equ 6
SoundTest_ChannelX:          equ 4
SoundTest_IconX:             equ 1
SoundTest_NoteX:             equ 18
SoundTest_FreqX:             equ 24
SoundTest_DACNameX:          equ SoundTest_NoteX
SoundTest_DACID_X:           equ 30
SoundTest_ChannelY:          equ 8
SoundTest_ChannelStepY:      equ 2
SoundTest_FM1Y:              equ SoundTest_ChannelY
SoundTest_FM2Y:              equ SoundTest_FM1Y+(SoundTest_ChannelStepY*1)
SoundTest_FM3Y:              equ SoundTest_FM1Y+(SoundTest_ChannelStepY*2)
SoundTest_FM4Y:              equ SoundTest_FM1Y+(SoundTest_ChannelStepY*3)
SoundTest_FM5Y:              equ SoundTest_FM1Y+(SoundTest_ChannelStepY*4)
SoundTest_FM6Y:              equ SoundTest_FM1Y+(SoundTest_ChannelStepY*5)
SoundTest_PSG1Y:             equ SoundTest_FM1Y+(SoundTest_ChannelStepY*6)
SoundTest_PSG2Y:             equ SoundTest_FM1Y+(SoundTest_ChannelStepY*7)
SoundTest_NoiseY:            equ SoundTest_FM1Y+(SoundTest_ChannelStepY*8)
SoundTest_FMFrequencyCount: equ (FMFrequencies_End-FMFrequencies)/2
SoundTest_PSGFrequencyCount:equ (PSGFrequencies_End-PSGFrequencies)/2
SoundTest_PaletteLine:       equ 0
SoundTest_FMOctaveBias:      equ 0
SoundTest_PSGOctaveBias:     equ 0
SoundTest_NoteWidth:         equ 3
SoundTest_FrequencyWidth:    equ 4
SoundTest_ShowFrequency:     equ 1
SoundTest_ShowDACSampleID:   equ 1
