; -----------------------------------------------------------------------------
; Fichero: Logical.asm
;
; Lógica del juego.
; -----------------------------------------------------------------------------

; -----------------------------------------------------------------------------
; Comprueba si la casilla 1 está libre.
;
; Salida: Z si está libre.
;	  A -> Código ascii del 1.
;
; Altera el valor del registro AF.
; -----------------------------------------------------------------------------
CheckFree1:
	ld	a, (Grid)	; Carga en A el valor del cuadro 1.
	or	a		; Comprueba si está ocupado.
	ld	a, '1'		; Carga el Ascii 1 en A.
	
	ret

; -----------------------------------------------------------------------------
; Comprueba si la casilla 2 está libre.
;
; Salida: Z si está libre.
;	  A -> Código ascii del 2.
;
; Altera el valor del registro AF.
; -----------------------------------------------------------------------------
CheckFree2:
	ld	a, (Grid+$01)	; Carga en A el valor del cuadro 2.
	or	a		; Comprueba si está ocupado.
	ld	a, '2'		; Carga el Ascii 2 en A.
	
	ret

; -----------------------------------------------------------------------------
; Comprueba si la casilla 3 está libre.
;
; Salida: Z si está libre.
;	  A -> Código ascii del 3.
;
; Altera el valor del registro AF.
; -----------------------------------------------------------------------------
CheckFree3:
	ld	a, (Grid+$02)	; Carga en A el valor del cuadro 3.
	or	a		; Comprueba si está ocupado.
	ld	a, '3'		; Carga el Ascii 3 en A.
	
	ret

; -----------------------------------------------------------------------------
; Comprueba si la casilla 4 está libre.
;
; Salida: Z si está libre.
;	  A -> Código ascii del 4.
;
; Altera el valor del registro AF.
; -----------------------------------------------------------------------------
CheckFree4:
	ld	a, (Grid+$03)	; Carga en A el valor del cuadro 4.
	or	a		; Comprueba si está ocupado.
	ld	a, '4'		; Carga el Ascii 4 en A.
	
	ret

; -----------------------------------------------------------------------------
; Comprueba si la casilla 5 está libre.
;
; Salida: Z si está libre.
;	  A -> Código ascii del 5.
;
; Altera el valor del registro AF.
; -----------------------------------------------------------------------------
CheckFree5:
	ld	a, (Grid+$04)	; Carga en A el valor del cuadro 5.
	or	a		; Comprueba si está ocupado.
	ld	a, '5'		; Carga el Ascii 5 en A.
	
	ret

; -----------------------------------------------------------------------------
; Comprueba si la casilla 6 está libre.
;
; Salida: Z si está libre.
;	  A -> Código ascii del 6.
;
; Altera el valor del registro AF.
; -----------------------------------------------------------------------------
CheckFree6:
	ld	a, (Grid+$05)	; Carga en A el valor del cuadro 6.
	or	a		; Comprueba si está ocupado.
	ld	a, '6'		; Carga el Ascii 6 en A.
	
	ret

; -----------------------------------------------------------------------------
; Comprueba si la casilla 7 está libre.
;
; Salida: Z si está libre.
;	  A -> Código ascii del 7.
;
; Altera el valor del registro AF.
; -----------------------------------------------------------------------------
CheckFree7:
	ld	a, (Grid+$06)	; Carga en A el valor del cuadro 7.
	or	a		; Comprueba si está ocupado.
	ld	a, '7'		; Carga el Ascii 7 en A.
	
	ret

; -----------------------------------------------------------------------------
; Comprueba si la casilla 8 está libre.
;
; Salida: Z si está libre.
;	  A -> Código ascii del 8.
;
; Altera el valor del registro AF.
; -----------------------------------------------------------------------------
CheckFree8:
	ld	a, (Grid+$07)	; Carga en A el valor del cuadro 8.
	or	a		; Comprueba si está ocupado.
	ld	a, '8'		; Carga el Ascii 8 en A.
	
	ret

; -----------------------------------------------------------------------------
; Comprueba si la casilla 9 está libre.
;
; Salida: Z si está libre.
;	  A -> Código ascii del 9.
;
; Altera el valor del registro AF.
; -----------------------------------------------------------------------------
CheckFree9:
	ld	a, (Grid+$08)	; Carga en A el valor del cuadro 9.
	or	a		; Comprueba si está ocupado.
	ld	a, '9'		; Carga el Ascii 9 en A.
	
	ret

; -----------------------------------------------------------------------------
; Comprueba si el movimiento es correcto.
;
; Entrada: A -> Código ascii de la tecla pulsada.
;
; Saliza: Z si el movimiento correcto, casilla libre y NZ en el caso contrario.
;
; Altera el valor de los registros AF y HL.
; -----------------------------------------------------------------------------
CheckMovement:
	sub	'0'				; Calcula el número de la tecla pulsada, 
						; restándole al ascii el ascii del 0.
	ld	hl, Grid-$01			; Apunta HL a la posición anterior al grid.

; Posiciona HL en la posición del grid correspondiente.
CheckMovement_loop:
	inc	hl				; Incrementa HL.
	dec	a				; Decrementa A.
	jr	nz, CheckMovement_loop		; Bucle hasta que A llegue e 0.

