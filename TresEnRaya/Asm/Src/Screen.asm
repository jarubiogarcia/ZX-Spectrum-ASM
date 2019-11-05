; -----------------------------------------------------------------------------
; Fichero: Screen.asm.
;
; Constanes y rutinas de la pantalla y la VideoRam.
; -----------------------------------------------------------------------------

; -----------------------------------------------------------------------------
; Constantes.
; -----------------------------------------------------------------------------
; Coordenadas X e Y de inicio (PLOT)
COORDX:		equ $5c7d
COORDY:		equ $5c7e

; Posición Y = 0 para LOCATE.
INI_TOP:	equ $18

; Posición X = 0 para LOCATE.
INI_LEFT:	equ $21

; Posiciones donde se pintan los elementos de OXO.
POS1_TOP:	equ INI_TOP - $07
POS2_TOP:	equ POS1_TOP - $05
POS3_TOP:	equ POS2_TOP - $05

POS1_LEFT:	equ INI_LEFT - $0a
POS2_LEFT:	equ POS1_LEFT - $05
POS3_LEFT:	equ POS2_LEFT - $05

; -----------------------------------------------------------------------------
; Rellena el área de atributos de la VideoRAM con el atributo especificado.
;
; Entrada: A -> Atributo especificado.
;	Bits 0-2	Color de tinta (0-7).
;	Bits 3-5	Color de papel (0-7).
;	Bit 6		Brillo (0/1).
;	Bit 7		Parpadeo (0/1).
;
; Altera el valor de los registros BC, DE y HL.
; -----------------------------------------------------------------------------
ClearAttributes:
	ld hl, VIDEOATTR	; Carga en HL la primera dirección del área de atributos de la VideoRAM
	ld (hl), a		; Carga el atributo en memoria.

	ld de, VIDEOATTR+1	; Carga en DE la segunda dirección del área de atributos de la VideoRAM.
	ld bc, VIDEOATTR_L-1	; Carga en BC el número de direcciones a copiar.

	ldir			; Copia de HL a DE las veces que tenga BC.

	ld (ATTR_T), a		; Carga el atributo en la variable de sistema de atributo actual
	ld (BORDCR), a		; y en la variable del border, que se usa para la pantalla 2 al volver a BASIC.

	ret

; -----------------------------------------------------------------------------
; Borra la línea de patalla especificada.
;
; Entrada: B -> Línea de pantalla a borrar.
;
; Altera el valor de los registros AF, C y HL.
; -----------------------------------------------------------------------------
ClearLine:
	push 	bc			; Preserva el valor del registro BC.
	
	ld	c, INI_LEFT		; Carga en C la primera columna.
	call	SetCursorPosition	; Posiciona el cursor.
	ld	b, $20			; 32 columnas en la línea.
ClearLine_loop:
	ld	a, ' '		
	rst	$10			; Imprime un espacio.
	djnz	ClearLine_loop		; Hasta que B sea 0.
	
	pop 	bc			; Recupera el valor del registro BC.

	ret

; -----------------------------------------------------------------------------
; Rellena la pantalla con el patrón especificado en A.
;
; Entrada: A -> Patrón con el que se rellena la pantalla.
;
; Altera el valor de los registros BC, DE y HL.
; -----------------------------------------------------------------------------
ClearScreen:
	ld hl, VIDEORAM		; Carga en HL la primera dirección del área gráfica de la VideoRAM.
	ld (hl), a		; Carga el patrón en memoria.

	ld de, VIDEORAM+1	; Carga en DE la segunda dirección del área gráfica de la VideoRAM.
	ld bc, VIDEORAM_L-1	; Carga en BC el número de direcciones a copiar.

	ldir			; Copia de HL a DE las veces que tenga BC.

	ret

; -----------------------------------------------------------------------------
; Imprime el valor de números BCD.
;
; Versión simplificada porque solo se van a imprimir números del 0 al 99.
;
; Entrada: HL -> Puntero al número a imprimir.
;
; Altera el valor del registro AF.
; -----------------------------------------------------------------------------
PrintBCD:
	ld a, (hl)		; Carga en A el número a imprimir.
	and $f0			; Se queda con las decenas.
	rrca
	rrca
	rrca
	rrca			; Rota para que los bits 4, 5, 6 y 7 pasen a 0, 1, 2 y 3.

	or a			; Si la decena es 0, imprime espacio. A = 0 solo si A = 0.
	jr nz, PrintBCD_ascii	; Salta si la decena no es 0.
	ld a, ' '
	jr PrintBCD_continue	; Imprime un espacio.

