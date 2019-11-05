; -----------------------------------------------------------------------------
; Cast.asm
;
; Archivo que contiene rutinas de conversión.
; -----------------------------------------------------------------------------

; -----------------------------------------------------------------------------
; Convierte números BCD a binario. Se explica en código con un ejemplo
; https://www.msx.org/forum/development/msx-development/bcdhex-conversion-asm
;
; Entrada: A -> Número BCD a convertir.
;
; Salida:  A -> Número binario resultante.
; -----------------------------------------------------------------------------
BCD2bin:
	; Preserva el valor de los registros
	PUSH BC

					; Suponemos que A vale $69 (HEX) en BCD
	LD	C, A			; C = $69
	AND	$F0			; Se queda con los bits 4, 5, 6 y 7. A = $60
	SRL	A			; Desplaza A a derecha. A = $30
	LD	B, A			; Deja ese valor en B. B = $30
	SRL	A			; Desplaza A a derecha. A = $18
	SRL	A			; Desplaza A a derecha. A = $0C
	ADD	A, B			; Suma B = $30 a A. A = $3C
	LD	B, A			; Carga el valor en B. B = $3C
	LD	A, C			; Carga el valor original en A. A = $69	
	AND	$0F			; Se queda con los bits 0, 1, 2 y 3. A = $09.
	ADD	A, B			; Suma B = $3C a A. A = $45 = 69 decimal.
					; $69 BCD se ha convertido en 69 decimal.

	; Recupera el valor de los registros
	POP	BC

	RET