; Evalúa si la casilla correspondiente está ocupada.
CheckMovement_check:
	ld	a, (hl)				; Carga en A el valor de la casilla. Puede ser $00 = libre,
						; $01 = ocupada por jugador 1 y $10 = ocupada por jugador 2.
	or	a				; Comprueba si está ocupada. Or A solo es 0 si A = 0.
	ret	nz				; Si no es 0, está ocupada y retorna.

	ld	a, (CurrentPlayerMov)		; Recupera el jugador actual.
	and	$03				; Se queda con los bits donde está el jugador.

	cp	$02				; Comprueba si es el jugador 2.
	jr	nz, CheckMovement_checkContinue ; Si es el jugador 1, salta.
	ld	a, $10				; Si el jugador es el 2, A = $10

CheckMovement_checkContinue:
	ld	(hl), a				; Marca la casilla para el jugador.
	xor	a				; Pone a 1 el flag Z.
	
	ret

; -----------------------------------------------------------------------------
; Comprueba si hay tres en raya.
;
; Retorno: Z si hay tres en raya y NZ en el caso contrario.
;	   A -> jugador actual.
;
; Altera el valor de los registros AF, BC e IX.
; -----------------------------------------------------------------------------
ChekcWinner:
	ld	ix, Grid-$01		; Carga en IX la dirección anterior a las posiciones del Grid.
	ld	a, (CurrentPlayerMov)	; Carga en A los movimientos y el jugador actual.
	and	$03			; Se queda con el jugador.

	ld	b, $03			; Carga en B lo que tienen que sumar las tres casillas para que gane el jugador 1.
	
	cp	$02			; Comprueba si el jugador es el 2.
	jr	nz, ChekcWinner_check	; Si es el juagdor 1, salta.
	
	ld	b, $30			; Carga en B lo que tienen que sumar las tres casillas para que gane el jugador 2.

ChekcWinner_check:
	ld	c, WINNERLINE123	; Indicador de línea 123.
	ld	a, (ix+1)		; Carga en A el valor de la casilla 1.
	add	a, (ix+2)
	add	a, (ix+3)		; Suma los valores de las casillas 2 y 3.
	cp	b			; Comprueba si la suma indica que hay ganador,
	ret	z			; en cuyo caso, sale.

	ld	c, WINNERLINE456	; Indicador de línea 456.
	ld	a, (ix+4)		; Carga en A el valor de la casilla 4.
	add	a, (ix+5)
	add	a, (ix+6)		; Suma los valores de las casillas 5 y 6.
	cp	b			; Comprueba si la suma indica que hay ganador,
	ret	z			; en cuyo caso, sale.

	ld	c, WINNERLINE789	; Indicador de línea 789.
	ld	a, (ix+7)		; Carga en A el valor de la casilla 7.
	add	a, (ix+8)
	add	a, (ix+9)		; Suma los valores de las casillas 8 y 9.
	cp	b			; Comprueba si la suma indica que hay ganador,
	ret	z			; en cuyo caso, sale.

	ld	c, WINNERLINE147	; Indicador de línea 147.
	ld	a, (ix+1)		; Carga en A el valor de la casilla 1.
	add	a, (ix+4)
	add	a, (ix+7)		; Suma los valores de las casillas 4 y 7.
	cp	b			; Comprueba si la suma indica que hay ganador,
	ret	z			; en cuyo caso, sale.

	ld	c, WINNERLINE258	; Indicador de línea 258.
	ld	a, (ix+2)		; Carga en A el valor de la casilla 2.
	add	a, (ix+5)
	add	a, (ix+8)		; Suma los valores de las casillas 5 y 8.
	cp	b			; Comprueba si la suma indica que hay ganador,
	ret	z			; en cuyo caso, sale.

	ld	c, WINNERLINE369	; Indicador de línea 369.
	ld	a, (ix+3)		; Carga en A el valor de la casilla 3.
	add	a, (ix+6)
	add	a, (ix+9)		; Suma los valores de las casillas 6 y 9.
	cp	b			; Comprueba si la suma indica que hay ganador,
	ret	z			; en cuyo caso, sale.

	ld	c, WINNERLINE159	; Indicador de línea 159.
	ld	a, (ix+1)		; Carga en A el valor de la casilla 1.
	add	a, (ix+5)
	add	a, (ix+9)		; Suma los valores de las casillas 5 y 9.
	cp	b			; Comprueba si la suma indica que hay ganador,
	ret	z			; en cuyo caso, sale.

	ld	c, WINNERLINE357	; Indicador de línea 357.
	ld	a, (ix+3)		; Carga en A el valor de la casilla 3.
	add	a, (ix+5)
	add	a, (ix+7)		; Suma los valores de las casillas 5 y 7.
	cp	b			; Comprueba si la suma indica que hay ganador.
	ret				; Siempre sale. Última condición.

; -----------------------------------------------------------------------------
; Obtiene el color de tinta para el jugador actual.
;
; Salida: A -> tinta para el jugador actual.
;
; Altera el valor del registro AF.
; -----------------------------------------------------------------------------
GetCurrentPlayerInk:
	ld	a, (CurrentPlayerMov)	; Obtiene el jugador y los movimiento.
	and	$01			; Se queda con el bit 0.
	ld	a, INKPLAYER1		; Carga el color para el jugador 1.
	ret	nz			; Si Z no está activo, es el jugador 1 y sale.

	ld	a, INKPLAYER2		; Carga el color para el jugador 2.
	ret	
	
; -----------------------------------------------------------------------------
; Obtiene un puntero al nombre del jugador actual.
;
; Entrada: L -> 1 = Actual, 0 = Anterior.
;
; Salida: HL -> puntero al nombre del jugador actual.
;
; Altera el valor del registro AF y HL.
; -----------------------------------------------------------------------------
GetPlayerName:
	ld	a, (CurrentPlayerMov)	; Obtiene el jugador y los movimiento.
	bit	0, l
	jr	nz, GetPlayerName_continue
	xor	$03