PrintBCD_ascii:
	add a, '0'		; Agrega el código Ascii del 0 para calcular el código Ascii del número.

PrintBCD_continue:
	rst $10			; Imprime el primer dígito.

	ld a, (hl)		; Vuelve a cargar el número a imprimir.
	and $0f			; Se queda con las unidades.

	add a, '0'		; Agrega el código Ascii del 0 para calcular el código Ascii del número.
	rst $10			; Imprime el segundo dígito.

	ret

; -----------------------------------------------------------------------------
; Pinta el tablero.
;
; Altera el valor de los registros AF, BC, D y HL.
; -----------------------------------------------------------------------------
PrintBoard:
	ld	a, $04
	call	SetInk			; Pone la tinta en verde.

	; Coordenadas iniciales del tablero.
	ld	b, INI_TOP - $05	; Asigna la coordenada Y.
	ld	c, INI_LEFT - $09	; Asigna la coordenada X.
	ld	d, $0e			; Número de líneas de tablero.

PrintBoard_1:
	dec	b			; Decrementa b para colocarlo en la coordenada inicial real.
	call	SetCursorPosition	; Posiciona el cursor.

	ld	hl, Board_1
	call	PrintString		; Pinta la línea con la que se forman las líneas verticales.

	dec	d
	jr	nz, PrintBoard_1	; Repite hasta que D = 0.

PrintBoard_2:
	; Coodenadas de la primera línea horizontal.
	ld	b, INI_TOP - $0a	; Asigna la coordenada Y.
	ld	c, INI_LEFT - $09	; Asigna la coordenada X.
	call	SetCursorPosition	; Posiciona el cursor.
	ld	hl, Board_2
	call	PrintString		; Pinta la línea horizontal.

	; Coodenadas de la segunda línea horizontal. La coordenada X no cambia.
	ld	b, INI_TOP - $0f	; Asigna la coordenada Y.
	call	SetCursorPosition	; Posiciona el cursor.
	ld	hl, Board_2
	call	PrintString		; Pinta la línea horizontal.

PrintBoard_3:
	; Pinta los números de guía para que el usuario sepa que tecla pulsar
	; para poner las fichas (O X O).

	ld	a, $03
	call	SetInk			; Pone la tinta en magenta.

	ld	b, POS1_TOP		; Asigna la coordenada Y.
	ld	c, POS1_LEFT		; Asigna la coordenada X.
	call	SetCursorPosition	; Posiciona el cursor.
	ld	a, "1"
	rst	$10			; Imprime el 1.

	ld	c, POS2_LEFT		; Asigna la coordenada X.
	call	SetCursorPosition	; Posiciona el cursor.
	ld	a, "2"
	rst	$10			; Imprime el 2.

	ld	c, POS3_LEFT		; Asigna la coordenada X.
	call	SetCursorPosition	; Posiciona el cursor.
	ld	a, "3"
	rst	$10			; Imprime el 3.

	ld	b, POS2_TOP		; Asigna la coordenada Y.
	call	SetCursorPosition	; Posiciona el cursor.
	ld	a, "6"
	rst	$10			; Imprime el 6.

	ld	c, POS2_LEFT		; Asigna la coordenada X.
	call	SetCursorPosition	; Posiciona el cursor.
	ld	a, "5"
	rst	$10			; Imprime el 5.

	ld	c, POS1_LEFT		; Asigna la coordenada X.
	call	SetCursorPosition	; Posiciona el cursor.
	ld	a, "4"
	rst	$10			; Imprime el 5.

	ld	b, POS3_TOP		; Asigna la coordenada Y.
	call	SetCursorPosition	; Posiciona el cursor.
	ld	a, "7"
	rst	$10			; Imprime el 7.

	ld	c, POS2_LEFT		; Asigna la coordenada X.
	call	SetCursorPosition	; Posiciona el cursor.
	ld	a, "8"
	rst	$10			; Imprime el 8.

	ld	c, POS3_LEFT		; Asigna la coordenada X.
	call	SetCursorPosition	; Posiciona el cursor.
	ld	a, "9"
	rst	$10			; Imprime el 9.

	ret

