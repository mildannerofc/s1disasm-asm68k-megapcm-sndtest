; ===========================================================================
; Sound Test - Knuckles Chaotix-inspired monitor for Sonic 1 ASM68K
; ---------------------------------------------------------------------------
; Uses the existing SMPS driver RAM to display the live FM/PSG note state.
; It does not replace the YM2612/SN76489 driver; it only reads its track state.
; ===========================================================================

GM_SoundTest:
		; Fade the previous screen to black before changing VDP state.
		bsr.w	PaletteFadeOut
		move.b	#bgm_Stop,d0
		bsr.w	QueueSound2
		bsr.w	ClearPLC
		disable_ints
		disable_display

		lea	(vdp_control_port).l,a6
		move.w	#$8004,(a6)			; 40-cell display, normal mode
		move.w	#$8200+(vram_fg>>10),(a6)
		move.w	#$8400+(vram_bg>>13),(a6)
		move.w	#$9001,(a6)			; 64-cell H-scroll table
		move.w	#$8700|$00,(a6)			; palette line 1, colour 0 = dark maroon
		move.w	#$8B00,(a6)			; full-screen vertical scrolling
		move.w	#$8F02,(a6)			; 2-byte VRAM auto-increment
		clr.b	(f_wtr_state).w
		bsr.w	ClearScreen

		; Load the Sound Test palette through the project's palette pointer table.
		clearRAM	v_palette,v_palette_end
		clearRAM	v_palette_fading,v_palette_fading_end
		moveq	#palid_SoundTest,d0
		bsr.w	PalLoad_Fade
		moveq	#palid_SoundTest,d0
		bsr.w	PalLoad

		; Nemesis-compressed 8x16 reference font + helper symbols + icons.
		locVRAM	SoundTest_ArtTile*tile_size
		lea	(SoundTest_Art_Nem).l,a0
		bsr.w	NemDec

		; Upload the real 40x28 foreground tilemap first.
		copyTilemap SoundTest_Tilemap,vram_fg,40,28

		bsr.w	SoundTest_DrawStatic
		bsr.w	SoundTest_SelectInitialEntry
		bsr.w	SoundTest_DrawSelection
		bsr.w	SoundTest_UpdateChannels

		enable_display
		enable_ints
		bsr.w	PaletteFadeIn

SoundTest_Loop:
		; CORREÇÃO DA TELA PRETA: Se sua engine travar aqui, certifique-se de usar um ID padrão 
		; como #2 (id_VBlank_Title) para manter as interrupções estáveis.
		move.b	#id_VBlank_SoundTest,(v_vblank_routine).w
		bsr.w	WaitForVBlank
		bsr.w	SoundTest_Controls
		cmpi.b	#id_SoundTest,(v_gamemode).w
		bne.s	SoundTest_Return

		subq.b	#1,(v_soundtest_timer).w
		bpl.s	SoundTest_Loop
		move.b	#3,(v_soundtest_timer).w
		bsr.w	SoundTest_UpdateChannels
		bra.s	SoundTest_Loop

SoundTest_Return:
		rts

; ---------------------------------------------------------------------------
; Controller handling (CORRIGIDO: Debounce via v_jpadpress1 e Setas Nativas)
; ---------------------------------------------------------------------------
SoundTest_Controls:
		move.b	(v_jpadpress1).w,d0	; Lê unicamente o pulso do botão apertado no frame
		bne.s	.has_press
		rts

.has_press:
		btst	#bitStart,d0
		bne.w	SoundTest_Exit

		btst	#bitA,d0
		bne.s	.add16
		btst	#bitB,d0
		bne.s	.sub16
		btst	#bitL,d0			; CORRIGIDO: Constante padrão Esquerda
		bne.s	.prev
		btst	#bitR,d0			; CORRIGIDO: Constante padrão Direita
		bne.s	.next
		btst	#bitC,d0
		bne.s	.replay
		rts

.add16:
		move.w	(v_soundtest_selection).w,d1
		addi.w	#SoundTest_SelectionStride,d1
		bra.s	.store

.sub16:
		move.w	(v_soundtest_selection).w,d1
		subi.w	#SoundTest_SelectionStride,d1
		bpl.s	.store
		addi.w	#SoundTest_SelectionCount,d1
		bra.s	.store

