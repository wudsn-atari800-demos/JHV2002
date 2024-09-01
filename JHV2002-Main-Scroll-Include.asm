;	@com.wudsn.ide.lng.mainsourcefile=JHV2002.asm

scroll_text	= $4a00	;Scroll text
scroll_chr1	= $b800	;Text charset
scroll_chr2	= $bc00	;Text charset

;================================================================
scroll_on	.byte 0
scroll_lms	= dl_tptr

scroll_ftab
:20		.byte $00
scroll_hcnt	.ds 1
scroll_hbar1	.ds 1
scroll_hbar2	.ds 1

	.proc scroll_init
	lda #0
	sta scroll_on
	mwa #text scroll_lms
	lda #0
	ldx #$32
	ldy #$72
	sta scroll_hcnt
	stx scroll_hbar1
	sty scroll_hbar2
	ldx #0
?1	lda scroll_chr1,x
	lsr
	sta scroll_chr2,x
	lda scroll_chr1+$100,x
	lsr
	sta scroll_chr2+$100,x
	inx
	bne ?1
	rts
	.endp

	.proc scroll_start
	lda #1
	sta scroll_on
	rts
	.endp

	.proc scroll_fade
	ldx #15	;TODO Is this correct?
?1	stx x1
	ldy #7
?2
	lda #0

	sec
	sbc x1
	beq ?5
	bpl ?4
?3	lda #0
	beq ?5
?4	ora #$30
?5	sta scroll_ftab,y
	dey
	bpl ?2
	lda #2
	jsr wait
	dex
	bpl ?1
	rts
	.endp

	.proc scroll_dli
	txa
	pha
	lda #$23
	sta $d40a
	sta $d400
	lda #0
	sta $d002
	sta $d003
	lda cnt
	lsr
	ldx #>scroll_chr1
	bcc *+4
	ldx #>scroll_chr2
	stx $d409
	lda cnt
	lsr
	and #15
	cmp #8
	bcc ?dlib1
	eor #15
?dlib1	ora #$f8
	sta $d017
	ldx #19
?2	lda scroll_ftab,x
	sta $d40a
	sta $d01a
	sta $d018
	dex
	bpl ?2

	pla
	tax
	rts
	.endp

	.proc scroll_bars
	lda cnt			;two_framed
	and #1
	bne ?3

	ldx #19
	lda #0
?2	sta scroll_ftab,x		;clear_bars
	dex
	bpl ?2

	ldy scroll_hcnt		;set_bars
	lda scroll_hbar1
	jsr ?bar
	lda #$02
	ldy #7
	jsr ?bar
	lda #14
	sec
	sbc scroll_hcnt
	tay
	lda scroll_hbar2
	jsr ?bar

	inc scroll_hcnt		;move_em
	lda scroll_hcnt
	cmp #15
	bne ?3
	lda #0
	sta scroll_hcnt
	ldx scroll_hbar1
	ldy scroll_hbar2
	stx scroll_hbar2
	sty scroll_hbar1
?3	rts

?bar	clc			;print_subroutine
	iny
	sta scroll_ftab,y
	sta scroll_ftab+4,y
	adc #2
	sta scroll_ftab+1,y
	sta scroll_ftab+3,y
	adc #2
	sta scroll_ftab+2,y
	rts
	.endp

	.proc scroll_line
	lda scroll_on
	beq ?1
	lda cnt
	lsr
	bcs ?1
	and #3
	eor #3
	sta $d404
	cmp #3
	bne ?1
	inc scroll_lms
	bne ?1
	inc scroll_lms+1
	lda scroll_lms+1
	cmp #>[text+$300]
	bne *+4
	lda #>text
	sta scroll_lms+1
?1	rts
	.endp