; -----------------------------------------------------------------------------
; Imprime la cuenta atrás.
;
; Altera el valor de los registros AF, BC y HL.
; -----------------------------------------------------------------------------
PrintCountDown:
	ld	a, $03
	call	SetInk			; Pone la tinta en magenta.

	ld	b, INI_TOP-$0c		; Asigna la coordenada Y.
	ld	c, INI_LEFT		; Asigna la coordenada X.
	call	SetCursorPosition	; Posiciona el cursor.
	ld	hl, CountDown
	call	PrintBCD		; Imprime imprime la cuenta atrás.

	ld	c, INI_LEFT-$1d		; Asigna la coordenada X.
	call	SetCursorPosition	; Posiciona el cursor.
	ld	hl, CountDown
	call	PrintBCD		; Imprime imprime la cuenta atrás.

	ret

; -----------------------------------------------------------------------------
; Imprime el nombre del jugador del turno actual.
;
; Altera el valor de los registros AF, BC y HL.
; -----------------------------------------------------------------------------
PrintCurrentPlayer:
	call	GetCurrentPlayerInk		; Obtiene la tinta para el jugador actual.
	or	$60				; Le añade brillo.
	call	SetInk				; Asigna la tinta.

	ld	b, INI_TOP-$15			; Asigna la coordenada Y.
	call	ClearLine			; Limpia la línea.

	ld	c, INI_LEFT-$06			; Asigan la coordenada X.
	call	SetCursorPosition		; Posiciona el cursor.

	ld	hl, TitleTurn
	call	PrintString			; Imprime el mensaje de turno.

	ld	c, INI_LEFT-$11			; Asigan la coordenada X.
	call	SetCursorPosition		; Posiciona el cursor

	ld	l, $01				; El jugador a obtener es el actual.
	call	GetPlayerName			; Obtiene el puntero al nombre del jugador actual.
	call	PrintString			; Imprime el nombre del jugador.

	ld	a, $01
	call	SetInk				; Asigna la tinta para quitar el brillo.

	ret

; -----------------------------------------------------------------------------
; Imprime el mensaje de casilla ocupada.
;
; Altera el valor de los registros AF, BC y HL.
; -----------------------------------------------------------------------------
PrintError:
	ld	b, INI_TOP-$15			; Asigna la coordenada Y.
	call	ClearLine			; Limpia la línea.

	ld	c, INI_LEFT-$08			; Asigan la coordenada X.
	call	SetCursorPosition		; Posiciona el cursor.

	ld	a, $c2
	call	SetInk				; Asigna la tinta.
	
	ld	hl, TitleError
	call	PrintString			; Imprime el mensaje de turno.

	ld	a, $02
	call	SetInk				; Asigna la tinta para quitar el brillo y parpadeo.

	ret

; -----------------------------------------------------------------------------
; Imprime el literal de fin de partida.
;
; Altera el valor de los registros AF, BC y HL.
; -----------------------------------------------------------------------------
PrintGameOver:
	ld	b, INI_TOP-$15		; Asigna la coordenada Y.
	call	ClearLine		; Limpia la línea.

	ld	c, INI_LEFT-$07		; Asigna la coordenada X.
	call	SetCursorPosition	; Posiciona el cursor.

	ld	a, $C7
	call	SetInk			; Asigna la tinta. Blanco con brillo y parpadeo.

	ld	hl, TitleGameOver
	call	PrintString		; Imprime el mensaje partida finalizada.

	ld	a, $07
	call	SetInk			; Asigna la tinta. Banco sin brillo, ni parpadeo.

	ret

; -----------------------------------------------------------------------------
; Imprime pierde turno.
;
; Altera el valor de los registros AF, BC y HL.
; -----------------------------------------------------------------------------
PrintLostMovement:
	ld	b, INI_TOP-$15
	call	ClearLine		; Limpia la línea.

	ld	c, INI_LEFT-$06
	call	SetCursorPosition	; Posiciona el cursor.

	ld	a, INKWARNING
	call	SetInk			; Asigna la tinta. Rojo brillante con flash.

	ld	l, $00			; El jugador a obtener es el anterior.
	call	GetPlayerName		; Obtiene el nombre del jugador anterior.
	call	PrintString		; Imprime el nombre del jugador.

	ld	hl, TitleLostMovement
	call	PrintString		; Imprime el mensaje pierde movimiento.

	ld	a, $02
	call	SetInk			; Asigna la tinta. Rojo.

	ret