.prev:
		move.w	(v_soundtest_selection).w,d1
		subq.w	#1,d1
		bpl.s	.store
		move.w	#SoundTest_SelectionLast,d1
		bra.s	.store

.next:
		move.w	(v_soundtest_selection).w,d1
		addq.w	#1,d1
		cmpi.w	#SoundTest_SelectionCount,d1
		blo.s	.store
		clr.w	d1
		bra.s	.store

.replay:
		bsr.w	SoundTest_PlaySelected
		move.b	#0,(v_soundtest_timer).w
		bsr.w	SoundTest_UpdateChannels
		rts

.store:
		cmpi.w	#SoundTest_SelectionCount,d1
		blo.s	.storeok
		subi.w	#SoundTest_SelectionCount,d1
.storeok:
		move.w	d1,(v_soundtest_selection).w
		bsr.w	SoundTest_DrawSelection
		bsr.w	SoundTest_UpdateChannels
		rts

SoundTest_Exit:
		bsr.w	PaletteFadeOut
		move.b	#bgm_Stop,d0
		bsr.w	QueueSound2
		move.b	#SoundTest_ReturnMode,(v_gamemode).w
		rts

; ---------------------------------------------------------------------------
; Start screen and music title.
; ---------------------------------------------------------------------------
SoundTest_DrawStatic:
		move.w	#Tile_Pal1|Tile_Prio,d2

		lea	SoundTest_Title(pc),a0
		moveq	#SoundTest_TitleX,d0
		moveq	#SoundTest_TitleY,d1
		bsr.w	SoundTest_DrawText

		lea	SoundTest_MusicLabel(pc),a0
		moveq	#SoundTest_MusicLabelX,d0
		moveq	#SoundTest_MusicLabelY,d1
		bsr.w	SoundTest_DrawText

		lea	SoundTest_Help(pc),a0
		moveq	#SoundTest_HelpX,d0
		moveq	#SoundTest_HelpY,d1
		bsr.w	SoundTest_DrawText
		lea	SoundTest_StartMenu(pc),a0
		moveq	#SoundTest_StartMenuX,d0
		moveq	#SoundTest_StartMenuY,d1
		bsr.w	SoundTest_DrawText

		lea	SoundTest_ChannelFM1(pc),a0
		moveq	#SoundTest_ChannelX,d0
		moveq	#SoundTest_FM1Y,d1
		bsr.w	SoundTest_DrawText
		lea	SoundTest_ChannelFM2(pc),a0
		moveq	#SoundTest_ChannelX,d0
		moveq	#SoundTest_FM2Y,d1
		bsr.w	SoundTest_DrawText
		lea	SoundTest_ChannelFM3(pc),a0
		moveq	#SoundTest_ChannelX,d0
		moveq	#SoundTest_FM3Y,d1
		bsr.w	SoundTest_DrawText
		lea	SoundTest_ChannelFM4(pc),a0
		moveq	#SoundTest_ChannelX,d0
		moveq	#SoundTest_FM4Y,d1
		bsr.w	SoundTest_DrawText
		lea	SoundTest_ChannelFM5(pc),a0
		moveq	#SoundTest_ChannelX,d0
		moveq	#SoundTest_FM5Y,d1
		bsr.w	SoundTest_DrawText
		lea	SoundTest_ChannelFM6(pc),a0
		moveq	#SoundTest_ChannelX,d0
		moveq	#SoundTest_FM6Y,d1
		bsr.w	SoundTest_DrawText
		lea	SoundTest_ChannelPSG1(pc),a0
		moveq	#SoundTest_ChannelX,d0
		moveq	#SoundTest_PSG1Y,d1
		bsr.w	SoundTest_DrawText
		lea	SoundTest_ChannelPSG2(pc),a0
		moveq	#SoundTest_ChannelX,d0
		moveq	#SoundTest_PSG2Y,d1
		bsr.w	SoundTest_DrawText
		lea	SoundTest_ChannelPSG3(pc),a0
		moveq	#SoundTest_ChannelX,d0
		moveq	#SoundTest_PSG3Y,d1
		bsr.w	SoundTest_DrawText
		lea	SoundTest_ChannelNoise(pc),a0
		moveq	#SoundTest_ChannelX,d0
		moveq	#SoundTest_NoiseY,d1
		bsr.w	SoundTest_DrawText

		move.w	#Tile_Pal1|Tile_Prio,d2
		moveq	#SoundTest_IconX,d0
		moveq	#SoundTest_MusicLabelY,d1
		moveq	#0,d3
		bsr.w	SoundTest_DrawIcon
		moveq	#34,d0
		moveq	#SoundTest_MusicLabelY,d1
		moveq	#2,d3
		bsr.w	SoundTest_DrawIcon

		moveq	#SoundTest_IconX,d0
		moveq	#SoundTest_FM1Y,d1
		moveq	#1,d3
		bsr.w	SoundTest_DrawIcon
		moveq	#SoundTest_FM2Y,d1
		bsr.w	SoundTest_DrawIcon
		moveq	#SoundTest_FM3Y,d1
		bsr.w	SoundTest_DrawIcon
		moveq	#SoundTest_FM4Y,d1
		bsr.w	SoundTest_DrawIcon
		moveq	#SoundTest_FM5Y,d1
		bsr.w	SoundTest_DrawIcon
		moveq	#SoundTest_FM6Y,d1
		bsr.w	SoundTest_DrawIcon
		moveq	#SoundTest_PSG1Y,d1
		bsr.w	SoundTest_DrawIcon
		moveq	#SoundTest_PSG2Y,d1
		bsr.w	SoundTest_DrawIcon
		moveq	#SoundTest_PSG3Y,d1
		bsr.w	SoundTest_DrawIcon
		moveq	#SoundTest_NoiseY,d1
		bsr.w	SoundTest_DrawIcon
		rts