GetPlayerName_continue:
	and	$01			; Se queda con el bit 0.
	ld	hl, NamePlayer1		; Carga el nombre para el jugador 1.
	ret	nz			; Si Z no está activo, es el jugador 1 y sale.

	ld	hl, NamePlayer2		; Carga el nombre para el jugador 1.
	ret			

; -----------------------------------------------------------------------------
; Mueve el Spectrum.
;
; Salida: A -> Código ascii de la casilla donde mueve.
;
; Altera el valor de los registros AF, BC e IX.
; -----------------------------------------------------------------------------
SpectrumMovement:
	ld	a, (CurrentPlayerMov)		; Recupera el número de movimientos y jugador actual.
	and 	$f0				; Se queda con el número de movimientos.
	jp	z, SpectrumRandomMovement	; Si es 0, primer movimiento para el Spectrum pseudoaleatorio.

	cp	$10				; Comprueba si hay mñas de un movimiento.
	jr	nz, SpectrumForWinMovement_123	; Si hay más de un movimiento, salta.

	call	CheckFree5			; Solo hay un movimiento, mueve al 5 si está libre.
	ret	z				; Si está libre sale.

; -----------------------------------------------------------------------------
; Evalúa si el Spectrum tiene movimiento para ganar.
; -----------------------------------------------------------------------------
SpectrumForWinMovement_123:
	ld	ix, Grid-$01			; Apunta IX a la posición anterior a Grid.
	ld	b, $20				; Carga en B el valor que indica que el Spectrum
						; tiene movimiento para ganar.

	ld	a, (ix+$01)			; Suma en A las casillas para saber cuántas están ocupadas.
	add	a, (ix+$02)
	add	a, (ix+$03)

	cp	b				; Si A = $20, hay movimiento para ganar.
	jp	nz, SpectrumForWinMovement_456	; Si no, salta.

	call	CheckFree1			; Verifica si la casilla 1 es la que está libre.
	ret	z				; Si está libre sale.
	
	call	CheckFree2			; Verifica si la casilla 2 es la que está libre.
	ret	z				; Si está libre sale.

	; La casilla 3 está libre.
	ld	a, '3'				; Carga en A el Ascii.
	ret					; Sale.

SpectrumForWinMovement_456:
	ld	a, (ix+$04)			; Suma en A las casillas para saber cuántas están ocupadas.
	add	a, (ix+$05)
	add	a, (ix+$06)

	cp	b				; Si A = $20, hay movimiento para ganar.
	jr	nz, SpectrumForWinMovement_789	; Si no, salta.
	
	call	CheckFree4			; Verifica si la casilla 4 es la que está libre.
	ret	z				; Si está libre sale.
	
	call	CheckFree5			; Verifica si la casilla 5 es la que está libre.
	ret	z				; Si está libre sale.

	; La casilla 6 está libre.
	ld	a, '6'				; Carga en A el Ascii.
	ret					; Sale.


SpectrumForWinMovement_789:
	ld	a, (ix+$07)			; Suma en A las casillas para saber cuántas están ocupadas.
	add	a, (ix+$08)
	add	a, (ix+$09)

	cp	b				; Si A = $20, hay movimiento para ganar.
	jr	nz, SpectrumForWinMovement_147	; Si no, salta.

	
	call	CheckFree7			; Verifica si la casilla 7 es la que está libre.
	ret	z				; Si está libre salta.
	
	call	CheckFree8			; Verifica si la casilla 8 es la que está libre.
	ret	z				; Si está libre sale.
	
	; La casilla 9 está libre.
	ld	a, '9'				; Carga en A el Ascii.
	ret					; Sale.
	
SpectrumForWinMovement_147:
	ld	a, (ix+$01)			; Suma en A las casillas para saber cuántas están ocupadas.
	add	a, (ix+$04)
	add	a, (ix+$07)

	cp	b				; Si A = $20, hay movimiento para ganar.
	jr	nz, SpectrumForWinMovement_258	; Si no, salta.

	call	CheckFree1			; Verifica si la casilla 1 es la que está libre.
	ret	z				; Si está libre sale.

	call	CheckFree4			; Verifica si la casilla 4 es la que está libre.
	ret	z				; Si está libre sale.
	
	; La casilla 7 está libre.
	ld	a, '7'				; Carga en A el Ascii.
	ret					; Sale.

SpectrumForWinMovement_258:
	ld	a, (ix+$02)			; Suma en A las casillas para saber cuántas están ocupadas.
	add	a, (ix+$05)
	add	a, (ix+$08)

	cp	b				; Si A = $20, hay movimiento para ganar.
	jr	nz, SpectrumForWinMovement_369	; Si no, salta.

	call	CheckFree2			; Verifica si la casilla 2 es la que está libre.
	ret	z				; Si está libre sale.
	
	call	CheckFree5			; Verifica si la casilla 5 es la que está libre.
	ret	z				; Si está libre sale.
	
	; La casilla 8 está libre.
	ld	a, '8'				; Carga en A el Ascii.
	ret					; Sale.
	
SpectrumForWinMovement_369:
	ld	a, (ix+$03)			; Suma en A las casillas para saber cuántas están ocupadas.
	add	a, (ix+$06)
	add	a, (ix+$09)

	cp	b				; Si A = $20, hay movimiento para ganar.
	jr	nz, SpectrumForWinMovement_159	; Si no, salta.

	call	CheckFree3			; Verifica si la casilla 3 es la que está libre.
	ret	z				; Si está libre sale.
		
	call	CheckFree6			; Verifica si la casilla 6 es la que está libre.
	ret	z				; Si está libre sale.
	
	; La casilla 9 está libre.
	ld	a, '9'				; Carga en A el Ascii.
	ret					; Sale.
	
