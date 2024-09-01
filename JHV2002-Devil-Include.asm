;	@com.wudsn.ide.lng.mainsourcefile=JHV2002.asm

devil_pic		= $5800
devil_pic_black		= $8b20
devil_pic_width		= 24
devil_pic_height	= 214
devil_sm		= $a000	;$1ac0 bytes
devil_sm_width		= 32
devil_sm_height		= devil_pic_height
devil_sm_size		= devil_sm_width*devil_sm_height
devil_dl		= devil_sm+[devil_sm_size]

;================================================================
	.proc devil_init
	jsr devil_clear
	jsr devil_copy

	lda #$1c+$21
	sta 559
	mwa #devil_dl 560
	rts
	.endp

	.proc devil_intro
	lda #25
	jsr wait

	ldy #0
?fade1	sty 709
	sty 710
	sty 712
	lda #2
	jsr wait
	iny
	cpy #16
	bne ?fade1
	
	dey
	sty devil_color+0
	sty devil_color+1
	sty devil_color+2

	lda #0
	sta devil_fade_cnt
?fade2	ldx #0
?fade3	jsr ?fadex
	inx
	cpx #3
	bne ?fade3
	bit wait_break
	bmi ?fade4
	inc devil_fade_cnt
	bne ?fade2
?fade4	lda #0			;Set show regs
	sta 709
	lda #14
	sta 710
	sta 712

	jsr devil_copy2
	rts

?fadex
	lda devil_scanline,x
	cmp $d40b
	bne *-3
	lda devil_color,x
	sta $d017
	lda devil_fade_cnt
	cmp devil_fade,x
	bcc ?3
	and #1
	bne ?3
	lda devil_color,x
	cmp #0
	beq ?3
	sec
	sbc #1
	sta devil_color,x
?3
	rts
	.endp

devil_scanline	.byte 1,16,110
devil_color	.byte 4,8,10
devil_fade	.byte $20,$60,$a0

;=======================================================================
	.proc devil_clear
	mwa #devil_sm p1
	mwa #devil_sm_size p2
	ldy #0
?1	lda #0
	sta (p1),y
	sbw p1 #1
	sbw p2 #1
	lda p2+1
	ora p2
	bne ?1
	rts
	.endp

;=======================================================================
	.proc devil_copy
	mwa #devil_pic_black p1
	mwa #[devil_sm+4] p2
	lda #devil_pic_height
	sta x1
?copy1	ldy #[devil_pic_width-1]
?copy2	lda (p1),y
	sta (p2),y
	dey
	bpl ?copy2
	adw p1 #devil_pic_width
	adw p2 #devil_sm_width 
	dec x1
	bne ?copy1
	rts
	.endp

;=======================================================================
	.proc devil_copy2
	
	lda #$33
	jsr ?copy0
	lda #$00
?copy0
	sta x2
	mwa #devil_pic_black p1
	mwa #devil_pic p2
	mwa #[devil_sm+4] p3
	lda #devil_pic_height
	sta x1
?copy1	ldy #[devil_pic_width-1]
?copy2	lda (p1),y
	and x2
	ora (p2),y
	sta (p3),y
	dey
	bpl ?copy2
	lda x2
	lsr
	bcc *+4
	ora #$80
	sta x2

	lda #1
	jsr wait

	adw p1 #devil_pic_width
	adw p2 #devil_pic_width 
	adw p3 #devil_sm_width 
	dec x1
	bne ?copy1
	rts

	.endp

devil_fade_cnt	.ds 1