; -----------------------------------------------------------------------------
; Imprime O o X dependiendo de jugador.
;
; Entrada: A -> Tecla pulsada.
;
; Altera el valor del registro AF.
; -----------------------------------------------------------------------------
PrintOXO:
	ld	b, POS1_TOP		; Asigna la coordenada Y.

	cp	KEY1			; Evalúa si se ha pulsado el 1.
	jr	nz, PrintOXO_key2	; Si no es así salta.

	ld	c, POS1_LEFT		; Asigna la coordenada X.
	jr	PrintOXO_continue	; Salta para imprimir la figura.

PrintOXO_key2:
	cp	KEY2			; Evalúa si se ha pulsado el 2.
	jr	nz, PrintOXO_key3	; Si no es así salta.
	
	ld	c, POS2_LEFT		; Asigna la coordenada X.
	jr	PrintOXO_continue	; Salta para imprimir la figura.

PrintOXO_key3:
	cp	KEY3			; Evalúa si se ha pulsado el 3.
	jr	nz, PrintOXO_key4	; Si no es así salta.

	ld	c, POS3_LEFT		; Asigna la coordenada X.
	jr	PrintOXO_continue	; Salta para imprimir la figura.

PrintOXO_key4:
	ld	b, POS2_TOP		; Asigna la coordenada Y.

	cp	KEY4			; Evalúa si se ha pulsado el 4.
	jr	nz, PrintOXO_key5	; Si no es así salta.

	ld	c, POS1_LEFT		; Asigna la coordenada X.
	jr	PrintOXO_continue	; Salta para imprimir la figura.

PrintOXO_key5:
	cp	KEY5			; Evalúa si se ha pulsado el 5.
	jr	nz, PrintOXO_key6	; Si no es así salta.

	ld	c, POS2_LEFT		; Asigna la coordenada X.
	jr	PrintOXO_continue	; Salta para imprimir la figura.

PrintOXO_key6:
	cp	KEY6			; Evalúa si se ha pulsado el 6.
	jr	nz, PrintOXO_key7	; Si no es así salta.

	ld	c, POS3_LEFT		; Asigna la coordenada X.
	jr	PrintOXO_continue	; Salta para imprimir la figura.

PrintOXO_key7:
	ld	b, POS3_TOP		; Asigna la coordenada Y.

	cp	KEY7			; Evalúa si se ha pulsado el 7.
	jr	nz, PrintOXO_key8	; Si no es así salta.

	ld	c, POS1_LEFT		; Asigna la coordenada X.
	jr	PrintOXO_continue	; Salta para imprimir la figura.

PrintOXO_key8:
	cp	KEY8			; Evalúa si se ha pulsado el 8.
	jr	nz, PrintOXO_key9	; Si no es así salta.

	ld	c, POS2_LEFT		; Asigna la coordenada X.
	jr	PrintOXO_continue	; Salta para imprimir la figura.

PrintOXO_key9:
	ld	c, POS3_LEFT		; Asigna la coordenada X.

PrintOXO_continue:
	ld	a, (CurrentPlayerMov)	; Obtiene el jugador y los movimientos.
	and	$01			; Evalúa si es el jugador 1.
	jr	nz, PrintX		; Si el el jugador 1, salta.

; -----------------------------------------------------------------------------
; Imprime la O en las coordenadas proporcionadas.
; 
; Entrada: BC -> Coordenadas Y / X
;
; Altera el valor de los registros AF, BC y HL.
; -----------------------------------------------------------------------------
PrintO:
	push	bc			; Preserva el valor de BC porque SetInk lo altera.

	ld	a, INKPLAYER2		; Obtiene la tinta del jugador 2.
	call	SetInk			; Asigna la tinta.

	pop	bc			; Recupera el valor de BC.

	call	SetCursorPosition	; Posiciona el cursor.

	; Imprime la O.
	ld	a, $92
	rst	$10			; Esquina superior izquierda.

	ld	a, $93
	rst	$10			; Esquina superior derecha.

	dec	b			; Baja una línea.
	call	SetCursorPosition	; Posiciona el cursor.
	ld	a, $94
	rst	$10			; Esquina inferior izquierda.

	ld	a, $95
	rst	$10			; Esquina inferior derecha.

	ret