SpectrumForWinMovement_159:
	ld	a, (ix+$01)			; Suma en A las casillas para saber cuántas están ocupadas.
	add	a, (ix+$05)
	add	a, (ix+$09)

	cp	b				; Si A = $20, hay movimiento para ganar.
	jr	nz, SpectrumForWinMovement_357	; Si no, salta.

	call	CheckFree1			; Verifica si la casilla 1 es la que está libre.
	ret	z				; Si está libre sale.
	
	call	CheckFree5			; Verifica si la casilla 5 es la que está libre.
	ret	z				; Si está libre sale.
	
	; La casilla 9 está libre.
	ld	a, '9'				; Carga en A el Ascii.
	ret					; Sale.

SpectrumForWinMovement_357:
	ld	a, (ix+$03)				; Suma en A las casillas para saber cuántas están ocupadas.
	add	a, (ix+$05)
	add	a, (ix+$07)

	cp	b					; Si A = $20, hay movimiento para ganar.
	jr	nz, SpectrumDefensiveMovement_123	; Si no, salta.

	call	CheckFree3				; Verifica si la casilla 3 es la que está libre.
	ret	z					; Si está libre sale.
	
	call	CheckFree5				; Verifica si la casilla 5 es la que está libre.
	ret	z					; Si está libre sale.
	
	; La casilla 7 está libre.
	ld	a, '7'					; Carga en A el Ascii.
	ret						; Sale.

; -----------------------------------------------------------------------------
; Movimiento defensivo horizontal y vertical.
; -----------------------------------------------------------------------------
SpectrumDefensiveMovement_123:
	ld	b, $02					; Carga en B el valor que indica que el jugador 1
							; tiene movimiento para ganar.

	ld	a, (ix+$01)				; Suma en A las casillas para saber cuántas están ocupadas.
	add	a, (ix+$02)
	add	a, (ix+$03)

	cp	b					; Si A = $02, hay movimiento para ganar.
	jp	nz, SpectrumDefensiveMovement_456	; Si no, salta.

	call	CheckFree1				; Verifica si la casilla 1 es la que está libre.
	ret	z					; Si está linra sale.

	call	CheckFree2				; Verifica si la casilla 2 es la que está libre.
	ret	z					; Si está libre sale.

	; La casilla 3 está libre.
	ld	a, '3'					; Carga en A el Ascii.
	ret						; Sale		

SpectrumDefensiveMovement_456:
	ld	a, (ix+$04)				; Suma en A las casillas para saber cuántas están ocupadas.
	add	a, (ix+$05)
	add	a, (ix+$06)

	cp	b					; Si A = $02, hay movimiento para ganar.
	jp	nz, SpectrumDefensiveMovement_789	; Si no, salta.
	
	call	CheckFree4				; Verifica si la casilla 4 es la que está libre.
	ret	z					; Si está libre sale.

	call	CheckFree5				; Verifica si la casilla 5 es la que está libre.
	ret	z					; Si está libre sale.

	; La  casilla 6 está libre.
	ld	a, '6'					; Carga en A el Ascii.
	ret						; Sale.

SpectrumDefensiveMovement_789:
	ld	a, (ix+$07)				; Suma en A las casillas para saber cuántas están ocupadas.
	add	a, (ix+$08)
	add	a, (ix+$09)

	cp	b					; Si A = $02, hay movimiento para ganar.
	jp	nz, SpectrumDefensiveMovement_147	; Si no, salta.

	call	CheckFree7				; Verifica si la casilla 7 es la que está libre.
	ret	z					; Si está libre sale.

	call	CheckFree8				; Verifica si la casilla 8 es la que está libre.
	ret	z					; Si está libre sale.

	; La casilla 9 está libre.
	ld	a, '9'					; Carga en A el Ascii.
	ret						; Sale.

SpectrumDefensiveMovement_147:
	ld	a, (ix+$01)				; Suma en A las casillas para saber cuántas están ocupadas.
	add	a, (ix+$04)
	add	a, (ix+$07)

	cp	b					; Si A = $02, hay movimiento para ganar.
	jp	nz, SpectrumDefensiveMovement_258	; Si no, salta.

	call	CheckFree1				; Verifica si la casilla 1 es la que está libre.
	ret	z					; Si está libre sale.

	call	CheckFree4				; Verifica si la casilla 4 es la que está libre.
	ret	z					; Si está libre sale.

	; La casilla 7 está libre.
	ld	a, '7'					; Carga en A el Ascii.
	ret						; Sale.

SpectrumDefensiveMovement_258:
	ld	a, (ix+$02)				; Suma en A las casillas para saber cuántas están ocupadas.
	add	a, (ix+$05)
	add	a, (ix+$08)

	cp	b					; Si A = $02, hay movimiento para ganar.
	jp	nz, SpectrumDefensiveMovement_369	; Si no, salta.

	call	CheckFree2				; Verifica si la casilla 2 es la que está libre.
	ret	z

	call	CheckFree5				; Verifica si la casilla 5 es la que está libre.
	ret	z

	; La casilla 8 está libre.
	ld	a, '8'					; Carga en A el Ascii.
	ret						; Sale.
	
