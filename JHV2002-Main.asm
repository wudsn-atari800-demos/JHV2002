;
;	>> Abbuc JHV 2002 Intro - Part 3 <<
;	(c) JAC! on 20.10.2002
;
;	@com.wudsn.ide.lng.mainsourcefile=JHV2002.asm


sound		= $0500
sound_address2	= $b004

lokas	= 1
sine	= 2

sin	= $be00	;$100 bytes

pm	= $d800

;=================================================================

	org $a000

dl	.byte $01
dl_ptr	.word lokas_dl_begin

dl_end	.byte $70,$52
dl_tptr	.word $ffff
	.byte $41
	.word dl

lokas_dl_begin
	.byte $80,$4e
	.word frame_line
lokas_dl
:410	.byte $00
	.byte $4e
	.word frame_line
	.byte $01
	.word dl_end

sine_dl_begin
	.byte $80,$4e
	.word frame_line

	.byte $70,$70,$70,$70,$70
	.byte $cf
sine_dl1
	.word sine_sm1
	.rept 127
	.byte $8f
	.endr
	.byte $70,$70,$70,$70,$10
	.byte $80,$00,$4e
	.word frame_line
	.byte $01
	.word dl_end


;=================================================================
start	jsr screen_init
	jsr intro
	rts

;=================================================================
	.proc screen_init
	sei
	lda #0
	sta $d40e
	sta $d20e
	sta $d400
	tax
?clr1	sta $d000,x
	inx
	bne ?clr1
	lda #$3c
	sta $d303
	lda #$fe
	sta $d301

	mwa #$e000 p1
	mwa #$0500 p2
	ldx #$20
	ldy #0
?copy	lda (p1),y
	sta (p2),y
	iny
	bne ?copy
	inc p1+1
	inc p2+1
	dex
	bne ?copy
?copx
	lda #0
	tax
?clrpm	sta pm+$300,x	;clear_pm
	sta pm+$400,x
	sta pm+$500,x
	sta pm+$600,x
	sta pm+$700,x
	inx
	bne ?clrpm

	lda #>pm
	sta $d407
	mwa #dli3 dliv

	mwa #nmi $fffa
	rts
	.endp

;=================================================================

	.proc intro
	mwa #sound_address2 sound_pointer
	jsr sound_init
	jsr lokas_gen_dl

	jsr scroll_init
	jsr lokas_init
	jsr convert_text

	jsr set_lokas

?wait1	lda $d010
	beq ?wait1
?wait2	lda $d40b
	bne ?wait2
	lda #$40
	sta $d40e
	lda #1
	jsr wait
;	cli

	jsr scroll_fade
	jsr scroll_start

	jmp main_loop_test

	lda #250
	jsr wait
	lda #150
	jsr wait
	jsr lokas_fade_in
	lda #250
	jsr wait
	jsr lokas_fade_color_up
main_loop
	jsr lokas_show

	jsr lokas_fade_color_up
	lda #$20
	sta lokas_dma
	sta lokas_flag

	jsr lokas_fade_color_down

main_loop_test
	lda #sine
	sta mode
	mwa #sine_dl_begin dl_ptr

	jsr sine_init

	lda #$ff
	sta lokas_flag
	lda #$21
	sta lokas_dma

	jsr sine_play
	jmp main_loop_test

	lda #$20
	sta lokas_dma
	jsr set_lokas
	jsr lokas_fade_color_up

	jmp main_loop
	.endp

mode	.byte 0

set_lokas
	lda #lokas
	sta mode
	mwa #lokas_dl_begin dl_ptr
	rts

;================================================================
lokas_first .byte 1

	.proc lokas_show
	jsr lokas_play_init
	jsr lokas_play
	jsr lokas_swap

	lda #$ff
	sta lokas_flag

	lda #$22
	sta lokas_dma
	jsr lokas_fade_color_down

	lda #75
	jsr wait

	lda lokas_first
	beq ?first
	lda #250
	jsr wait
	lda #50
	jsr wait
	lda #0
	sta lokas_first

?first	lda #4
	sta lokas_count
?loop	jsr lokas_play
	jsr lokas_swap
	jsr lokas_play_next
	lda lokas_picup
	bne ?loop
	dec lokas_count
	beq ?exit
	jsr lokas_fade_color_up
	jsr lokas_fade_color_down
	jmp ?loop
?exit	rts
	.endp

;================================================================
	.proc wait
	clc
	adc cnt
@1	bit wait_break
	bmi @2
	cmp cnt
	bne @1
@2	rts
	.endp

wait_break	.byte 0

;================================================================

nmi	bit $d40f
	bpl nmi1

;================================================================