SoundTest_DrawMusic:
		bra.w	SoundTest_DrawSelection

; ---------------------------------------------------------------------------
; Select initial index entry
; ---------------------------------------------------------------------------
SoundTest_SelectInitialEntry:
        moveq   #0,d0
        move.b  #SoundTest_InitialID,d0
        lea     SoundTest_SelectionTable(pc),a0
        moveq   #SoundTest_SelectionCount-1,d1
        moveq   #0,d2
.find:
        cmp.b   (a0),d0
        beq.s   .found
        adda.w  #SoundTest_EntryRecordSize,a0
        addq.w  #1,d2
        dbf     d1,.find
        clr.w   d2
.found:
        move.w  d2,(v_soundtest_selection).w
        rts

SoundTest_DrawSelection:
		move.w	#Tile_Pal1|Tile_Prio,d2
		lea	SoundTest_BlankSelectionHeader(pc),a0
		moveq	#SoundTest_MusicLabelX,d0
		moveq	#SoundTest_MusicLabelY,d1
		bsr.w	SoundTest_DrawText
		lea	SoundTest_BlankMusic(pc),a0
		moveq	#SoundTest_MusicNameX,d0
		moveq	#SoundTest_MusicLabelY,d1
		bsr.w	SoundTest_DrawText

		move.w	(v_soundtest_selection).w,d6
		lsl.w	#3,d6
		lea	SoundTest_SelectionTable(pc),a1
		moveq	#0,d4
		move.b	(a1,d6.w),d4
		moveq	#0,d5
		move.b	1(a1,d6.w),d5
		movea.l	4(a1,d6.w),a2

		tst.b	d5
		beq.s	.music_type
		lea	SoundTest_SFXLabel(pc),a0
		bra.s	.draw_type
.music_type:
		lea	SoundTest_MusicLabel(pc),a0
.draw_type:
		moveq	#SoundTest_MusicLabelX,d0
		moveq	#SoundTest_MusicLabelY,d1
		move.w	#Tile_Pal1|Tile_Prio,d2
		bsr.w	SoundTest_DrawText

		move.w	d4,d1
		bsr.w	SoundTest_FormatByteHex
		moveq	#SoundTest_MusicID_X,d0
		moveq	#SoundTest_MusicLabelY,d1
		move.w	#Tile_Pal1|Tile_Prio,d2
		lea	(v_soundtest_textbuf).w,a0
		bsr.w	SoundTest_DrawText

		movea.l	a2,a0
		moveq	#SoundTest_MusicNameX,d0
		moveq	#SoundTest_MusicLabelY,d1
		move.w	#Tile_Pal1|Tile_Prio,d2
		bsr.w	SoundTest_DrawText
		rts

SoundTest_PlaySelected:
		move.w	(v_soundtest_selection).w,d6
		cmpi.w	#SoundTest_SelectionCount,d6
		blo.s	.valid
		clr.w	d6
		move.w	d6,(v_soundtest_selection).w
