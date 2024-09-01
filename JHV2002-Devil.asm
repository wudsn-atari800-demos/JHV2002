;
;	>> Abbuc JHV 2002 Intro - Part 2 <<
;	(c) JAC! on 20.10.2002
;
;	@com.wudsn.ide.lng.mainsourcefile=JHV2002.asm


sound		= $5000
sound_address1	= $8400

sin	.ds $100

pm	= $4800

;=====================================================================

start
	jsr screen_init
	jsr intro
	jsr screen_exit
	rts

	.proc screen_init
	lda #0
	sta 709
	sta 710
	sta 712
	lda $d40b
	bne *-3

	sei
	lda #0
	sta $d40e
	lda #$ff
	sta $d301
	lda $222
	sta vbi_old
	lda $223
	sta vbi_old+1
	mwa #vbi $222
	rts
	.endp

	.proc screen_exit
	sei
	lda #$00
	sta $d40e
	lda vbi_old
	sta $222
	lda vbi_old+1
	sta $223
	lda #$40
	sta $d40e
	cli
	clc
	rts
	.endp


	.proc intro
	mwa #sound_address1 sound_pointer
	jsr sound_init
	jsr devil_init

?wait1	lda $d010
	beq ?wait1
?wait2	lda $d40b
	bne ?wait2
	lda #$40
	sta $d40e
	cli

	jsr devil_intro
	jsr square_init
	jsr square_set_color
	jsr square_set_speed

	lda #1
	ldx #176
	ldy #0
	jsr square_play

	lda #0
	ldx #0
	ldy #1
	jsr square_play

	lda #1
	ldx #180
	ldy #0
	jsr square_play
	
	lda #250
	jsr wait
	lda #25
	jsr wait
	jsr sound_stop
	rts
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


vbi	lda $d20f
	and #12
	cmp #12
	bne vbi0
	lda $d01f
	and #7
	cmp #7
	bne vbi0
	lda $d010
	bne vbi1
vbi0	lda #$ff
	sta wait_break
vbi1
	jsr sound_replay
	.byte $4c
vbi_old	.word $ffff

	rts

;================================================================

	org $3000

	icl "JHV2002-Devil-Include.asm"
	icl "JHV2002-Devil-Sound-Include.asm"
	icl "JHV2002-Devil-Square-Include.asm"

	org devil_dl
	.byte $70
	.byte $4f
	.word devil_sm
	.rept 127
	.byte $0f
	.endr
	.byte $4f
	.word devil_sm+$1000
	.rept 85
	.byte $0f
	.endr
	.byte $41
	.word devil_dl

	org devil_pic
	ins "JHV2002-Devil.pic"
	
	org devil_pic_black
	ins "JHV2002-Devil-Black.pic"

	org sound
	ins "JHV2002-Devil-CMC-Replay$5000.prg"

	org sin
	ins "JHV2002-Devil-Sinus256.sin"

	org sound_address1-6
	ins "JHV2002-Devil-Gyrae-$8400.cmc"	;Also nice
