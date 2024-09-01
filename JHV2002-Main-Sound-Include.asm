sound_set	= sound+3
sound_replay	= sound+6

sound_pointer	.word 0


	.proc sound_init
	jsr sound_reset	
	jsr sound_start
	rts
	.endp

	.proc sound_reset
	ldx #8
	lda #0
?1	sta $d200,x
	dex
	bpl ?1
	lda #3
	sta $d30f
	rts
	.endp

	.proc sound_start
	ldx sound_pointer
	ldy sound_pointer+1
	lda #$70	;Init code
	jsr sound_set

	lda #$00	;Set song code
	tax		;First song.
	ldx #0
	jsr sound_set
	rts
	.endp

	.proc sound_stop
	lda #$40	;stop code
	jsr sound_set
	rts
	.endp

