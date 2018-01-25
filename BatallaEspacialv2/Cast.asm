; -----------------------------------------------------------------------------
; Cast.asm
;
; Archivo que contiene rutinas de conversión.
; -----------------------------------------------------------------------------

BCD2bin:
	; Preserva el valor de los registros
	PUSH BC

	LD	C,A
	AND	0F0H
	SRL	A
	LD	B,A
	SRL	A
	SRL	A
	ADD	A,B
	LD	B,A
	LD	A,C
	AND	0FH
	ADD	A,B

	; Recupera el valor de los registros
	POP	BC

	RET