; -----------------------------------------------------------------------------
; Imprime la X en las coordenadas proporcionadas.
; 
; Entrada: BC -> Coordenadas Y / X.
;
; Altera el valor de los registros AF, BC y HL.
; -----------------------------------------------------------------------------
PrintX:
	push	bc			; Preserva el valor de BC porque SetInk lo altera.

	ld	a, INKPLAYER1		; Obtiene la tinta del jugador 1.
	call	SetInk			; Asigna la tinta.

	pop	bc			; Recupera el valor de BC.

	call	SetCursorPosition	; Posiciona el cursor.

	; Imprime la X.
	ld	a, $90
	rst	$10			; Esquina superior izquierda.

	ld	a, $91
	rst	$10			; Esquina superior derecha.

	dec	b			; Baja una línea.
	call	SetCursorPosition	; Posiciona el cursor.
	ld	a, $91
	rst	$10			; Esquina inferior izquierda.

	ld	a, $90
	rst	$10			; Esquina inferior derecha.

	ret

; -----------------------------------------------------------------------------
; Imprime el marcador.
;
; Altera el valor de los registros AF, BC y HL.
; -----------------------------------------------------------------------------
PrintPoints:
	ld	a, INKPLAYER1
	call	SetInk			; Asigna la tinta del jugador 1.

	; Posiciona el cursor e imprime los puntos del jugador 1.
	ld	b, INI_TOP - $04	; Asigna la coordenada Y.
	ld	c, INI_LEFT - $03	; Asigna la coordenada X.
	call	SetCursorPosition	; Posiciona el cursor.
	ld	hl, PointsPlayer1
	call	PrintBCD		; Imprime los puntos del jugador 1.

	; Cambia el color.
	ld	a, INKTIE
	call	SetInk			; Asigna la tinta de las tablas.

	; Posiciona el cursor e imprime las tablas.
	ld	b, INI_TOP - $04	; Asigna la coordenada Y.
	ld	c, INI_LEFT - $0f	; Asigna la coordenada X.
	call	SetCursorPosition	; Posiciona el cursor.
	ld	hl, PointsTie
	call	PrintBCD		; Imprime los puntos de las tablas.

	ld	a, INKPLAYER2
	call	SetInk			; Asigna la tinta del jugador 1.

	; Posiciona el cursor e imprime los puntos del jugador 2.
	ld	b, INI_TOP - $04	; Asigna la coordenada Y.
	ld	c, INI_LEFT - $1b	; Asigna la coordenada X.
	call	SetCursorPosition	; Posiciona el cursor.
	ld	hl, PointsPlayer2
	call	PrintBCD		; Imprime los puntos de las tablas.

	ret

; -----------------------------------------------------------------------------
; Imprime cadenas terminadas en null (0).
;
; Entrada: HL -> Primera dirección de memoria de la cadena.
;
; Altera el valor de los registros AF y HL.
; -----------------------------------------------------------------------------
PrintString:
	ld a, (hl)	; Carga en A el valor de la dirección de memoria que apunta
			; a un carácter de la cadena.
	or a		; Comprueba si el carácter es 0 (null).
	ret z		; Si es 0, fin de la cadena. Sale.

	rst $10		; Imprime el carácter.

	inc hl		; Avanza a la dirección de memoria del siguiente carácter.

	jr PrintString	; Siguiente iteración del bucle.

; -----------------------------------------------------------------------------
; Imprime el nombre del jugador que gana.
;
; Altera el valor de los registros AF, BC y HL.
; -----------------------------------------------------------------------------
PrintTie:
	ld	b, INI_TOP-$15		; Asigna la coordenada Y.
	call	ClearLine		; Limpia la línea.

	ld	c, INI_LEFT-$0d		; Asigan la coordenada X.
	call	SetCursorPosition	; Posiciona el cursor.

	ld	a, INKWARNING
	call	SetInk			; Asigna la tinta.

	ld	hl, TitleTie
	call	PrintString		; Imprime el mensaje de tablas.

	ld	a, $02
	call	SetInk			; Asigna la tinta para quitar brillo y parpadeo.

	ret

