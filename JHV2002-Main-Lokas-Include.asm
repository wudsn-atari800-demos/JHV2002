;	@com.wudsn.ide.lng.mainsourcefile=JHV2002.asm

lokas_movie	= $0cdb	;$919a bytes

lokas_sm1	= $c000	;$1000 bytes
lokas_sm2	= $e000	;$1000 bytes
lokas_sm_width	= 40
lokas_sm_height	= 102

lokas_base	= $f000
lokas_setlms	= $fc00	;SetLms_Routine, $140 bytes


sektor	= 512		;Start_Sector.
base1	= $1000		;Load_Base.
number1	= 264		;Number_of_Sectors_to_read.
base2	= $4000		;Load_Base.
number2	= 117		;Number_of_Sectors_to_read.
base3	= $4000		;Load_Base.
number3	= 119		;Number_of_Sectors_to_read.

;=================================================================
	.proc lokas_init
	lda #0
	sta lokas_flag
	sta lokas_color0
	sta lokas_color1

	lda #$20
	sta lokas_dma

	ldx #0
?1	txa		;replicate pattern
	lsr
	lsr
	lsr
	lsr
	tay
	lda ?pattern,y
	sta lokas_pathi,x
	txa
	and #$0f
	tay
	lda ?pattern,y
	sta lokas_patlo,x
	inx
	bne ?1
	rts

?pattern
	.byte $00,$11,$22,$33,$44,$55,$66,$77,$88,$99,$aa,$bb,$cc,$dd,$ee,$ff
	.endp

;=================================================================
	.proc lokas_clear
	lda #>lokas_sm2		;Clear_Page_2
	jsr ?clrsm
	lda #>lokas_sm1		;Clear_Page_1
	jsr ?clrsm
	rts

?clrsm	sta p1+1
	lda #0
	sta p1
	tay
	ldx #$10
?clrpage
	sta (p1),y
	iny
	bne ?clrpage
	inc p1+1
	dex
	bne ?clrpage
	rts
	.endp

;=================================================================
	.proc lokas_fade_in
	ldy #0			;lokas frame
?1	sty lokas_color1
	lda #2
	jsr wait
	iny
	cpy #16
	bne ?1
	rts
	.endp

;=================================================================
	.proc lokas_dli1
	lda #$22
	sta $d400
	lda #0
	sta $d01d
	sta $d014
	sta $d015
	lda lokas_color1
	sta $d016
	sta $d012
	sta $d013

	lda #$30
	sta $d000
	lda #$d0
	sta $d001
	sta $d003
	lda #$10
	sta $d002

	lda #$ff
	sta $d00a
	sta $d00b
	sta $d00f
	sta $d010
	lda #$80
	sta $d00d
	sta $d00e

	sta $d40a
	lda lokas_dma
	sta $d400
	lda lokas_color0
	sta $d01a
	lda #$40
	sta $d01b
	rts
	.endp

;=================================================================
	.proc lokas_dli2
	lda #$22
	sta $d400
	lda #0
	sta $d01b
	sta $d40a
	sta $d01a
	sta $d000
	sta $d001
	rts
	.endp

;=================================================================
	.proc lokas_play_init
	lda #>lokas_sm2
	ldx #>lokas_sm1
	ldy #0
	sta lokas_smup1
	stx lokas_smup2
	sty lokas_picup
	
	lda #0
	sta lokas_mode
	rts
	.endp

;=================================================================
	.proc lokas_play_next
	inc lokas_picup
	lda lokas_picup
	cmp #36
	bne ?1
	lda #0
	sta lokas_picup
	lda #50
	jsr wait
?1	rts
	.endp

;=================================================================
	.proc lokas_fade_color_up
?1	lda $d20a
	and #$f0
	beq ?1
	cmp lokas_color0
	beq ?1
	clc
	adc #15
	sta ?newcolor
	ldx #0
	ldy lokas_color0
?2	sty lokas_color0
	lda #2
	jsr wait
	iny
	inx
	cpx #16
	bne ?2
	rts
	.endp

	.proc lokas_fade_color_down
	ldx #16
	ldy ?newcolor
	bit lokas_flag
	bmi ?4
	ldy #15
?4	sty lokas_color0
	lda #2
	jsr wait
	dey
	dex
	bne ?4
	rts
	.endp

?newcolor	.byte 0

;=================================================================
	.proc lokas_play
	lda lokas_mode
	bmi ?1
	jsr lokas_play18
	jmp ?2
?1	jsr lokas_play36
?2	jsr lokas_depack
	rts
	.endp

;=================================================================
	.proc lokas_play18

?play1	lda lokas_picup
	cmp #18
	bcc ?play2
	lda #35
	sec
	sbc lokas_picup
