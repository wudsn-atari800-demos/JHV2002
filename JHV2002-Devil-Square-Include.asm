;	@com.wudsn.ide.lng.mainsourcefile=JHV2002.asm

square_sin	= sin

square_anz	= 8
square_offset_default	= $100

square_pm	= pm
square_pm0	= square_pm+$327
square_pm1	= square_pm0+$100
square_pm2	= square_pm1+$100
square_pm3	= square_pm2+$100
square_pm4	= square_pm3+$100

square_offset	.ds 2

square_sx	.ds square_anz
square_sy	.ds square_anz
square_ss	.ds square_anz
square_ssl	.ds square_anz
square_ypos	.ds square_anz

	.macro square_plot_pm1
	sta :1,y
	sta :1+1,y
	sta :1+2,y
	sta :1+3,y
	sta :1+4,y
	sta :1+5,y
	sta :1+6,y
	sta :1+7,y
	.endm
	
	.macro square_plot_pm
	square_plot_pm1 :1
	square_plot_pm1 :1+$08
	square_plot_pm1 :1+$10
	square_plot_pm1 :1+$18
	square_plot_pm1 :1+$20
	square_plot_pm1 :1+$28
	square_plot_pm1 :1+$30
	square_plot_pm1 :1+$38
	rts
	.endm

	.macro square_plot_missle1
	lda :1,y
	ora #:2
	sta :1,y
	lda :1+1,y
	ora #:2
	sta :1+1,y
	lda :1+2,y
	ora #:2
	sta :1+2,y
	lda :1+3,y
	ora #:2
	sta :1+3,y
	lda :1+4,y
	ora #:2
	sta :1+4,y
	lda :1+5,y
	ora #:2
	sta :1+5,y
	lda :1+6,y
	ora #:2
	sta :1+6,y
	lda :1+7,y
	ora #:2
	sta :1+7,y
	.endm

	.macro square_plot_mi
	square_plot_missle1 :1 :2
	square_plot_missle1 :1+$08 :2
	rts
	.endm

;==============================================================
square_init
	ldx #0
	txa
?clrpm	sta square_pm+$300,x
	sta square_pm+$400,x
	sta square_pm+$500,x
	sta square_pm+$600,x
	sta square_pm+$700,x
	inx
	bne ?clrpm

	lda #$ff
	sta $d008
	sta $d009
	sta $d00a
	sta $d00b
	sta $d00c

	lda #>square_pm
	sta $d407
	lda #3
	sta $d01d
	lda #$21	;$20 in the original release
	sta $d01b
	sta 623
	
	mwa #square_offset_default square_offset 
	rts

;==============================================================
square_set_color
	lda $d20a
	and #$f0
	sta square_color1
	ora #4
	sta $d012
	sta 704
square_set_color1
	lda $d20a
	and #$f0
	cmp square_color1
	beq square_set_color1
	sta square_color2
	ora #8
	sta $d013
	sta 705
square_set_color2
	lda $d20a
	and #$f0
	cmp square_color1
	beq square_set_color2
	cmp square_color2
	beq square_set_color2
	sta square_color3
	ora #6
	sta $d014
	sta 706
square_set_color3
	lda $d20a
	and #$f0
	cmp square_color1
	beq square_set_color3
	cmp square_color2
	beq square_set_color3
	cmp square_color3
	beq square_set_color3
	ora #8
	sta $d015
	sta 707
	rts

square_color1	.byte 0
square_color2	.byte 0
square_color3	.byte 0
;==============================================================
	.proc square_set_speed
	ldx #[square_anz-1]
?1	lda $d20a
	sta square_sx,x
	clc
	adc #$40
	sta square_sy,x
?2	lda $d20a
	and #3
	beq ?2
	bit $d20a
	bpl ?3
	eor #$ff
?3	sta square_ss,x
	lda $d20a
	and #1
	sta square_ssl,x
	dex
	bpl ?1
	rts
	.endp

;==============================================================
	.proc square_play
	sta ?play_move
	stx sqplay_count
	sty sqplay_count+1
?play	lda #1
	jsr wait
	jsr square_display
	lda ?play_move
	beq ?nomove
	jsr square_move
?nomove	lda wait_break
	bne ?break
	sbw sqplay_count #1
	lda sqplay_count
	ora sqplay_count+1
	bne ?play
	rts

?break	ldx #[square_anz-1]
	lda #0
?1	sta $d000,x
	dex
	bpl ?1
	rts

?play_move	.byte 0
sqplay_count	.word 0
	.endp

;==============================================================
	.proc square_display
	ldx #[square_anz-1]
?cloop	ldy square_ypos,x
	lda #0
	jsr square_plot
	dex
	bpl ?cloop

	ldx #[square_anz-1]
?ploop
	ldy square_sx,x
	lda square_sin,y
	lsr
	lsr
	clc
	adc square_offset
	tay
	lda square_offset+1
	adc #0
	bmi ?hide
	beq ?show
?hide
	ldy #0
?show	tya
	sta $d000,x

	ldy square_sy,x
	lda square_sin,y
	lsr
	tay
	sta square_ypos,x
	lda #$ff
	jsr square_plot

	lda cnt
	and #1
	tay
	clc
	lda square_ssl,x
	lsr
	bcc ?delay
	cpy #0
	bne ?noadd
?delay	clc
	lda square_ss,x
	adc square_sx,x
	sta square_sx,x
	clc
	lda square_ss,x
	adc square_sy,x
	sta square_sy,x
?noadd	dex
	bpl ?ploop
	rts
	.endp

;==============================================================
	.proc square_plot
	cpx #0
	jeq sqpm1
	cpx #1
	jeq sqpm2
	cpx #2
	jeq sqpm3
	cpx #3
	jeq sqpm4
	cmp #0
	jeq sqpmi
	cpx #4
	jeq sqpm5
	cpx #5
	jeq sqpm6
	cpx #6
	jeq sqpm7
	cpx #7
	jeq sqpm8
	rts

sqpm1	square_plot_pm square_pm1
sqpm2	square_plot_pm square_pm2
sqpm3	square_plot_pm square_pm3
sqpm4	square_plot_pm square_pm4
sqpm5	square_plot_mi square_pm0 $c0
sqpm6	square_plot_mi square_pm0 $30
sqpm7	square_plot_mi square_pm0 $0c
sqpm8	square_plot_mi square_pm0 $03
sqpmi	square_plot_pm square_pm0

	.endp

;==============================================================
	.proc square_move
	sbw square_offset #1
	lda #$ff
	cmp square_offset+1
	bne ?1
	lda #$c0
	cmp square_offset
	bne ?1

	mwa #square_offset_default square_offset 
	jsr square_set_color
	jsr square_set_speed
?1	rts
	.endp
