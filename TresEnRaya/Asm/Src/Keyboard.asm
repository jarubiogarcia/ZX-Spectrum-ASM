; -----------------------------------------------------------------------------
; Fichero: Keyboard.asm
;
; Rutinas del teclado.
; -----------------------------------------------------------------------------

; -----------------------------------------------------------------------------
; Espera a que se pulse una tecla y devuelve su código Ascii.
;
; Salida: A -> Código Ascii de la tecla.
;
; Altera el valor de los registros AF y HL.
; -----------------------------------------------------------------------------
WaitKeyAlpha:
	ld	hl, FLAGS_KEY		; Carga en HL la dirección a los flag del teclado.
	set	$03, (hl)		; Asigna entrada en modo L.

; Bucle hasta que se obtenga una tecla.
WaitKeyAlpha_loop:
	bit	$05, (hl)		; Comprueba si se ha pulsado una tecla.
	jr	z, WaitKeyAlpha_loop	; Si no se ha pulsado, vuelve al bucle.
	res	$05, (hl)		; Es necesario poner el bit a 0 para futuras inspecciones.

; Obtiene el Ascii de la tecla pulsada.
; Ascii válidos 12 ($0C), 13 ($0D) y de 32 ($20) a 127 ($7F).
; Si la tecla pulsada es Space, cargar ' ' en A.
WaitKeyAlpha_loadKey:
	ld	hl, LAST_KEY		; Carga en HL la dirección a la variable de la última tecla pulsada.
	ld	a, (hl)			; Carga en A la última tecla pulsada.	

	cp	$80			; Si es un código Ascii mayor de 127
	jr	nc, WaitKeyAlpha	; tecla no válida y vuelve a esperar.

	cp	KEYDEL			; Comprueba si la tecla pulsada es Delete
	ret	z			; y si es así, retorna.

	cp	KEYENT			; Comprueba si la tecla pulsada es Enter
	ret	z			; y si es así, retorna.

	cp	KEYSPC			; Si la tecla pulsada es menor que Space
	jr	c, WaitKeyAlpha		; tecla no válida y vuelve a esperar.
	ret	nz			; Si no es Space retorna.
	ld	a, ' '			; Si es Space, carga Espacio en A
	ret				; y retorna.

; -----------------------------------------------------------------------------
; Espera a que se pulse alguna tecla del tablero.
; Durante el juego se activan las interrupciones para poder realizar la
; cuenta atrás. Con las interrupciones activadas no se actualizan ni FLAGS_KEY,
; ni LAST_KEY. Por eso es necesaria esta rutina, para leer pulsaciones del teclado.
;
; Salida:	A	->	Tecla pulsada.
;
; Altera el valor de los registros AF y BC.
; -----------------------------------------------------------------------------
WaitKeyBoard:
	ld	a, $f7
	in	a, ($fe)		; Lee la semifila $f7 (1 al 5).

	cpl				; Invierte los bits para que las teclas pulsadas se pongan a 1.
	and	$1F			; Se queda con los 5 bits de las teclas (0-4).
	jr	z, WaitKeyBoard_6	; Si es cero, no se ha pulsado ninguna tecla y salta a leer la semifila $ef (0 al 6).

	bit	$00, a			; Evalúa si se ha pulsado el 1. 
	jr	z, WaitKeyBoard_2	; Si no es así comprueba la siguiente.

	; Se ha pulsado el 1.
	ld	a, KEY1			; Carga el valor correspondiente.

	ret				; Sale.

WaitKeyBoard_2:
	bit	$01, a			; Evalúa si se ha pulsado el 2.
	jr	z, WaitKeyBoard_3	; Si no es así comprueba la siguiente.

	ld	a, KEY2			; Se ha pulsado el 2, carga el valor correspondiente.

	ret				; Sale.