?play2	asl
	tax
	clc
	lda ?offset,x
	adc #<lokas_movie
	sta p1
	lda ?offset+1,x
	adc #>lokas_movie
	sta p1+1
	rts

?offset	.word $0000,$070a,$0ea5,$1608,$1dce,$269a,$300e,$398e,$4352
	.word $4c86,$550f,$5d80,$65e3,$6df3,$7575,$7cdc,$83b3,$8aa7
	.word $919a
	.endp

;=================================================================
	.proc lokas_play36
?play1	ldx lokas_picup
	ldy ?mmuidx,x
	lda ?mmuval,y
	sta $d301
	lda ?adrlo,x
	sta p1
	lda ?adrhi,x
	sta p1+1
	rts

?adrhi	.byte $10,$17,$1e,$27,$30,$39,$42,$4a,$51
	.byte $58,$5f,$66,$6d,$74,$78,$79,$7e,$84
	.byte $8b,$40,$47,$51,$5a,$63,$6b,$73,$40
	.byte $46,$4e,$54,$5b,$60,$63,$66,$6c,$73

?adrlo	.byte $00,$0a,$6d,$39,$b9,$ed,$5e,$6e,$d5
	.byte $c9,$e7,$ec,$ce,$44,$6b,$f8,$0e,$f7
	.byte $fa,$00,$c6,$3a,$fe,$87,$ea,$6c,$00
	.byte $f3,$0c,$be,$78,$f3,$4c,$18,$c4,$f4

?mmuidx	.byte 0,0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0,0
	.byte 0,1,1,1,1,1,1,1,2
	.byte 2,2,2,2,2,2,2,2,2
?mmuval	.byte $fe,$ee,$ec

	.endp

;=================================================================
	.proc lokas_swap
	lda lokas_smup1
	ldx lokas_smup2
	sta lokas_smup2
	stx lokas_smup1
	lda $d40b
	bne *-3
	jsr lokas_setlms
	rts
	.endp

;=================================================================
	.proc lokas_depack
	lda #0
	sta p2
	lda lokas_smup2
	sta p2+1
	clc
	adc #$0f		;High-byte of screen end
	sta ?depack3+1
	ldy #0

?depack1	
	lda (p1),y
	inw p1
	tax
	cmp #$f0
	bcs ?found1
	and #$0f
	cmp #$0f
	beq ?found2
	txa
	sta (p2),y
	inc p2
	bne ?depack1
	inc p2+1

?depack2
	lda p2+1	;high-byte of screen end, end of low-byte at $f0 is ignored
?depack3
	cmp #$ff
	bcc ?depack1
	lda p2
	cmp #$ff
	bne ?depack1
	rts

;---------------------------------------------------------------
?found1	lda (p1),y		;load number of bytes to repeat
	inw p1
	pha
	tay
	lda lokas_patlo,x
?fill1	sta (p2),y		;fill
	dey
	bne ?fill1
	sta (p2),y

	pla			;add_steps+1
	sec
	adc p2
	sta p2
	bcc ?depack2
	inc p2+1
	jmp ?depack2

;---------------------------------------------------------------
?found2	lda lokas_pathi,x
	sta (p2),y		;store_two_steps
	iny
	sta (p2),y
	dey

	clc			;add_steps
	lda p2
	adc #2
	sta p2
	bcc ?depack2
	inc p2+1
	jmp ?depack2

	.endp

;================================================================
	.proc lokas_gen_dl
	ldy #0
	mwa #lokas_dl p1
	mwa #lokas_setlms p2
	mwa #lokas_sm1 p3

	jsr ?gen_dl3
	inw p1
	jsr ?gen_dl3
	inw p1
	adw p3 #lokas_sm_width

	ldx #0
?gen_dl1
	lda #$0f
	sta (p1),y
	inw p1
	jsr ?gen_dl3

	lda #$8e		;STX $nnnn
	sta (p2),y
	inw p2
	lda p1
	sta (p2),y
	inw p2
	lda p1+1
	sta (p2),y
	inw p2
	inw p1

	clc
	lda p3
	adc #lokas_sm_width
	sta p3
	bcc ?gen_dl2
	inc p3+1
	lda #$e8		;INX
	sta (p2),y
	inw p2

?gen_dl2
	inx
	cpx #[lokas_sm_height-1]
	bne ?gen_dl1

	lda #$60		;RTS
	sta (p2),y
	rts

?gen_dl3
	lda #$4f		;SETLMS ($CF for DLI)
	cpx #[lokas_sm_height-2]
	bne *+4
	ora #$80
	sta (p1),y
	inw p1
	lda p3
	sta (p1),y
	inw p1
	lda p3+1
	sta (p1),y
	rts
	.endp