SpectrumDefensiveMovement_369:
	ld	a, (ix+$03)				; Suma en A las casillas para saber cuántas están ocupadas.
	add	a, (ix+$06)
	add	a, (ix+$09)

	cp	b					; Si A = $02, hay movimiento para ganar.
	jp	nz, SpectrumDefensiveMovement_159	; Si no, salta.

	call	CheckFree3				; Verifica si la casilla 3 es la que está libre.
	ret	z					; Si está libre sale.

	call	CheckFree6				; Verifica si la casilla 6 es la que está libre.
	ret	z					; Si está libre sale.

	; La casilla 9 está libre.
	ld	a, '9'					; Carga en A el Ascii.
	ret						; Sale.

SpectrumDefensiveMovement_159:
	ld	a, (ix+$01)				; Suma en A las casillas para saber cuántas están ocupadas.
	add	a, (ix+$05)
	add	a, (ix+$09)

	cp	b					; Si A = $02, hay movimiento para ganar.
	jp	nz, SpectrumDefensiveMovement_357	; Si no, salta.

	call	CheckFree1				; Verifica si la casilla 1 es la que está libre.
	ret	z					; Si está libre sale.

	call	CheckFree5				; Verifica si la casilla 5 es la que está libre.
	ret	z					; Si está libre sale.

	; La casilla 9 está libre.
	ld	a, '9'					; Carga en A el Ascii.
	ret						; Sale.

SpectrumDefensiveMovement_357:
	ld	a, (ix+$03)				; Suma en A las casillas para saber cuántas están ocupadas.
	add	a, (ix+$05)
	add	a, (ix+$07)

	cp	b					; Si A = $02, hay movimiento para ganar.
	jp	nz, SpectrumDefensiveMovement_diagonal	; Si no, salta.

	call	CheckFree3				; Verifica si la casilla 3 es la que está libre.
	ret	z					; Si está libre sale.

	call	CheckFree5				; Verifica si la casilla 5 es la que está libre.
	ret	z					; Si está libre sale.

	; La casilla 7 está libre.
	ld	a, '7'					; Carga en A el Ascii.
	ret						; Sale.

; -----------------------------------------------------------------------------
; Movimiento defensivo diagonal.
; -----------------------------------------------------------------------------
SpectrumDefensiveMovement_diagonal:
	; Comprueba si jugador 1 intenta jugada diagonal.
	ld	a, (ix+$01)					; Suma en A las casillas para saber cuántas están ocupadas.
	add	a, (ix+$09)
	cp	b						; Si A = $02, hay movimiento diagonal.
	jr	z, SpectrumDefensiveMovement_crossBlock		; Si hay movimiento diagonal, salta a bloqueo.

	ld	a, (ix+$03)					; Suma en A las casillas para saber cuántas están ocupadas.
	add	a, (ix+$07)
	cp	b						; Si A = $02, hay movimiento diagonal.
	jr	nz, SpectrumDefensiveMovement_crossBlock1	; Si no hay movimiento diagonal, salta.

SpectrumDefensiveMovement_crossBlock:
	; Bloquea en cruz.
	call	CheckFree4	; Comprueba si la casilla 4 está libre.
	ret 	z		; Si está libre sale.

	call	CheckFree6	; Comprueba si la casilla 6 está libre.
	ret 	z		; Si está libre sale.

	call	CheckFree2	; Comprueba si la casilla 2 está libre.
	ret	z		; Si está libre sale.

	call	CheckFree8	; Comprueba si la casilla 9 está libre.
	ret	z		; Si está libre sale.

; -----------------------------------------------------------------------------
; Movimiento defensivo de diagonal con el centro ocupado.
; -----------------------------------------------------------------------------
SpectrumDefensiveMovement_crossBlock1:
	ld	a, (ix+$05)					; Carga la casilla 5 en A.
	and	$0f						; Se queda con la parte del jugador 1.
	jr	z, SpectrumDefensiveMovement_cornerBlock16	; Si está a 0, no la tiene ocupada.
								; Sale de este bloue de comprobaciones.

	ld	a, (ix+$01)					; Carga la casilla 1 en A.
	and	$0f						; Se queda con la parte del jugador 1.
	jr	z, SpectrumDefensiveMovement_crossBlock3	; Si no la tiene ocupada, salta.

	call	CheckFree7					; Comprueba si la casilla 7 está libre.
	ret	z						; Si está libre sale.

SpectrumDefensiveMovement_crossBlock3:
	ld	a, (ix+$03)					; Carga la casilla 3 en A.
	and	$0f						; Se queda con la parte del jugador 1.
	jr	z, SpectrumDefensiveMovement_crossBlock7	; Si no la tiene ocupada, salta.

	call	CheckFree9					; Comprueba si la casilla 9 está libre.
	ret	z						; Si está libre sale.

SpectrumDefensiveMovement_crossBlock7:
	ld	a, (ix+$07)					; Carga la casilla 7 en A.
	and	$0f						; Se queda con la parte del jugador 1.
	jr	z, SpectrumDefensiveMovement_crossBlock9	; Si no la tiene ocupada, salta.

	call	CheckFree1					; Comprueba si la casilla 1 está libre.
	ret	z						; Si está libre sale.

SpectrumDefensiveMovement_crossBlock9:
	ld	a, (ix+$09)					; Carga la casilla 9 en A.
	and	$0f						; Se queda con la parte del jugador 1.
	jr	z, SpectrumDefensiveMovement_cornerBlock16	; Si no la tiene ocupada, salta.

	call	CheckFree3					; Comprueba si la casilla 3 está libre.
	ret	z						; Si está libre sale.