; -----------------------------------------------------------------------------
; Imprime el nombre del jugador que gana.
;
; Altera el valor de los registros AF, BC y HL.
; -----------------------------------------------------------------------------
PrintWinner:
	ld	b, INI_TOP-$15			; Asigna la coordenada Y.
	call	ClearLine			; Limpia la línea.

	call	GetCurrentPlayerInk		; Obtiene la tinta del jugador actual.
	or	$c0				; Asigna brillo y parpadeo.
	call	SetInk				; Asigna la tinta.

	ld	b, INI_TOP-$15			; Asigna la coordenada Y. SetInk destruye BC.
	ld	c, INI_LEFT-$07			; Asigna la coordenada X.
	call	SetCursorPosition		; Posiciona el cursor.

	ld	hl, TitlePointFor
	call	PrintString			; Imprime el mensaje de punto para.

	ld	c, INI_LEFT-$12			; Asigna la coordenada X.
	call	SetCursorPosition		; Posiciona el cursor

	; Imprime el nombre del jugador.
	ld	l, $01				; El nombre a obtener es el del jugador actual.
	call	GetPlayerName			; Obtiene el nombre del jugador.
	call	PrintString			; Imprime el nombre del jugador.

	ld	a, $01
	call	SetInk				; Asigna la tinta para quitar brillo y parpadeo.

	ret

; -----------------------------------------------------------------------------
; Imprime la línea ganadora.
;
; Altera el valor de los registros AF, BC, DE y HL.
; -----------------------------------------------------------------------------
PrintWinnerLine:
	cp	WINNERLINE357		; Comprueba su la línea ganadora es la 357.
	jr	z, PrintWinnerLine357	; Si es así, salta a pintarla.

	cp	WINNERLINE147		; Comprueba su la línea ganadora es la 147.
	jr	z, PrintWinnerLine147	; Si es así, salta a pintarla.

	cp	WINNERLINE258		; Comprueba su la línea ganadora es la 258.
	jr	z, PrintWinnerLine258	; Si es así, salta a pintarla.

	cp	WINNERLINE369		; Comprueba su la línea ganadora es la 369.
	jr	z, PrintWinnerLine369	; Si es así, salta a pintarla.

	cp	WINNERLINE123		; Comprueba su la línea ganadora es la 123.
	jr	z, PrintWinnerLine123	; Si es así, salta a pintarla.

	cp	WINNERLINE456		; Comprueba su la línea ganadora es la 456.
	jr	z, PrintWinnerLine456	; Si es así, salta a pintarla.

	cp	WINNERLINE789		; Comprueba su la línea ganadora es la 789.
	jr	z, PrintWinnerLine789	; Si es así, salta a pintarla.

PrintWinnerLine159:
	ld	hl, COORDX
	ld	(hl), $b7		; Asigna la coordenada X.
	inc	hl
	ld	(hl), $10		; Asigna la coordenada Y.

	ld	bc, $6c6c		; Asigna longitud de de Y y X.
	ld	de, $01ff		; Asigna orientación de Y y X.
	call	DRAW			; Pinta la línea.

	ret

PrintWinnerLine357:
	ld	hl, COORDX		; Asigna la coordenada X.
	ld	(hl), $48
	inc	hl
	ld	(hl), $10		; Asigna la coordenada Y.

	ld	bc, $6c6c		; Asigna longitud de de Y y X.
	ld	de, $0101		; Asigna orientación de Y y X.
	call	DRAW			; Pinta la línea.

	ret

PrintWinnerLine147:
	ld	hl, COORDX		; Asigna la coordenada X.
	ld	(hl), $58
	inc	hl
	ld	(hl), $10		; Asigna la coordenada Y.

	ld	bc, $6c00		; Asigna longitud de de Y y X.
	ld	de, $0101		; Asigna orientación de Y y X.
	call	DRAW			; Pinta la línea.

	ret

PrintWinnerLine258:
	ld	hl, COORDX		; Asigna la coordenada X.
	ld	(hl), $80
	inc	hl
	ld	(hl), $10		; Asigna la coordenada Y.

	ld	bc, $6c00		; Asigna longitud de de Y y X.
	ld	de, $0101		; Asigna orientación de Y y X.
	call	DRAW			; Pinta la línea.

	ret