dli	pha			;Display list interrupt entry point.
	.byte $4c		;JMP $nnnn
dliv	.word dlix		;DLI target vector

dli3	jsr lokas_dli1
	lda mode
	cmp #sine
	beq ?1
	mwa #dli4l dliv
	pla
	rti
		
?1	mwa #dli4s dliv
	lda #$c0
	sta dli4s+1
	pla
	rti

dli4l	sta $d40a	
dli4s1	jsr lokas_dli2	;Lokas
	jsr scroll_dli
	pla
	rti

dli4s	lda #$40
	eor #$80
	sta dli4s+1
	sta $d40a
	sta $d01b
	lda $d40b
	cmp #90
	bcs dli4s1
	pla
	rti

dlix	pla
	rti

;================================================================
nmi1	pha
	txa
	pha
	tya
	pha
	jmp vbi

nmix	pla
	tay
	pla
	tax
	pla
	rti

;================================================================

	.proc vbi
	lda $d20f
	and #12
	cmp #12
	bne ?vbi0
	lda $d01f
	and #7
	cmp #7
	bne ?vbi0
	lda $d010
	bne ?vbi1
?vbi0	lda #$ff
;	sta wait_break

?vbi1
	mwa #dl $d402
	mwa #dli3 dliv
	lda #$c0
	sta $d40e
	lda #3
	sta $d01d
	lda #$3d
	sta $d400

	jsr sound_replay
	jsr scroll_line
	jsr scroll_bars
	inc cnt
	jmp nmix
	.endp

;=================================================================
	.proc convert_text
	mwa #original_text p1
	mwa #text p2
	jsr ?convert
	rts

?convert
	ldy #0			;Convert_ASCII
?conv1	lda (p1),y
	cmp #$ff
	bne ?conv2
	rts
?conv2	sec
	sbc #$20
	cmp #$20
	bcc ?conv3
	sbc #$20
?conv3	sta (p1),y
	sta (p2),y
	inw p1
	inw p2
	jmp ?conv1
	.endp

original_text
	.byte '                                                    '
	.byte ' willkommen auf der abbuc jhv 2002 ...       '
	.byte '    beginnen wir mit der show!   '
	.byte ' die animation hat 18 bilder in einer aufloesung von 80x100 punkten - '
	.byte 'das entspricht 72000 bytes. die bilder werden echtzeit entpackt mit einer '
	.byte 'geschwindigkeit von 10 bildern pro sekunde.                           '
	.byte 'und der zweite effekt ist ein 256 farben wellenmuster aus 512 punkten.  '
	.byte 'ich hoffe das ganze gefaellt euch! diese version ist gerade noch '
	.byte 'rechtzeitig '
	.byte 'fuer die jhv fertig geworden. es danach wird noch eine verbesserte geben. '
	.byte 'gruesse und ein riesiges danke gehen an meine frau patricia, stephan von f2 '
	.byte 'und konrad szscesniak. besides a big hello to all members of taquart -'
	.byte ' i hope to hear from you soon! jac on 25-10-2002'
	.byte '                                                                    '
	.byte '                                                             '
	.byte '                             '

	.byte $ff

frame_line
:40	.byte $55

;================================================================

	icl "JHV2002-Main-Sound-Include.asm"
	icl "JHV2002-Main-Scroll-Include.asm"
	icl "JHV2002-Main-Lokas-Include.asm"
	icl "JHV2002-Main-Sine-Include.asm"

	org $f000
	icl "JHV2002-Main-Lokas.inc"
	org $f400
	icl "JHV2002-Main-Sine.inc"

	org $f800
text	.ds $400

;	The sound replay routine is included in "JHV2002-Lokas-$0500-$24ff.bin"
	org sound-6
	ins "JHV2002-Devil-Main-CMC-Replay$0500.prg"

;	The lokas movie is split into "JHV2002-Main-Lokas18-$0500-$24ff.bin" and "JHV2002-Main-LokasLokas-$2500-$9e74.bin"
;	org lokas_movie
;	ins "JHV2002-Main-Lokas18.pic" // $919a bytes

;	The first part of the movie is copied under the ROM by the saver. See "screen_init".
;	org $0500
;	ins "JHV2002-Main-Lokas18-$0500-$24ff.bin"

;	The second part of the movie included here.
	org $2500
	ins "JHV2002-Main-Lokas18-$2500-$9e74.bin"

	org scroll_chr1
	ins "JHV2002-Main.chr"

	org sound_address2-6
	ins "JHV2002-Main-Muz43-$b004.cmc"	; Nice game/intro tune

	org sin
	ins "JHV2002-Main-Sine.sin"
	ins "JHV2002-Main-Sine.sin"