; -----------------------------------------------------------------------------
; Movimiento defensivo en cruz.
; -----------------------------------------------------------------------------
SpectrumDefensiveMovement_cornerBlock16:
	ld	a, (ix+$01)					; Suma en A las casillas para saber cuántas están ocupadas.
	add	a, (ix+$06)
	cp	b						; Si A = $02, hay movimiento en cruz.
	jr	nz, SpectrumDefensiveMovement_cornerBlock34	; Si no hay movimiento en cruz, salta.

	call	CheckFree3					; Comprueba si la casilla 3 está libre.
	ret	z						; Si está libre sale.

SpectrumDefensiveMovement_cornerBlock34:
	ld	a, (ix+$03)					; Suma en A las casillas para saber cuántas están ocupadas.
	add	a, (ix+$04)
	cp	b						; Si A = $02, hay movimiento en cruz.
	jr	nz, SpectrumDefensiveMovement_cornerBlock67	; Si no hay movimiento en cruz, salta.

	call	CheckFree1					; Comprueba si la casilla 1 está libre.
	ret	z						; Si está libre sale.

SpectrumDefensiveMovement_cornerBlock67:
	ld	a, (ix+$06)					; Suma en A las casillas para saber cuántas están ocupadas.
	add	a, (ix+$07)
	cp	b						; Si A = $02, hay movimiento en cruz.
	jr	nz, SpectrumDefensiveMovement_cornerBlock49	; Si no hay movimiento en cruz, salta.

	call	CheckFree9					; Comprueba si la casilla 9 está libre.
	ret	z						; Si está libre sale.

SpectrumDefensiveMovement_cornerBlock49:
	ld	a, (ix+$04)					; Suma en A las casillas para saber cuántas están ocupadas.
	add	a, (ix+$09)
	cp	b						; Si A = $02, hay movimiento en cruz.
	jr	nz, SpectrumDefensiveMovement_cornerBlock1827	; Si no hay movimiento en cruz, salta.

	call	CheckFree7					; Comprueba si la casilla 7 está libre.
	ret	z						; Si está libre sale.

SpectrumDefensiveMovement_cornerBlock1827:
	ld	a, (ix+$01)						; Suma en A las casillas para saber cuántas están ocupadas.
	add	a, (ix+$08)
	cp	b							; Si A = $02, hay movimiento en cruz.
	jr	z, SpectrumDefensiveMovement_cornerBlock1827Continue	; Si hay movimiento en cruz, salta a bloquear.

	ld	a, (ix+$02)						; Suma en A las casillas para saber cuántas están ocupadas.
	add	a, (ix+$07)
	cp	b							; Si A = $02, hay movimiento en cruz.
	jr	nz, SpectrumDefensiveMovement_cornerBlock2938		; Si no hay movimiento en cruz, salta.

SpectrumDefensiveMovement_cornerBlock1827Continue:
	call	CheckFree4						; Comprueba si la casilla 4 está libre.
	ret	z							; Si está libre sale.

SpectrumDefensiveMovement_cornerBlock2938:
	ld	a, (ix+$02)						; Suma en A las casillas para saber cuántas están ocupadas.
	add	a, (ix+$09)
	cp	b							; Si A = $02, hay movimiento en cruz.
	jr	z, SpectrumDefensiveMovement_cornerBlock2938Continue	; Si hay movimiento en cruz, salta a bloquear.

	ld	a, (ix+$03)						; Suma en A las casillas para saber cuántas están ocupadas.
	add	a, (ix+$08)
	cp	b							; Si A = $02, hay movimiento en cruz.
	jr	nz, SpectrumOffensiveMovement_123			; Si no hay movimiento en cruz, salta.

SpectrumDefensiveMovement_cornerBlock2938Continue:
	call	CheckFree6						; Comprueba si la casilla 6 está libre.
	ret	z							; Si está libre sale.

; -----------------------------------------------------------------------------
; Movimiento ofensivo horizontal, vertical y diagonal.
; -----------------------------------------------------------------------------
SpectrumOffensiveMovement_123:
	ld	b, $20					; Carga el valor que indica que Spectrum tiene
							; dos casillas ocupadas.
	ld	a, (ix+$01)				; Suma en A las casillas para saber cuántas están ocupadas.
	add	a, (ix+$02)
	add	a, (ix+$03)
	ld	c, a					; Carga el valor en C para luego recuperarlo.
	and	$03					; Se queda con las casillas del jugador 1.
	or	a					; Comprueba si hay alguna ocupada.
	jr	nz, SpectrumOffensiveMovement_456	; Si hay alguna ocupada, salta.

	ld	a, c					; Recupera el valor de A desde C.
	and	$30					; Se queda con las casillas del Spectrum.
	cp	b					; Comprueba si ya hay dos ocupadas.
	jr	z, SpectrumOffensiveMovement_456	; Si hay dos ocupadas salta.

	call	CheckFree1				; Comprueba si la casilla 1 está libre.
	ret	z					; Si está libre sale.

	call	CheckFree2				; Comprueba si la casilla 1 está libre.
	ret	z					; Si está libre sale.

	; La casilla 3 está libre.
	ld	a, '3'					; Carga en A el Ascii.
	ret						; Sale.


