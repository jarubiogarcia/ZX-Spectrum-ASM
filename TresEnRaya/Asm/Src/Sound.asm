; -----------------------------------------------------------------------------
; Fichero: Sound.asm
;
; Sonidos del programa.
; -----------------------------------------------------------------------------

; -----------------------------------------------------------------------------
; Reproduce una melodía.
;
; Entrada: BC = Dirección de inicio de la melodía.
;
; Para ahorrar bytes, se hace byte a byte y la duración siempre se semifusa
; o fusa, para que solo se necesite un byte. Esta rutina está adaptada para
; este funcionamiento.
; -----------------------------------------------------------------------------
PlayMusic:
	push	af			; Preserva el valor de los registros.
	push	bc
	push	de
	push	hl
	push	ix

playMusic_loop:
	ld	a, (bc)			; Carga en A el byte alto de la nota.
	ld	h, a			; Carga en valor en H.
	or	a			; Comprueba si el valor es 0.
	jr	z, playMusic_end	; Si el valor es 0 salta, ha llegado al fin.

	inc	bc			; Apunta BC al siguiente valor.
	ld	a, (bc)			; Carga en A el byte bajo de la nota.
	ld	l, a			; Carga el valor en L.

	inc	bc			; Apunta BC al siguiente valor.
	ld	a, (bc)			; Carga en A la duración de la nota.
	ld	e, a			; Carga el valor en E.
	ld	d, $00			; Pone D a 0.
	inc	bc			; Apunta BC al siguiente valor.

	push	bc			; Preserva BC.
	call	BEEPER			; Reproduce la nota.
	pop	bc			; Recupera BC.

	jr	playMusic_loop		; Bucle hasta que se llegue al 0 que marca el fin de la melodía.

playMusic_end:
	pop	ix			; Restaura el valor de los registros.
	pop	hl
	pop	de
	pop	bc
	pop	af

	ret