.valid:
		lsl.w	#3,d6
		lea	SoundTest_SelectionTable(pc),a0
		moveq	#0,d0
		move.b	(a0,d6.w),d0
		bsr.w	QueueSound2
		rts

; ---------------------------------------------------------------------------
; Channel display tracking
; ---------------------------------------------------------------------------
SoundTest_UpdateChannels:
		lea	(v_snddriver_ram).w,a6

		lea	SMPS_RAM.v_music_fm1_track(a6),a0
		moveq	#8,d0
		bsr.w	SoundTest_DrawFMTrack
		lea	SMPS_RAM.v_music_fm2_track(a6),a0
		moveq	#10,d0
		bsr.w	SoundTest_DrawFMTrack
		lea	SMPS_RAM.v_music_fm3_track(a6),a0
		moveq	#12,d0
		bsr.w	SoundTest_DrawFMTrack
		lea	SMPS_RAM.v_music_fm4_track(a6),a0
		moveq	#14,d0
		bsr.w	SoundTest_DrawFMTrack
		lea	SMPS_RAM.v_music_fm5_track(a6),a0
		moveq	#16,d0
		bsr.w	SoundTest_DrawFMTrack

		lea	SMPS_RAM.v_music_dac_track(a6),a0
		btst	#7,SMPS_Track.PlaybackControl(a0)
		beq.s	.fm6slot
		btst	#1,SMPS_Track.PlaybackControl(a0)
		bne.s	.fm6slot
		bsr.w	SoundTest_DrawDACSlot
		bra.s	.psg1
.fm6slot:
		lea	SMPS_RAM.v_music_fm6_track(a6),a0
		bsr.w	SoundTest_DrawFM6Slot

.psg1:
		lea	SMPS_RAM.v_music_psg1_track(a6),a0
		moveq	#20,d0
		bsr.w	SoundTest_DrawPSGTrack
		lea	SMPS_RAM.v_music_psg2_track(a6),a0
		moveq	#22,d0
		bsr.w	SoundTest_DrawPSGTrack
		lea	SMPS_RAM.v_music_psg3_track(a6),a0
		moveq	#24,d0
		bsr.w	SoundTest_DrawPSGTrack
		bsr.w	SoundTest_DrawNoise
		rts

SoundTest_DrawFMTrack:
		move.w	d0,d5
		move.w	SMPS_Track.Freq(a0),d1
		btst	#7,SMPS_Track.PlaybackControl(a0)
		beq.w	SoundTest_DrawRest
		btst	#1,SMPS_Track.PlaybackControl(a0)
		bne.w	SoundTest_DrawRest
		tst.w	d1
		beq.w	SoundTest_DrawRest
		movea.l	a0,a2
		lea	(FMFrequencies).l,a1
		moveq	#0,d2
		moveq	#SoundTest_FMFrequencyCount-1,d3
.fmfind:
		cmp.w	(a1)+,d1
		beq.s	.fmfound
		addq.w	#1,d2
		dbf	d3,.fmfind
		movea.l	a2,a0
		move.w	d5,d0
		bra.w	SoundTest_DrawRest
.fmfound:
		move.w	d2,d1
		bsr.w	SoundTest_FormatFMNote
		move.w	d5,d1
		move.w	#Tile_Pal1|Tile_Prio,d2
		moveq	#SoundTest_NoteX,d0
		lea	(v_soundtest_textbuf).w,a0
		bsr.w	SoundTest_DrawText
		if SoundTest_ShowFrequency
		move.w	SMPS_Track.Freq(a2),d1
		bsr.w	SoundTest_FormatFrequency
		move.w	d5,d1
		move.w	#Tile_Pal1|Tile_Prio,d2
		moveq	#SoundTest_FreqX,d0
		lea	(v_soundtest_textbuf).w,a0
		bsr.w	SoundTest_DrawText
		endif
		rts

