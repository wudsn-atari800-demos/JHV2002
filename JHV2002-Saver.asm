;	Copy $2000 bytes to the RAM under the OS

start
	sei
	lda #0
	sta $d40e
	sta $d20e
	lda $d40b
	bne *-3
	sta $d400
	lda #$3c
	sta $d303
	lda #$fe
	sta $d301

	mwa #saver_data p1	
	mwa #$e000 p2
	ldx #$20
	ldy #0
saver_copy
	lda (p1),y
	sta (p2),y
	iny
	bne saver_copy
	inc p1+1
	inc p2+1
	dex
	bne saver_copy


	lda #$ff
	sta $d301
	lda #$40
	sta $d40e
	cli
	clc
	rts

saver_data
	ins "JHV2002-Main-Lokas18-$0500-$24ff.bin"