SpectrumOffensiveMovement_456:
	ld	a, (ix+$04)				; Suma en A las casillas para saber cuántas están ocupadas.
	add	a, (ix+$05)
	add	a, (ix+$06)
	ld	c, a					; Carga el valor en C para luego recuperarlo.
	and	$03					; Se queda con las casillas del jugador 1
	or	a		;			; Comprueba si hay alguna ocupada.
	jr	nz, SpectrumOffensiveMovement_789	; Si hay alguna ocupada, salta.

	ld	a, c					; Recupera el valor de A desde C.
	and	$30					; Se queda con las casillas del Spectrum.
	cp	b					; Comprueba si ya hay dos ocupadas.
	jr	z, SpectrumOffensiveMovement_789	; Si hay dos ocupadas salta.

	call	CheckFree4				; Comprueba si la casilla 4 está libre.
	ret	z					; Si está libre sale.

	call	CheckFree5				; Comprueba si la casilla 5 está libre.
	ret	z					; Si está libre sale.

	; La casilla 6 está libre.
	ld	a, '6'					; Carga en A el Ascii.
	ret						; Sale.

SpectrumOffensiveMovement_789:
	ld	a, (ix+$07)				; Suma en A las casillas para saber cuántas están ocupadas.
	add	a, (ix+$08)
	add	a, (ix+$09)
	ld	c, a					; Carga el valor en C para luego recuperarlo.
	and	$03					; Se queda con las casillas del jugador 1
	or	a					; Comprueba si hay alguna ocupada.
	jr	nz, SpectrumOffensiveMovement_147	; Si hay alguna ocupada, salta.

	ld	a, c					; Recupera el valor de A desde C.
	and	$30					; Se queda con las casillas del Spectrum.
	cp	b					; Comprueba si ya hay dos ocupadas.
	jr	z, SpectrumOffensiveMovement_147	; Si hay dos ocupadas salta.

	call	CheckFree7				; Comprueba si la casilla 7 está libre.
	ret	z					; Si está libre sale.

	call	CheckFree8				; Comprueba si la casilla 8 está libre.
	ret	z					; Si está libre sale.

	; La casilla 9 está libre.
	ld	a, '9'					; Carga en A el Ascii.
	ret						; Sale.

SpectrumOffensiveMovement_147:
	ld	a, (ix+$01)				; Suma en A las casillas para saber cuántas están ocupadas.
	add	a, (ix+$04)
	add	a, (ix+$07)
	ld	c, a					; Carga el valor en C para luego recuperarlo.
	and	$03					; Se queda con las casillas del jugador 1
	or	a					; Comprueba si hay alguna ocupada.
	jr	nz, SpectrumOffensiveMovement_258	; Si hay alguna ocupada, salta.

	ld	a, c					; Recupera el valor de A desde C.
	and	$30					; Se queda con las casillas del Spectrum.
	cp	b					; Comprueba si ya hay dos ocupadas.
	jr	z, SpectrumOffensiveMovement_258	; Si hay dos ocupadas salta.

	call	CheckFree1				; Comprueba si la casilla 1 está libre.
	ret	z					; Si está libre sale.

	call	CheckFree4				; Comprueba si la casilla 4 está libre.
	ret	z					; Si está libre sale.

	; La casilla 7 está libre.
	ld	a, '7'					; Carga en A el Ascii.
	ret						; Sale.

SpectrumOffensiveMovement_258:
	ld	a, (ix+$02)				; Suma en A las casillas para saber cuántas están ocupadas.
	add	a, (ix+$05)
	add	a, (ix+$08)
	ld	c, a					; Carga el valor en C para luego recuperarlo.
	and	$03					; Se queda con las casillas del jugador 1
	or	a					; Comprueba si hay alguna ocupada.
	jr	nz, SpectrumOffensiveMovement_369	; Si hay alguna ocupada, salta.

	ld	a, c					; Recupera el valor de A desde C.
	and	$30					; Se queda con las casillas del Spectrum.
	cp	b					; Comprueba si ya hay dos ocupadas.
	jr	z, SpectrumOffensiveMovement_369	; Si hay dos ocupadas salta.

	call	CheckFree2				; Comprueba si la casilla 2 está libre.
	ret	z					; Si está libre sale.

	call	CheckFree5				; Comprueba si la casilla 5 está libre.
	ret	z					; Si está libre sale.

	; La casilla 8 está libre.
	ld	a, '8'					; Carga en A el Ascii.
	ret						; Sale.

SpectrumOffensiveMovement_369:
	ld	a, (ix+$03)				; Suma en A las casillas para saber cuántas están ocupadas.
	add	a, (ix+$06)
	add	a, (ix+$09)
	ld	c, a					; Carga el valor en C para luego recuperarlo.
	and	$03					; Se queda con las casillas del jugador 1
	or	a					; Comprueba si hay alguna ocupada.
	jr	nz, SpectrumOffensiveMovement_159	; Si hay alguna ocupada, salta.

	ld	a, c					; Recupera el valor de A desde C.
	and	$30					; Se queda con las casillas del Spectrum.
	cp	b					; Comprueba si ya hay dos ocupadas.
	jr	z, SpectrumOffensiveMovement_159	; Si hay dos ocupadas salta.

	call	CheckFree3				; Comprueba si la casilla 3 está libre.
	ret	z					; Si está libre sale.

	call	CheckFree6				; Comprueba si la casilla 6 está libre.
	ret	z					; Si está libre sale.

	; La casilla 9 está libre.
	ld	a, '9'					; Carga en A el Ascii.
	ret						; Sale.