SoundTest_DrawFM6Slot:
		move.l	a0,-(sp)
		move.w	#SoundTest_FM6Y,-(sp)
		lea	SoundTest_DACNameBlank(pc),a0
		moveq	#SoundTest_DACNameX,d0
		move.w	(sp),d1
		move.w	#Tile_Pal1|Tile_Prio,d2
		bsr.w	SoundTest_DrawText
		lea	SoundTest_BlankByte2(pc),a0
		moveq	#SoundTest_DACID_X,d0
		move.w	(sp),d1
		move.w	#Tile_Pal1|Tile_Prio,d2
		bsr.w	SoundTest_DrawText

		moveq	#SoundTest_ChannelX,d0
		moveq	#SoundTest_FM6Y,d1
		move.w	#Tile_Pal1|Tile_Prio,d2
		lea	SoundTest_ChannelFM6(pc),a0
		bsr.w	SoundTest_DrawText
		move.w	(sp)+,d0
		movea.l	(sp)+,a0
		moveq	#SoundTest_FM6Y,d0
		bra.w	SoundTest_DrawFMTrack

SoundTest_DrawDACSlot:
		moveq	#SoundTest_FM6Y,d5
		moveq	#SoundTest_ChannelX,d0
		moveq	#SoundTest_FM6Y,d1
		move.w	#Tile_Pal1|Tile_Prio,d2
		lea	SoundTest_ChannelDAC(pc),a0
		bsr.w	SoundTest_DrawText

		lea	(v_snddriver_ram).w,a6
		lea	SMPS_RAM.v_music_dac_track(a6),a0
		btst	#7,SMPS_Track.PlaybackControl(a0)
		beq.w	SoundTest_DrawRestAtRow
		btst	#1,SMPS_Track.PlaybackControl(a0)
		bne.w	SoundTest_DrawRestAtRow

		lea	SoundTest_DACNameBlank(pc),a0
		move.w	d5,d1
		moveq	#SoundTest_DACNameX,d0
		move.w	#Tile_Pal1|Tile_Prio,d2
		bsr.w	SoundTest_DrawText
		lea	SoundTest_BlankFreq(pc),a0
		move.w	d5,d1
		moveq	#SoundTest_FreqX,d0
		move.w	#Tile_Pal1|Tile_Prio,d2
		bsr.w	SoundTest_DrawText
		lea	SoundTest_BlankByte2(pc),a0
		move.w	d5,d1
		moveq	#SoundTest_DACID_X,d0
		move.w	#Tile_Pal1|Tile_Prio,d2
		bsr.w	SoundTest_DrawText

		lea	(v_snddriver_ram).w,a6
		lea	SMPS_RAM.v_music_dac_track(a6),a0
		moveq	#0,d1
		move.b	SMPS_Track.SavedDAC(a0),d1
		move.b	d1,d4
		cmpi.b	#$80,d4
		beq.w	SoundTest_DrawRestAtRow
		bsr.w	SoundTest_FormatDACName
		move.w	d5,d1
		moveq	#SoundTest_DACNameX,d0
		move.w	#Tile_Pal1|Tile_Prio,d2
		bsr.w	SoundTest_DrawText
		rts

SoundTest_DrawPSGTrack:
		move.w	d0,d5
		move.w	SMPS_Track.Freq(a0),d1
		btst	#7,SMPS_Track.PlaybackControl(a0)
		beq.w	SoundTest_DrawRest
		btst	#1,SMPS_Track.PlaybackControl(a0)
		bne.w	SoundTest_DrawRest
		cmpi.w	#-1,d1
		beq.w	SoundTest_DrawRest
		movea.l	a0,a2
		lea	(PSGFrequencies).l,a1
		moveq	#0,d2
		moveq	#SoundTest_PSGFrequencyCount-1,d3
.psgfind:
		cmp.w	(a1)+,d1
		beq.s	.psgfound
		addq.w	#1,d2
		dbf	d3,.psgfind
		movea.l	a2,a0
		move.w	d5,d0
		bra.w	SoundTest_DrawRest
.psgfound:
		move.w	d2,d1
		bsr.w	SoundTest_FormatPSGNote
		move.w	d5,d1
		move.w	#Tile_Pal1|Tile_Prio,d2
		moveq	#SoundTest_NoteX,d0
		lea	(v_soundtest_textbuf).w,a0
		bsr.w	SoundTest_DrawText
		if SoundTest_ShowFrequency
		move.w	SMPS_Track.Freq(a2),d1
		bsr.w	SoundTest_FormatFrequency
		move.w	d5,d1
		move.w	#Tile_Pal1|Tile_Prio,d2
		moveq	#SoundTest_FreqX,d0
		lea	(v_soundtest_textbuf).w,a0
		bsr.w	SoundTest_DrawText
		endif
		rts