PrintWinnerLine369:
	ld	hl, COORDX		; Asigna la coordenada X.
	ld	(hl), $a8
	inc	hl
	ld	(hl), $10		; Asigna la coordenada Y.

	ld	bc, $6c00		; Asigna longitud de de Y y X.
	ld	de, $0101		; Asigna orientación de Y y X.
	call	DRAW			; Pinta la línea.

	ret
	
PrintWinnerLine123:
	ld	hl, COORDX		; Asigna la coordenada X.
	ld	(hl), $48
	inc	hl
	ld	(hl), $70		; Asigna la coordenada Y.

	ld	bc, $006c		; Asigna longitud de de Y y X.
	ld	de, $0101		; Asigna orientación de Y y X.
	call	DRAW			; Pinta la línea.

	ret

PrintWinnerLine456:
	ld	hl, COORDX		; Asigna la coordenada X.
	ld	(hl), $48
	inc	hl
	ld	(hl), $47		; Asigna la coordenada Y.

	ld	bc, $006c		; Asigna longitud de de Y y X.
	ld	de, $0101		; Asigna orientación de Y y X.
	call	DRAW			; Pinta la línea.

	ret

PrintWinnerLine789:
	ld	hl, COORDX		; Asigna la coordenada X.
	ld	(hl), $48
	inc	hl
	ld	(hl), $20		; Asigna la coordenada Y.

	ld	bc, $006c		; Asigna longitud de de Y y X.
	ld	de, $0101		; Asigna orientación de Y y X.
	call	DRAW			; Pinta la línea.

	ret

; -----------------------------------------------------------------------------
; Canbia el color de borde.
;
; Entrada: A -> Color para el borde.
;
; Altera el valor de los registros AF y BC.
; -----------------------------------------------------------------------------
SetBorder:
	and 	$07		; Se queda solo con el color.
	out 	($fe), a	; Cambia el color del borde.

	rlca
	rlca
	rlca			; Rota tres bits a la izquierda para poner el color en los bits de paper/border.
	ld 	b, a		; Carga el valor en B.

	ld 	a, (BORDCR)	; Recupera la variable de sistema BORDCR.
	and 	$c7		; Desecha lo bits de paper/border.
	or 	b		; Agrega el color para el paper/border.

	ld 	(BORDCR), a	; Carga el valor en la variable de sistema BORDCR.
				; Si no se hace y se usa BEEPER, el borde se pone a 0 (negro).

	ret

; -----------------------------------------------------------------------------
; Posiciona el cursor. La esquina superior está en 24,33.
;
; Entrada: B ->	Y.
;	   C ->	X.
; -----------------------------------------------------------------------------
SetCursorPosition:
	push 	af
	push 	bc
	push 	de
	push 	hl		; Preserva el valor de los registros que altera la rutina LOCATE de la ROM.

	call 	LOCATE	; Posiciona el cursor.

	pop 	hl
	pop 	de
	pop 	bc
	pop 	af		; Recupera los valores de los registros.

	ret

; -----------------------------------------------------------------------------
; Asigna el color para la tinta.
;
; Entrada: A -> Color para la tinta.
;
; Altera el valor de los registros AF y BC.
; -----------------------------------------------------------------------------
SetInk:
	and 	$c7		; Se queda el parpadeo, brillo y tinta.
	ld 	b, a		; Lo carga en B.

	ld 	a, (ATTR_T)	; Recupera la variable de sistema del atributo actual.
	and 	$38		; Se queda con el fondo.

	or 	b		; Añade la tinta, brillo y parpadeo.
	ld 	(ATTR_T), a	; Carga el valor en memoria.

	ret

; -----------------------------------------------------------------------------
; Asigna el color para el fondo.
;
; Entrada: A -> Color para el fondo.
;
; Altera el valor de los registros AF y BC.
; -----------------------------------------------------------------------------
SetPaper:
	and 	$07		; Se queda con el color.
	rlca
	rlca
	rlca			; Rota tres bits a la izquierda para poner el color en bits de paper/border.
	ld 	b, a		; Carga el valor en B.

	ld	 a, (ATTR_T)	; Recupera la variable de sistema del atributo actual.
	and 	$c7		; Desecha el fondo.

	or 	b		; Agrega el fondo especificado el papel.
	ld 	(ATTR_T), a	; Carga el valor en memoria.

	ret