SpectrumOffensiveMovement_159:
	ld	a, (ix+$01)				; Suma en A las casillas para saber cuántas están ocupadas.
	add	a, (ix+$05)
	add	a, (ix+$09)
	ld	c, a					; Carga el valor en C para luego recuperarlo.
	and	$03					; Se queda con las casillas del jugador 1
	or	a					; Comprueba si hay alguna ocupada.
	jr	nz, SpectrumOffensiveMovement_357	; Si hay alguna ocupada, salta.

	ld	a, c					; Recupera el valor de A desde C.
	and	$30					; Se queda con las casillas del Spectrum.
	cp	b					; Comprueba si ya hay dos ocupadas.
	jr	z, SpectrumOffensiveMovement_357	; Si hay dos ocupadas salta.

	call	CheckFree1				; Comprueba si la casilla 1 está libre.
	ret	z					; Si está libre sale.

	call	CheckFree5				; Comprueba si la casilla 5 está libre.
	ret	z					; Si está libre sale.

	; La casilla 9 está libre.
	ld	a, '9'					; Carga en A el Ascii.
	ret						; Sale.

SpectrumOffensiveMovement_357:
	ld	a, (ix+$03)				; Suma en A las casillas para saber cuántas están ocupadas.
	add	a, (ix+$05)
	add	a, (ix+$07)
	ld	c, a					; Carga el valor en C para luego recuperarlo.
	and	$03					; Se queda con las casillas del jugador 1
	or	a					; Comprueba si hay alguna ocupada.
	jr	nz, SpectrumGenericMovement		; Si hay alguna ocupada, salta.

	ld	a, c					; Recupera el valor de A desde C.
	and	$30					; Se queda con las casillas del Spectrum.
	cp	b					; Comprueba si ya hay dos ocupadas.
	jr	z, SpectrumGenericMovement		; Si hay dos ocupadas salta.

	call	CheckFree3				; Comprueba si la casilla 3 está libre.
	ret	z					; Si está libre sale.

	call	CheckFree5				; Comprueba si la casilla 5 está libre.
	ret	z					; Si está libre sale.

	; La casilla 7 está libre.
	ld	a, '7'					; Carga en A el Ascii.
	ret						; Sale.

; -----------------------------------------------------------------------------
; Movimiento genérico. 
; Si con todo lo anterior, no ha hecho movimiento, mueve a la primera casilla
; libre.
; -----------------------------------------------------------------------------
SpectrumGenericMovement:
	ld	c, '1'					; Carga en C el Ascii de 1.
	ld	b, $09					; Carga en B el número de casillas.
	ld	a, $00					; Carga en A el valor para saber si la casilla está vacía.
	ld	hl, Grid				; Carga en HL la dirección de la primera casilla.

SpectrumGenericMovement_loop:
	cp	(hl)					; Compara el valor de memoria con 0.
	jr	z, SpectrumGenericMovement_end		; Si es cero, casilla vacia y salta.
	inc	c					; No está vacía, incrementa el código Ascii.
	inc	hl					; Apunta HL a la siguiente casilla.
	djnz	SpectrumGenericMovement_loop		; Bucle hasta que B sea 0.

SpectrumGenericMovement_end:
	ld	a, c					; Carga en A el Ascii de la casilla vacía.
	ret						; Sale.

; -----------------------------------------------------------------------------
; Genera números pseudo aleatorios del 1 al 9.
; Sigue un puntero a través de la ROM (a partir de una semilla) y retorna el
; contenido del byte de esta posición.
;
; Rutina obtenida de http://old8bits.blogspot.com.es/2016/04/como-escribir-juegos-para-el-zx_18.html
; Se ha modificado ligeramente.
;
; Salida: A -> Número aleatorio generado
;
; Altera el valor de los registros AF y HL.
; -----------------------------------------------------------------------------
SpectrumRandomMovement:
	ld hl, (Seed)					; Carga en HL el valor de la semilla.
	ld a, (hl)					; Obtiene el valor del byte apuntado por HL.
	inc	hl					; Avanza HL hasta la siguiente posición de memoria.

	; En este caso, la rutina se usa para el primer movimiento del Spectrum,
	; por lo que el valor debe estar entre 0 y 8.
	and	$0f					; Se queda con los bits 0, 1, 2 y 3.
	cp	$09					; Comprueba si el valor en menor de 9.
	jr	c, SpectrumRandomMovement_continue	; Si es menor de 9, salta.

	srl	a					; El valor es mayor de 8, desplaza un bit a derecha.

SpectrumRandomMovement_continue:
	inc	a					; Incrementa A para que el valor quede comprendido entre 1 y 9.
	add	a, '0'					; Le suma el código ascii del 0.
	
	push	af					; Preserva AF.

	; Mantiene el puntero en los 16Kb ($3FFF) de la ROM, por debajo de $4000.
	; cp h = a - h
	ld	a, $40					; Carga el valor máximo del byte más significativo de HL.
	cp 	h					; Lo compara con HL.
	jr	nz, SpectrumRandomMovement_end		; Si A no es $40, salta.				
	
	ld	hl, 0					; Apunta HL al inicio de la ROM.
SpectrumRandomMovement_end:
	ld 	(Seed), hl				; Pone el valor en memoria

	pop	af					; Recupera el valor de AF.

	ret

; -----------------------------------------------------------------------------
; Actualiza el jugador y el número de movimientos.
;
; Salida: A -> Número de movimientos y jugador.
;
; Altera el valor del registro AF.
; -----------------------------------------------------------------------------
UpdatePlayerMov:
	ld	a, (MaxSeconds)			; Obtiene los segundos por turno.
	ld	(CountDown), a			; Actualiza la cuenta a atrás.
	ld	a, $00
	ld	(CountDownTicks), a		; Pone a 0 el contador de ticks.

	ld	a, (CurrentPlayerMov)		; Carga el jugador y el número de movimientos.
	xor	$03				; Alterna jugador 1 y jugador 2.
	add	a, $10				; Añade un turno.	
	ld	(CurrentPlayerMov), a		; Lo carga en memoria.

	ret