SoundTest_DrawNoise:
		lea	(v_snddriver_ram).w,a6
		lea	SMPS_RAM.v_music_psg3_track(a6),a0
		moveq	#26,d5
		btst	#7,SMPS_Track.PlaybackControl(a0)
		beq.w	SoundTest_DrawRestAtRow
		btst	#1,SMPS_Track.PlaybackControl(a0)
		bne.w	SoundTest_DrawRestAtRow
		cmpi.b	#$E0,SMPS_Track.VoiceControl(a0)
		bne.w	SoundTest_DrawRestAtRow

		move.b	SMPS_Track.PSGNoise(a0),d1
		bsr.w	SoundTest_FormatNoiseNote
		move.w	d5,d1
		move.w	#Tile_Pal1|Tile_Prio,d2
		moveq	#SoundTest_NoteX,d0
		lea	(v_soundtest_textbuf).w,a0
		bsr.w	SoundTest_DrawText

		lea	(v_snddriver_ram).w,a6
		lea	SMPS_RAM.v_music_psg3_track(a6),a0
		moveq	#0,d1
		move.b	SMPS_Track.PSGNoise(a0),d1
		bsr.w	SoundTest_FormatNoiseFrequency
		move.w	d5,d1
		move.w	#Tile_Pal1|Tile_Prio,d2
		moveq	#SoundTest_FreqX,d0
		lea	(v_soundtest_textbuf).w,a0
		bsr.w	SoundTest_DrawText
		rts

SoundTest_DrawRestAtRow:
		move.w	d5,d0
		bra.w	SoundTest_DrawRest

SoundTest_DrawRest:
		move.w	d0,d1
		move.w	#Tile_Pal1|Tile_Prio,d2
		moveq	#SoundTest_NoteX,d0
		lea	SoundTest_Rest(pc),a0
		bsr.w	SoundTest_DrawText
		lea	SoundTest_BlankFreq(pc),a0
		moveq	#SoundTest_FreqX,d0
		bsr.w	SoundTest_DrawText
		rts

; ---------------------------------------------------------------------------
; Format and conversion text utilities
; ---------------------------------------------------------------------------
SoundTest_NoteSemitoneAdjust: equ $0

SoundTest_FormatFMNote:
		moveq	#0,d0
		move.w	d1,d0
		addi.w	#SoundTest_NoteSemitoneAdjust,d0
		bpl.s	.fm_index_ok
		moveq	#0,d0
.fm_index_ok:
		divu.w	#12,d0
		move.w	d0,d4
		swap	d0
		andi.w	#$000F,d0
		lsl.w	#1,d0
		lea	SoundTest_NoteLetters(pc),a1
		lea	(v_soundtest_textbuf).w,a0
		move.b	(a1,d0.w),(a0)+
		move.b	1(a1,d0.w),(a0)+
		addi.w	#SoundTest_FMOctaveBias,d4
		move.b	d4,d0
		andi.b	#$0F,d0
		addi.b	#'0',d0
		move.b	d0,(a0)+
		clr.b	(a0)
		rts

SoundTest_FormatPSGNote:
		moveq	#0,d0
		move.w	d1,d0
		addi.w	#SoundTest_NoteSemitoneAdjust,d0
		bpl.s	.psg_index_ok
		moveq	#0,d0
.psg_index_ok:
		divu.w	#12,d0
		move.w	d0,d4
		swap	d0
		andi.w	#$000F,d0
		lsl.w	#1,d0
		lea	SoundTest_NoteLetters(pc),a1
		lea	(v_soundtest_textbuf).w,a0
		move.b	(a1,d0.w),(a0)+
		move.b	1(a1,d0.w),(a0)+
		addi.w	#SoundTest_PSGOctaveBias,d4
		move.b	d4,d0
		andi.b	#$0F,d0
		addi.b	#'0',d0
		move.b	d0,(a0)+
		clr.b	(a0)
		rts

SoundTest_FormatNoiseNote:
		lea	(v_soundtest_textbuf).w,a0
		move.b	#'N',(a0)+
		move.b	#'-',(a0)+
		andi.w	#$0003,d1
		addi.b	#'0',d1
		move.b	d1,(a0)+
		clr.b	(a0)
		rts

SoundTest_FormatNoiseFrequency:
		bra.w	SoundTest_FormatFrequency

