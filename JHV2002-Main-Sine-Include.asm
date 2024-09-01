;	@com.wudsn.ide.lng.mainsourcefile=JHV2002.asm

sine_sm1	= $c000	;$1000 bytes
sine_sm2	= $e000	;$1000 bytes

sine_max_x	= 16
sine_max_y	= 16
sine_max_lines	= 128-10
sine_sm_width	= 32

sine_last_x	= sine_max_x-1
sine_last_y	= sine_max_y-1

sine_x		= x1
sine_y		= x2
sine_z		= x3
sine_px		= x4
sine_py		= x5


	.proc sine_init
	jsr sine_init_regs
	jsr sine_init_tables
	jsr sine_clear
	jsr sine_swap
	jsr sine_clear
	rts
	.endp

	.proc sine_play
	lda #3
	sta ?loops
?step	lda #70
	sta ?steps
?loop	lda #1
	jsr wait
	lda cnt
	sta ?start_frame

	jsr sine_swap
	jsr sine_clear
	jsr sine_plot
	jsr sine_move
	
	lda cnt
	sec
	sbc ?start_frame
	cmp $400
	bcc ?nomax
	sta $400
?nomax	dec ?steps
	bne ?loop
	jsr sine_set_steps
	dec ?loops
	bne ?step
	rts

?loops		.byte 0
?steps		.byte 0
?start_frame	.byte 0
	.endp


;=====================================================================
	.proc sine_init_regs
	lda #0
	sta sine_smup

	lda #$70
	sta sine_offsetx
	clc
	adc #$40
	sta sine_offsety
	lda #0
	sta sine_offsetz

	lda #5
	ldx #7
	ldy #1
	sta sine_offsetx_step
	stx sine_offsety_step
	sty sine_offsetz_step
	rts
	.endp

;=====================================================================
	.proc sine_init_tables
	mwa #sine_sm1 p1
	ldx #0
?1	lda p1
	sta sine_llo,x
	lda p1+1
	sta sine_lhi1,x
	clc
	adc #>[sine_sm2-sine_sm1] 
	sta sine_lhi2,x
	cpx #sine_max_lines
	bcs ?2
	txa		;One even lines due to APAC mode
	lsr
	bcc ?2
	adw p1 #sine_sm_width*2
?2	inx
	bne ?1

	ldx #0
?3	txa
	lsr
	lsr
	lsr
	and #15
	sta x1
	asl
	asl
	asl
	asl
	ora x1
	sta sine_ctab,x
	sta sine_ctab+$100,x
	txa
	asl
	and #$f0
	sta x1
	lsr
	lsr
	lsr
	lsr
	ora x1
	sta sine_ftab,x
	sta sine_ftab+$100,x
	inx
	bne ?3

	rts
	.endp

;=====================================================================
	.proc sine_set_steps
?1	lda $d20a
	and #7
	beq ?1
	sta sine_offsetx_step
?2	lda $d20a
	and #7
	beq ?2
	sta sine_offsety_step
?3	lda $d20a
	and #3
	beq ?3
	lda #0
	sta sine_offsetz_step
	rts
	.endp

;=====================================================================
	.proc sine_dli1
	lda #$21
	sta $d400
	lda #$c0
	sta sine_dli2+1
	sta $d01b
	rts
	.endp

;=====================================================================
	.proc sine_dli2
	lda #$c0
	sta $d01b
	eor #$80
	sta sine_dli2+1
	pla
	rti
	.endp

;=====================================================================
	.proc sine_swap
	lda sine_smup
	eor #1
	sta sine_smup

	ldx #>sine_lhi1
	ldy #>sine_sm2
	cmp #0
	beq ?1
	ldx #>sine_lhi2
	ldy #>sine_sm1
?1	stx sine_plot.sine_plot_color_lhi+2
	sty sine_dl1+1
	rts
	.endp

;=====================================================================
	.proc sine_clear
	.macro sine_clrsm
	sta :1,x
	sta :1+$100,x
	sta :1+$200,x
	sta :1+$200,x
	sta :1+$300,x
	sta :1+$400,x
	sta :1+$500,x
	sta :1+$600,x
	sta :1+$700,x
	sta :1+$800,x
	sta :1+$900,x
	sta :1+$a00,x
	sta :1+$b00,x
	sta :1+$c00,x
	sta :1+$d00,x
	sta :1+$e00,x
	sta :1+$f00,x
	.endm

	lda #0
	tax
	ldy sine_smup
	bne ?3
?2	sine_clrsm sine_sm1
	inx
	bne ?2
	rts

?3	sine_clrsm sine_sm2
	inx
	bne ?3
	rts
	.endp

;=====================================================================
	.macro plot_byte
	ldy #<[:1*sine_sm_width]
	sta (p1),y
	.endm

	.proc sine_plot
	lda sine_offsetx
	sta ?sintabx+1
	lda sine_offsety
	sta ?sintaby+1
	lda sine_offsetz
	sta ?sintabz+1

	lda #0
	sta sine_y
	lda #sine_max_y+sine_last_x
	sta sine_py
sine_plot_loopy
	lda #sine_last_x
	sta sine_x

	lda sine_py
	sta sine_px	;right most pixel (byte) to start

	lda sine_y
	asl
	asl
	asl
	tay
?sintaby
	lda sin,y
	sta ?sinvaly+1

sine_plot_loopx
	lda sine_x
	asl
	asl
	asl
	tax
	clc
?sintabx
	lda sin,x
?sinvaly
	adc #0
	ror
	lsr
	tax
	eor #$ff
	sec
	adc sine_y
	eor #128
	cmp #sine_max_lines
	bcs ?noplot

sine_plot_color
	tay
	lda sine_px
	ora sine_llo,y
	sta p1
	sta p2
sine_plot_color_lhi
	lda sine_lhi1,y
	sta p1+1
	clc
	adc #1
	sta p2+1

?sintabz
	lda sine_ftab,x
	plot_byte 0
	sta (p2),y
	plot_byte 2
	sta (p2),y
	plot_byte 4
	plot_byte 6

	lda sine_ctab,x
	plot_byte 1
	sta (p2),y
	plot_byte 3
	sta (p2),y
	plot_byte 5
	plot_byte 7

?noplot
	dec sine_px
	dec sine_x
	bpl sine_plot_loopx
	dec sine_py
	inc sine_y
	lda sine_y
	cmp #sine_max_y
	bne sine_plot_loopy
	rts
	.endp

;=====================================================================
	.proc sine_move
	lda sine_offsetx
       	clc
	adc sine_offsetx_step
	sta sine_offsetx

	lda sine_offsety
	clc
	adc sine_offsety_step
	sta sine_offsety

	lda sine_offsetz
	clc
	adc sine_offsetz_step
	sta sine_offsetz
	rts
	.end