WaitKeyBoard_3:
	bit	$02, a			; Evalúa si se ha pulsado el 3.
	jr	z, WaitKeyBoard_4	; Si no es así comprueba la siguiente.

	ld	a, KEY3			; Se ha pulsado el 3, carga el valor correspondiente.
	
	ret				; Sale.

WaitKeyBoard_4:
	bit	$03, a			; Evalúa si se ha pulsado el 4.
	jr	z, WaitKeyBoard_5	; Si no es así comprueba la siguiente.

	ld	a, KEY4			; Se ha pulsado el 4, carga el valor correspondiente.
	
	ret				; Sale.

WaitKeyBoard_5:
	bit	$04, a			; Evalúa si se ha pulsado el 5.
	jr	z, WaitKeyBoard_6	; Si no es así comprueba la siguiente.

	ld	a, KEY5			; Se ha pulsado el 5, carga el valor correspondiente.
	
	ret				; Sale.

WaitKeyBoard_6:
	ld	a, $ef
	in	a, ($fe)		; Lee la semifila $ef (0 al 6).

	cpl				; Invierte los bits para que las teclas pulsadas se pongan a 1.

	and	$1F			; Se queda con los 5 bits de las teclas (0-4).
	jr	z, WaitKeyBoard_noKey	; Si es cero, no se ha pulsado ninguna tecla y vuelve a leer el teclado.

	bit	$04, a			; Evalúa si se ha pulsado el 6.
	jr	z, WaitKeyBoard_7	; Si no es así comprueba la siguiente.

	ld	a, KEY6			; Se ha pulsado el 6, carga el valor correspondiente.
	
	ret				; Sale.

WaitKeyBoard_7:
	bit	$03, a			; Evalúa si se ha pulsado el 7.
	jr	z, WaitKeyBoard_8	; Si no es así comprueba la siguiente.

	ld	a, KEY7			; Se ha pulsado el 7, carga el valor correspondiente.
	
	ret				; Sale.

WaitKeyBoard_8:
	bit	$02, a			; Evalúa si se ha pulsado el 8.
	jr	z, WaitKeyBoard_9	; Si no es así comprueba la siguiente.

	ld	a, KEY8			; Se ha pulsado el 8, carga el valor correspondiente.
	
	ret				; Sale.

WaitKeyBoard_9:
	bit	$01, a			; Evalúa si se ha pulsado el 9.
	jr	z, WaitKeyBoard		; Si no es así vuelve a leer el teclado.

	ld	a, KEY9			; Se ha pulsado el 9, carga el valor correspondiente.
	
	ret				; Sale.

WaitKeyBoard_noKey:
	ld	a, $00			; No se ha pulsado ninguna tecla.

	ret

; -----------------------------------------------------------------------------
; Espera que haya alguna tecla pulsada.
;
; Altera el valor del registro A.
; -----------------------------------------------------------------------------
WaitKeyPressed:
	xor	a			; Pone A a 0 para leer todas las teclas.
	in	a, ($fe)		; Lee todas la teclas.

	or	$e0			; Pone los 3 bits más significativos a 1.
					; Los bits 0 a 5, si hay teclas pulsadas vienen a 0.

	inc	a			; Si no hay ninguna tecla pulsada A = $FF al incrementar A = $00.
	jr	z, WaitKeyPressed	; Bucle hasta que se pulse una tecla.

	ret

; -----------------------------------------------------------------------------
; Espera que no haya ninguna tecla pulsada.
;
; Altera el valor del registro A.
; -----------------------------------------------------------------------------
WaitKeyReleased:
	xor	a			; Pone A a 0 para leer todas las teclas.
	in	a, ($fe)		; Lee todas la teclas.

	or	$e0			; Pone los 3 bits más significativos a 1.
					; Los bits 0 a 5, si hay teclas pulsadas vienen a 0.

	inc	a			; Si no hay ninguna tecla pulsada A = $FF al incrementar A = $00.
	jr	nz, WaitKeyReleased	; Bucle hasta que no haya ninguna tecla pulsada.

	ret