SoundTest_FormatDACName:
		moveq	#0,d1
		move.b	d4,d1
		subi.w	#SoundTest_DACSample_First,d1
		bmi.s	.unknown
		cmpi.w	#SoundTest_DACSample_Last-SoundTest_DACSample_First,d1
		bhi.s	.unknown
		lsl.w	#2,d1
		lea	SoundTest_DACSampleNames(pc),a0
		movea.l	(a0,d1.w),a0
		rts
.unknown:
		lea	SoundTest_DAC_SAMPLE(pc),a0
		rts

SoundTest_FormatByteHex:
		lea	(v_soundtest_textbuf).w,a0
		lea	SoundTest_Hex(pc),a1
		move.w	d1,d0
		lsr.w	#4,d0
		andi.w	#$000F,d0
		move.b	(a1,d0.w),(a0)+
		andi.w	#$000F,d1
		move.b	(a1,d1.w),(a0)+
		clr.b	(a0)
		rts

SoundTest_FormatFrequency:
		lea	(v_soundtest_textbuf).w,a0
		lea	SoundTest_Hex(pc),a1
		move.w	d1,d0
		move.w	d0,d2
		lsr.w	#8,d2
		lsr.w	#4,d2
		andi.w	#$000F,d2
		move.b	(a1,d2.w),(a0)+
		move.w	d0,d2
		lsr.w	#8,d2
		andi.w	#$000F,d2
		move.b	(a1,d2.w),(a0)+
		move.w	d0,d2
		lsr.w	#4,d2
		andi.w	#$000F,d2
		move.b	(a1,d2.w),(a0)+
		andi.w	#$000F,d0
		move.b	(a1,d0.w),(a0)+
		clr.b	(a0)
		rts

; ---------------------------------------------------------------------------
; Draw VDP Graphics and text string handlers
; ---------------------------------------------------------------------------
SoundTest_DrawIcon:
		move.w	d0,d4
		add.w	d4,d4
		move.w	d1,d5
		lsl.w	#7,d5
		add.w	d4,d5
		addi.w	#vram_fg,d5
		move.w	d5,d0
		bsr.w	SoundTest_SetVRAM
		move.w	d3,d0
		addi.w	#SoundTest_IconTile,d0
		or.w	d2,d0
		move.w	d0,(vdp_data_port).l
		rts

SoundTest_DrawText:
		movem.l	d0-d6/a0-a2,-(sp)
		move.w	d0,d6
		add.w	d6,d6
		move.w	d1,d3
		lsl.w	#7,d3
		add.w	d6,d3
		addi.w	#vram_fg,d3
		move.w	d2,d5
		movea.l	a0,a2

		move.w	d3,d0
		bsr.w	SoundTest_SetVRAM
		movea.l	a2,a0
.top:
		moveq	#0,d1
		move.b	(a0)+,d1
		beq.s	.topdone
		cmpi.b	#'a',d1
		blo.s	.notlower_top
		cmpi.b	#'z',d1
		bhi.s	.notlower_top
		subi.b	#$20,d1
.notlower_top:
		cmpi.b	#$7F,d1
		bhi.s	.space_top
		lea	SoundTest_FontMap(pc),a1
		move.b	(a1,d1.w),d1
		addi.w	#SoundTest_ArtTile,d1
		or.w	d5,d1
		move.w	d1,(vdp_data_port).l
		bra.s	.top
.space_top:
		move.w	d5,d1
		ori.w	#SoundTest_ArtTile,d1
		move.w	d1,(vdp_data_port).l
		bra.s	.top
.topdone:

		movea.l	a2,a0
		addi.w	#$80,d3
		move.w	d3,d0
		bsr.w	SoundTest_SetVRAM
.bottom:
		moveq	#0,d1
		move.b	(a0)+,d1
		beq.s	.done
		cmpi.b	#'a',d1
		blo.s	.notlower_bottom
		cmpi.b	#'z',d1
		bhi.s	.notlower_bottom
		subi.b	#$20,d1
.notlower_bottom:
		cmpi.b	#$7F,d1
		bhi.s	.space_bottom
		lea	SoundTest_FontMap(pc),a1
		move.b	(a1,d1.w),d1
		addi.w	#SoundTest_ArtTile+1,d1
		or.w	d5,d1
		move.w	d1,(vdp_data_port).l
		bra.s	.bottom
.space_bottom:
		move.w	d5,d1
		ori.w	#SoundTest_ArtTile+1,d1
		move.w	d1,(vdp_data_port).l
		bra.s	.bottom
