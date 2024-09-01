;
;	>> Abbuc JHV 2002 Intro <<
;	(c) JAC! on 20.10.2002
;

;=================================================================

start	jsr screen_fade
	rts

	.proc screen_fade
	lda #15
	sta x1
?1	lda #3
	clc
	adc 20
?wait	cmp 20
	bne ?wait
	ldx #8
?2	lda 704,x
	and #$f0
	sta x2
	lda 704,x
	and #15
	cmp x1
	bcc ?3
	lda x1
	beq ?4
?3	ora x2
?4	sta 704,x
	sta $d012,x
	dex
	bpl ?2
	dec x1
	bpl ?1
	lda #0
	sta 559
	lda #1
	sta 580
	lda #$ff
	sta $d301
	clc
	lda #10
	adc 20
?wait2	cmp 20
	bne ?wait2
	rts
	.endp
