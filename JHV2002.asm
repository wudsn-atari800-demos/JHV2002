;
;	>> Abbuc JHV 2002 Intro <<
;	(c) JAC! on 20.10.2002
;

x1	= $e0	;temporaries
x2	= $e1
x3	= $e2
x4	= $e4
x5	= $e5

p1	= $f0	;general_pointers
p2	= $f2
p3	= $f4

cnt	= $14	;general_counter

	org $2000

	.proc fade
	icl "JHV2002-Fade.asm"
	.endp
	ini fade.start

	org $4000
	.proc devil
	icl "JHV2002-Devil.asm"
	.endp

	ini devil.start

;	org $2000
;
;	.proc saver
;	icl "JHV2002-Saver.asm"
;	.endp
;
;	ini saver.start
;	
;	.proc main
;	icl "JHV2002-Main.asm"
;	.endp
;
;	ini main.start