.done:
		movem.l	(sp)+,d0-d6/a0-a2
		rts

SoundTest_SetVRAM:
		moveq	#0,d1
		move.w	d0,d1
		andi.l	#$3FFF,d1
		swap	d1
		ori.l	#$40000000,d1
		move.w	d0,d2
		andi.w	#$C000,d2
		lsr.w	#8,d2
		lsr.w	#6,d2
		or.w	d2,d1
		move.l	d1,(vdp_control_port).l
		rts

		include	"soundtest/data/Sound Test Font Mapping.asm"

; ---------------------------------------------------------------------------
; Static Data Block
; ---------------------------------------------------------------------------
SoundTest_Title:        dc.b "SOUND TEST",0
SoundTest_MusicLabel:   dc.b "MUSIC",0
SoundTest_SFXLabel:     dc.b "SFX",0
SoundTest_Help:         dc.b "A+16 B-16 C PLAY",0
SoundTest_StartMenu:    dc.b "START MENU",0
SoundTest_ChannelFM1:   dc.b "FM 1",0
SoundTest_ChannelFM2:   dc.b "FM 2",0
SoundTest_ChannelFM3:   dc.b "FM 3",0
SoundTest_ChannelFM4:   dc.b "FM 4",0
SoundTest_ChannelFM5:   dc.b "FM 5",0
SoundTest_ChannelFM6:   dc.b "FM 6",0
SoundTest_ChannelDAC:   dc.b "DAC ",0
SoundTest_ChannelPSG1:  dc.b "PSG 1",0
SoundTest_ChannelPSG2:  dc.b "PSG 2",0
SoundTest_ChannelPSG3:  dc.b "PSG 3",0
SoundTest_ChannelNoise: dc.b "NOISE",0
SoundTest_BlankSelectionHeader: dc.b "      ",0
SoundTest_BlankMusic:   dc.b "                         ",0
SoundTest_Rest:         dc.b "---",0
SoundTest_PCM:          dc.b "PCM",0
SoundTest_DACActive:    dc.b "----",0
SoundTest_DACNameBlank: dc.b "           ",0
SoundTest_BlankByte2:   dc.b "  ",0
SoundTest_DAC_SAMPLE:   dc.b "SAMPLE",0
SoundTest_BlankFreq:    dc.b "    ",0
SoundTest_Hex:          dc.b "0123456789ABCDEF"
SoundTest_NoteLetters:  dc.b "C-C#D-D#E-F-F#G-G#A-A#B-"
		even

SoundTest_DACSampleNames:
		dc.l SoundTest_DAC_KICK,SoundTest_DAC_SNARE,SoundTest_DAC_TIMPANI,SoundTest_DAC_CLAP
		dc.l SoundTest_DAC_CYMBAL,SoundTest_DAC_UNUSED,SoundTest_DAC_UNUSED,SoundTest_DAC_HITIMPANI
		dc.l SoundTest_DAC_MIDTIMPANI,SoundTest_DAC_LOWTIMPANI,SoundTest_DAC_VERYLOWTIMPANI,SoundTest_DAC_SEGACHANT

SoundTest_DAC_KICK:           dc.b "KICK",0
SoundTest_DAC_SNARE:          dc.b "SNARE",0
SoundTest_DAC_TIMPANI:        dc.b "TIMPANI",0
SoundTest_DAC_CLAP:           dc.b "CLAP",0
SoundTest_DAC_CYMBAL:         dc.b "CYMBAL",0
SoundTest_DAC_UNUSED:         dc.b "UNUSED",0
SoundTest_DAC_HITIMPANI:      dc.b "HI TIMPANI",0
SoundTest_DAC_MIDTIMPANI:     dc.b "MID TIMPANI",0
SoundTest_DAC_LOWTIMPANI:     dc.b "LOW TIMPANI",0
SoundTest_DAC_VERYLOWTIMPANI: dc.b "VERY LOW",0
SoundTest_DAC_SEGACHANT:      dc.b "SEGACHANT",0
		even

		include "soundtest/data/entries/Sound Test Entries.asm"
		even

SoundTest_Art_Nem:
		binclude	"soundtest/data/Sound Test Font Icons.nem"
		even
SoundTest_Art_Nem_End:

SoundTest_Tilemap:
		binclude	"soundtest/data/Sound Test Tilemap.bin"
		even
