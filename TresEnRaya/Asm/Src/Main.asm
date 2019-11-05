; -----------------------------------------------------------------------------
; Fichero: Main.asm
;
; Fichero principal Tres En Raya.
; -----------------------------------------------------------------------------

org $5dad

; -----------------------------------------------------------------------------
; Entrada del programa Tren En Raya.
;
; Altera el valor de los registros AF y HL.
; -----------------------------------------------------------------------------
TresEnRaya:
	ld	hl, Sprite_X		; Apunta HL al primer sprite.
	ld 	(UDG), hl		; Pone el primer sprite como dirección del primer UDG.

	ld	a, $02			
	call	OPENCHAN		; Abre el canal 2, pantalla 1.

	ld	a, $00
	call	SetBorder		; Pone el borde en negro.

	ld	a, $07
	call	ClearAttributes		; Pone el papel en negro y la tinta en blanco.

	; Inicializa los valores.
	ld	a, $01
	ld	(MaxPlayers), a		; Número de jugadores 1.

	ld	a, $05
	ld	(MaxPoints), a		; Número de puntos 5.

	ld	a, $10
	ld	(MaxSeconds), a		; Segundos por turno 10, en BCD.

TresEnRaya_menu:
	ld	a, $00
	call	ClearScreen		; Limpia la pantalla.

	call	Menu			; Imprime el menú.

	call	Espamatica		; Imprime Espamatica.

	call	MenuOptions		; Evalúa las opciones.

	; Empieza la partida.
	call 	GetPlayersName		; Solicita el nombre de los jugadores.

; -----------------------------------------------------------------------------
; Inicia la partida.
;
; Altera el valor de los registros AF, BC, DE, HL e IX.
; -----------------------------------------------------------------------------
TresEnRaya_ini:
	call	EnableISR		; Activa las interrupciones en modo 2.

	ld	a, $00
	call	ClearScreen		; Limpia la pantalla.

	ld	hl, CurrentPlayerMov	; Incializa el jugador actual y número total de movimientos.
	ld	(hl), $01		; El jugador está en los bits 0, 1, 2 y 3. Los movimientos en 4, 5, 6 y 7.

	; Imprime la pantalla de juego.
	ld	a, $07
	call	SetInk			; Cambia la tinta a blanco.

	ld	b, INI_TOP
	ld	c, INI_LEFT - $05
	call	SetCursorPosition	; Posiciona el cursor.

	ld	hl, Title
	call	PrintString		; Imprime el título.

	ld	hl, Title_1
	call	PrintString		; Imprime la segunda parte del título.

	ld	hl, MaxPoints
	call	PrintBCD		; Imprime los puntos para ganar la partida.

	ld	hl, Title_2
	call	PrintString		; Imprime la tercera parte del título.

	ld	a, (MaxPoints)
	cp	$01			; Comprueba si es más de un punto.
	jr	z, TresEnRaya_iniContinue	; Si es un punto salta.
	
	ld	a, 's'
	rst	$10			; Imprime la S para el plural.

TresEnRaya_iniContinue:
	; Imprime los nombres de los jugadores.
	ld	a, $02
	call	SetInk			; Cambia la tinta a rojo.

	ld	b, INI_TOP - $02
	ld	c, INI_LEFT
	call 	SetCursorPosition	; Posiciona el cursor.
	ld	hl, NamePlayer1
	call	PrintString		; Imprime el nombre del jugador 1.

	ld	c, INI_LEFT - $0d
	call	SetCursorPosition	; Posiciona el cursor.
	ld	hl, TitleTie
	call	PrintString		; Imprime el literal Tablas.

	ld	c, INI_LEFT - $18
	call	SetCursorPosition	; Posiciona el cursor.
	ld	hl, NamePlayer2
	call	PrintString		; Imprime el nombre del jugador 2.

	; Imprime la figura de los jugadores.
	ld	b, INI_TOP - $04
	ld	c, INI_LEFT
	call	PrintX			; Imprime la X.

	ld	b, INI_TOP - $04
	ld	c, INI_LEFT - $18
	call	PrintO			; Imprime la O.

TresEnRaya_iniEnd:
	; Inicializa los marcadores.
	ld	ix, PointsPlayer1
	ld	(ix+0), $00		; Puntos del jugador 1.
	ld	(ix+1), $00		; Puntos del jugador 2.
	ld	(ix+2), $00		; Tablas.

TresEnRaya_game:
	; Inicializa la cuenta atrás.
	ld	hl, CountDown		; Apunta HL a la cuenta atrás.
	ld	a, (MaxSeconds)		; A = segundos por turno.
	ld	(hl), a			; Carga el valor en la cuentra atrás.

	ld	hl, CountDownTicks	; Apunta HL a los ticks de la cuenta atrás.
	ld	(hl), $00		; Pone los ticks a 0.

	; Incializa el número total de movimientos
	ld	hl, CurrentPlayerMov	; Apunta HL a los movimientos y al jugador actual.
	ld	a, (hl)			; Carga el valor en A.
	and	$03			; Se queda con el jugador actual.
	ld	(hl), a			; Carga el valor en memoria.

	; Inicializa los movimientos.
	ld	hl, Grid		; Apunta HL al tablero.
	ld	(hl), $00		; Pone la primera casilla a 0.
	ld	de, Grid+$01		; Apunta DE a la segunda casilla del tablero.
	ld	bc, $08			; 8 repeticiones.
	ldir				; Copia el valor de la primera casilla a las otras 8.

	call	PrintPoints		; Imprime la puntuación.

	; Comprueba si se finaliza la partida
	ld	hl, MaxPoints		; Apunta HL a los puntos necesarios para ganar la partida.

	ld	a, (PointsPlayer1)	; Carga en A los puntos del jugador 1.
	cp	(hl)			; Lo compara con los puntos necesarios para ganar la partida.
	jp	z, TresEnRaya_end	; Si son iguales, fin de partida.

	ld	a, (PointsPlayer2)	; Carga en A los puntos del jugador 1.
	cp	(hl)			; Lo compara con los puntos necesarios para ganar la partida.
	jp	z, TresEnRaya_end	; Si son iguales, fin de partida.

	ld	a, (PointsTie)		; Carga en A el número de tablas.
	cp	$10			; Lo compara 10 en BCD.
	jp	z, TresEnRaya_end	; Si son iguales, fin de partida.

	call	PrintBoard		; Imprime el tablero.

; -----------------------------------------------------------------------------
; Bucle principal del programa Tren En Raya.
;
; Altera el valor de los registros AF, BC y HL.
; -----------------------------------------------------------------------------
TresEnRaya_loop:
	call	PrintCurrentPlayer		; Imprime el jugador que juega.

	ld	a, (CurrentPlayerMov)		; Carga el jugador actual y los movimientos.
	and	$03				; Se queda con el jugador actual.
	cp	$01				; Comprueba si el jugador es el 1.
	jr	z, TresEnRaya_loop2		; Si el jugador actual es el 1, salta para que mueva.

	ld	a, (MaxPlayers)			; Carga el número de jugadores.
	cp	$02				; Comprueba si son 2 jugadores.
	jr	z, TresEnRaya_loop2		; Si son 2 jugadores, salta para que mueva el jugador 2.

	; Llega aquí si es un solo player. 
	ld	bc, SoundSpectrum		
	call	PlayMusic			; Reproduce el sonido de juega Spectrum.

	call 	SpectrumMovement		; Mueve el Spectrum.
	jr	TresEnRaya_loopEnd		; Salta al fin del bucle.

TresEnRaya_loop2:
	ld	bc, SoundNextPlayer
	call	PlayMusic			; Reproduce el sonido de jugador siguiente.

	call	WaitKeyReleased			; Espera hasta que no haya ninguna tecla pulsada.
TresEnRaya_loopContinue:
	call	WaitKeyBoard			; Espera a que se pulse una tecla del 1 a 9.
	or	a				; Comprueba si A es 0.
	jr	nz, TresEnRaya_loopEnd		; Si no es cero, ha pulsado tecla.

	call	PrintCountDown			; Imprime la cuenta atrás.
	ld	a, (SwCountDown)		; Comprueba si está activo el indicador de alarma.
	or	a
	jr	z, TresEnRaya_loopContinue2	; Si no está activo, salta.
	ld	bc, SoundCountDown		; Carga en A el tipo de sonido a reproducir.
	call	PlayMusic			; Reproduce el sonido.
	xor	a				; Pone A a 0.
	ld	(SwCountDown), a		; Lo carga en memoria.

TresEnRaya_loopContinue2:
	ld	a, (CountDown)			; Carga en A la cuenta atrás.
	or	a				; Comprueba si ha llegado a 0.
	jr	nz, TresEnRaya_loopContinue	; Si no es 0, vuelve a solicitar tecla.
	jr	TresEnRaya_lostMovement		; Si es 0, pierde turno.

TresEnRaya_loopEnd:
	ld	b, a				; Guarda el valor de A.
	call	CheckMovement			; Chequea si el movimiento es correcto.
	jr	z, TresEnRaya_cotinueMovement	; Si es correcto salta.
	call	PrintError			; Casilla ocupada.
	push	bc
	ld	bc, SoundError
	call	PlayMusic			; Reproduce el sonido de error.
	pop	bc
	call	PrintCurrentPlayer		; Imprime el jugador actual.
	jr	TresEnRaya_loop2		; Solicita movimiento.

TresEnRaya_cotinueMovement:
	ld	a, b				; Recupera el valor de A.

	call	PrintOXO			; Pinta X ú O dependiendo de jugador.

	call	ChekcWinner			; Chequea si hay ganador.
	jr	z, TresEnRaya_hasWinner		; Si salta, hay ganador.

	call	UpdatePlayerMov			; Actualiza el jugador, el número de movimientos y la cuenta atrás.

	and	$f0				; Evalúa si ya se han hecho los 9 movimientos posibles.
	cp	$90
	jr	c, TresEnRaya_loop		; Si no es así, nuevo movimiento.

	; Hay tablas.
	call	PrintTie			; Imprime el mensaje Tablas.

	ld	bc, SoundTie
	call	PlayMusic			; Reproduce el sonido de tablas.

	ld	hl, PointsTie			; Apunta HL a los puntos de tablas.
	ld	a, (hl)				; Carga los puntos en A.
	inc	a				; Incrementa un punto.
	daa					; Ajuste BCD.
	ld	(hl), a				; Lo carga en memoria.

	jp	TresEnRaya_game			; Nuevo punto.

TresEnRaya_lostMovement:
	; El jugador ha perdido el turno.
	ld	a, (CurrentPlayerMov)		; Carga el jugador y el número de movimientos.
	xor	$03				; Alterna jugador 1 y jugador 2.
	ld	(CurrentPlayerMov), a		; Lo carga en memoria.

	ld	a, (MaxSeconds)			; Carga el número de segundos por turno.
	ld	(CountDown), a			; Reincia la cuenta atrás.
	xor	a				; Pone A a 0.
	ld	(CountDownTicks), a		; Reinicia los ticks.

	call	PrintLostMovement		; Imprime pierde turno.

	ld	bc, SoundLostMovement
	call	PlayMusic				; Reproduce sonido de perdida de movimiento.

	jp	TresEnRaya_loop			; Vuelve al bucle principal.

; -----------------------------------------------------------------------------
; Hay ganador de tres en raya.
;
; Altera el valor de los registos AF, B y HL.
; -----------------------------------------------------------------------------
TresEnRaya_hasWinner:
	push	bc				; Preserva el valor del registro BC.
	call	GetCurrentPlayerInk		; Obtiene la tinta del jugador actual.
	call	SetInk				; Asigna la tinta.
	pop	bc				; Recupera el valor del registro BC.

	ld	a, c				; Carga en A la línea ganadora.
	call	PrintWinnerLine			; Imprime la línea ganadora.

	call	PrintWinner			; Imprime el ganador del punto.

	ld	bc, SoundWinGame
	call	PlayMusic			; Reproduce el sonido de ganador.

	ld	a, (CurrentPlayerMov)		; Obtiene el jugador actual y los movimientos.
	and	$03				; Se queda con el jugador.

	ld	hl, PointsPlayer1		; Apunta HL a los puntos del jugador 1.

	cp	$01				; Comprueba si el jugador actual es el 1.
	jr	z, TresEnRaya_hasWinnerContinue	; Si el jugador es el 1 salta.

	inc	hl				; Apunta HL a los puntos del jugador 2.

TresEnRaya_hasWinnerContinue:
	ld	a, (hl)				; Carga los puntos en A.
	inc	a				; Incrementa un punto.
	ld	(hl), a				; Lo carga en memoria.

	call	UpdatePlayerMov			; Actualiza el jugador y el número de movimientos.
	jp	TresEnRaya_game			; Salta para nuevo punto.

; -----------------------------------------------------------------------------
; Fin de la partida.
; -----------------------------------------------------------------------------	
TresEnRaya_end:
	call	PrintGameOver		; Pinta el mensaje de fin de partida.
	call 	DisableISR		; Deshabilita las interrupciones en modo 2.

	call	WaitKeyReleased		; Espera a que no haya ninguna tecla pulsada.
	call	WaitKeyPressed		; Espera a que se pulse una tecla.

	ld	b, INI_TOP - $15	
	call	ClearLine		; Borra la línea se mensajes.
	
	jp	TresEnRaya_menu		; Salta al menú principal.

; -----------------------------------------------------------------------------
; Imprime Espamatica.
;
; Altera el valor de los registros AF, BC y HL.
; -----------------------------------------------------------------------------
Espamatica:
	ld	a, $07
	call	SetInk				; Pone la tinta en blanco.

	ld	b, INI_TOP - $15
	ld	c, INI_LEFT - $08
	call	SetCursorPosition		; Posiciona el cursor.

	ld	hl, TitleEspamatica
	call	PrintString			; Imprime Espamatica.

	; Colorea los carácteres de Espamática.
	; Asigna valores al área de atributos de la Vídeo Ram.
	ld	a, $42				; Rojo brillo.
	ld	(VIDEOATTR+$02a0+$08), a	; E.
	ld	(VIDEOATTR+$02a0+$0c), a	; m.
	ld	(VIDEOATTR+$02a0+$10), a	; c.

	ld	a, $46				; Amarillo brillo.
	ld	(VIDEOATTR+$02a0+$09), a	; s.
	ld	(VIDEOATTR+$02a0+$0d), a	; a.
	ld	(VIDEOATTR+$02a0+$11), a	; a.

	ld	a, $44				; Verde brillo.
	ld	(VIDEOATTR+$02a0+$0a), a	; p.
	ld	(VIDEOATTR+$02a0+$0e), a	; t.

	ld	a, $45				; Azul cielo brillo.
	ld	(VIDEOATTR+$02a0+$0b), a	; a.
	ld	(VIDEOATTR+$02a0+$0f), a	; i.

	ret

; -----------------------------------------------------------------------------
; Obtiene el nombre de los jugadores.
;
; Altera el valor de los registos AF, BC, DE y HL.
; -----------------------------------------------------------------------------
GetPlayersName:
	ld	a, $04
	call	SetInk				; Asigna la tinta. Verde.

	ld	b, INI_TOP - $0f
	ld	c, INI_LEFT - $01
	call	SetCursorPosition		; Posiciona el cursor

	ld	hl, TitlePlayerName
	call	PrintString			
	ld	hl, TitlePlayerName1
	call	PrintString			; Imprime título para jugador 1.

	ld	bc, (CURSOR)			; Obtiene la posición actual del cursor.

	ld	hl, NamePlayer1			; HL = puntero a NamePlayer1.
	ld	d, $00				; D = contador de longitud del nombre, máximo 8.

	ld	a, $03
	call	SetInk				; Asigna la tinta. Magenta.

	call	GetPlayersName_getName		; Pide el nombre del jugador 1.

	ld	a, (MaxPlayers)			; Obtiene el número de jugadores.

	cp	$02				; Comprueba si son dos jugadores.
	jr	z, GetPlayersName_2		; Si son dos jugadores salta a pedir el nombre de jugador 2.

	; Un solo juagdor.
	; Copia el nombre por defecto del jugador 2.
	ld	hl, NamePlayer2Default		; HL apunta a nombre por defecto de jugador 2.
	ld	de, NamePlayer2			; DE apunta a nombre de jugador 2.
	ld	bc, $08				; Para copiar 8 carácteres.
	ldir					; Copia nombre por defecto de juagador 2 en nombre de jugador 2.

	ret

GetPlayersName_2:
	ld	a, $04
	call	SetInk				; Asigna la tinta. Verde.

	ld	b, INI_TOP - $11
	ld	c, INI_LEFT - $01
	call	SetCursorPosition		; Posiciona el cursor.

	ld	hl, TitlePlayerName
	call	PrintString			; Imprime título para jugador 1.
	ld	hl, TitlePlayerName2
	call	PrintString			; Imprime título para jugador 2.

	ld	bc, (CURSOR)			; Obtiene la posición actual del cursor.

	ld	hl, NamePlayer2			; HL = puntero a NamePlayer2.
	ld	d, $00				; D = contador de longitud del nombre, máximo 8.

	ld	a, $03
	call	SetInk				; Asigna la tinta. Magenta.

	call	GetPlayersName_getName		; Pide el nombre del jugador 2.

	ret

; Pide el nombre del jugador.
GetPlayersName_getName:
	push	hl				; Preserva el valor de HL.
	call	WaitKeyAlpha			; Espera a que se pulse una tecla. Alfanumérica, enter o delete.
	pop	hl				; Recupera el valor de HL.

	cp	KEYDEL				; Comprueba si la tecla es delete.
	jr	z, GetPlayersName_delete	; Si la tecla es Delete, salta a borrar el carácter anterior.

	cp	KEYENT				; Comprueba si la tecla es enter.
	jr	z, GetPLayersName_enter		; Si la tecla es Enter, salta a finalizar la entrada de nombre.
	
	ld	e, a				; Carga el codigo Ascii en E.

	ld	a, $08				; A = longitud máxima del nombre,
	cp	d				; D = longitud actual del nombre.
	jr	z, GetPlayersName_getName	; Si se ha llegado a la longitud máxima vuelve a solicitar tecla.
						; Opciones válidad enter o delete.

	ld	a, e				; Carga en A el código Ascii.

	ld	(hl), a				; Añade el caracter al nombre.
	inc	hl				; Avanza HL a la siguiente posición.

	rst	$10				; Imprime el carácter en pantalla.

	
	inc	d				; Aumenta el contador de longitud del nombre, máximo 8 caracteres
	jr	GetPlayersName_getName		; Vuelve para solicitar otro carácter.

GetPlayersName_delete:
	ld	a, 0				; A = 0.
	cp	d				; Comprueba si la longitud del nombre es 0.
	jr	z, GetPlayersName_getName	; Si es cero, vuelve para solicitar un carácter.

	dec	d				; Resta uno a la longitud de la cadena.

	dec	hl				; Sitúa HL en el carácter anterior.
	ld	(hl), a				; Borra el carácter anterior de la cadena. A = 0.

	ld	bc, (CURSOR)			; Recupera la posición actual del cursor.
	inc	c				; Apunta a la columna anterior.
	call	SetCursorPosition		; Posiciona el cursor.

	ld	a, ' '
	rst	$10				; Borra el carácter en pantalla.
	
	call	SetCursorPosition		; Vuelve a posicionar el cursor.

	jr	GetPlayersName_getName		; Vuelve para solicitar otro carácter.

GetPLayersName_enter:
	ld	a, 0				; A = 0.
	cp	d				; Comprueba si la longitud del nombre es 0.			
	jr	z, GetPlayersName_getName	; Si es cero, vuelve para solicitar un carácter.

	ld	(hl), a				; Pone un 0 en la posición actual para marcar fin de cadena.
	
	ret					; Fin de la toma del nombre.

; -----------------------------------------------------------------------------
; Imprime el menú.
;
; Altera del valor de los registros AF, BC y HL.
; -----------------------------------------------------------------------------
Menu:
	ld	a, $00
	call	ClearScreen			; Limpia la pantalla.
	
	ld	a, $02
	call	SetInk				; Pone la tinta en rojo.

	ld	b, INI_TOP - $00
	ld	c, INI_LEFT - $0a
	call	SetCursorPosition		; Posiciona el cursor.

	ld	hl, Title
	call	PrintString			; Imprime el título.

	; Imprime la opción 0.
	ld	a, $05
	call	SetInk				; Pone la tinta en azul cielo.

	ld	b, INI_TOP - $04
	ld	c, INI_LEFT - $08
	call	SetCursorPosition		; Posiciona el cursor.

	ld	hl, TitleOptionStart
	call	PrintString			; Imprime la opción.

	; Imprime la opción 1.
	ld	a, $06
	call	SetInk				; Pone la tinta en azul amarillo.

	ld	b, INI_TOP - $06
	call	SetCursorPosition		; Posiciona el cursor.

	ld	hl, TitleOptionPlayer
	call	PrintString			; Imprime la opción.

	; Imprime la opción 2.
	ld	b, INI_TOP - $08
	call	SetCursorPosition		; Posiciona el cursor.

	ld	hl, TitleOptionPoint
	call	PrintString			; Imprime la opción.

	; Imprime la opción 3.
	ld	b, INI_TOP - $0a
	call	SetCursorPosition		; Posiciona el cursor.

	ld	hl, TitleOptionTime
	call	PrintString			; Imprime la opción.

	call	MenuPlayers			; Imprime el número de jugadores seleccionado.
	call	MenuPoints			; Imprime el número de puntos seleccionado.
	call	MenuTime			; Imprime los segundos por turno seleccionado.

	ret

; -----------------------------------------------------------------------------
; Imprime el número de jugadores seleccionados.
;
; Altera el valor de los registros B y HL.
; -----------------------------------------------------------------------------
MenuPlayers:
	ld	b, INI_TOP - $06		; B = Coordenada Y.
	ld	hl, MaxPlayers			; HL = Número de jugadores.
	jr	MenuValuesPrint			; Salta a imprimir el valor.

; -----------------------------------------------------------------------------
; Imprime el número de puntos seleccionado.
;
; Altera el valor de los registros B y HL.
; -----------------------------------------------------------------------------
MenuPoints:
	ld	b, INI_TOP - $08		; B = Coordenada Y.
	ld	hl, MaxPoints			; HL = Número de puntos.
	jr	MenuValuesPrint			; Salta a imprimir el valor.

; -----------------------------------------------------------------------------
; Imprime los segundos seleccionados por turno.
;
; Altera el valor de los registros B y HL.
; -----------------------------------------------------------------------------
MenuTime:
	ld	b, INI_TOP - $0a		; B = Coordenada Y.
	ld	hl, MaxSeconds			; HL = Segundos por turno.

; -----------------------------------------------------------------------------
; Imprime el valor de las opciones.
;
; Altera el valor de los registros AF y C.
; -----------------------------------------------------------------------------
MenuValuesPrint:
	ld	c, INI_LEFT - $16		; C = Coordenada X.
	call	SetCursorPosition		; Posiciona el cursor.

	ld	a, $02
	call	SetInk				; Asigna la tinta. Rojo.

	call 	PrintBCD			; Imprime el valor.

	ret

; -----------------------------------------------------------------------------
; Trata la opción seleccionada en el menú
;
; Altera el valor del registro AF.
; -----------------------------------------------------------------------------
MenuOptions:
	call	WaitKeyAlpha			; Espera a que se pulse una tecla.

	; Evalúa la tecla pulsada
	cp	KEY0				; Comprueba si se ha pulsado el 0.
	ret	z				; Si se ha pulsado retorna para que empiece la partida.

	cp	KEY1				; Comprueba si se ha pulsado el 1.
	jr	z, MenuOption_players		; Si se ha pulsado salta para alterar el número de jugadores.

	cp	KEY2				; Comprueba si se ha pulsado el 2.
	jr	z, MenuOption_points		; Si se ha pulsado salta para alterar el número de puntos.
	
	cp	KEY3				; Comprueba si ha pulsado el 3.
	jr	z, MenuOption_time		; Si se ha pulsado salta para alterar el tiempo por turno.

	; Se ha pulsado otra tecla.		
	jr	MenuOptions			; Vuelta a empezar.

MenuOption_players:
	ld	a, (MaxPlayers)			; Obtiene el número de jugadores.
	xor	#03				; Lo alterna entre 1 y 2.
	ld	(MaxPlayers), a			; Carga en memoria el número de jugadores seleccionado.

	call	MenuPlayers			; Imprime el número de jugadores seleccionado.

	jr	MenuOptions			; Vuelve a las opciones.

MenuOption_points:
	ld	a, (MaxPoints)			; Obtiene el número de puntos por partida.
	inc	a				; Le suma 1.

	cp	$06				; Comprueba si el número de puntos es mayor igual a 6.
	jr	c, MenuOption_pointsEnd		; Si hay acarreo, es menor y salta.

	ld	a, $01				; Es mayor o igual, lo pone a uno.

MenuOption_pointsEnd:
	ld	(MaxPoints), a			; Carga en memoria el número de puntos seleccionado.
	call	MenuPoints			; Imprime el número de puntos seleccionado.

	jr	MenuOptions			; Vuelve a las opciones.

MenuOption_time:
	ld	a, (MaxSeconds)			; Obtiene el número de segundos por turno.
	add	a, $05				; Le suma 5.
	daa					; Normaliza A ya que son números en formato BCD.

	cp	$31				; Comprueba si los segundos son mayor o igual a 31 (BCD).
	jp	c, MenuOption_timeEnd		; Si hay acarreo, es menor y salta.

	ld	a, $05				; Es mayor o igual, lo pone a 5.

MenuOption_timeEnd:
	ld	(MaxSeconds), a			; Carga en memoria el número de segundos por turno seleccionado.
	call	MenuTime			; Imprime el número de segundos por turno seleccionado.

	jr	MenuOptions			; Vuelve a las opciones.

; -----------------------------------------------------------------------------
; Desactiva las interrupciones en modo 1.
;
; Altera el valor de los registros A, HL e I.
; -----------------------------------------------------------------------------
DisableISR:
	di		; Deshabilita las interruciones.
	im	1	; Cambia al modo 1 de interrupciones.
	ei		; Activa las interrupciones.
			; Ahora rutinas de la ROM, como la que escanea el teclado,
			; están habilitadas.
	ret

; -----------------------------------------------------------------------------
; Activa las interrupciones en modo 2.
;
; Altera el valor de los registros A, HL e I.
; -----------------------------------------------------------------------------
EnableISR:
	di				; Deshabilita las interruciones.
	ld	a, $0f
	ld	i, a			; Carga el registro I
	im 	2			; Cambia al modo 2 de interrupciones.
	ei				; Activa las interrupciones.
					; Ahora rutinas de la ROM, como la que escanea el teclado,
					; están deshabilitadas.
	ret

; Incluye el resto de ficheros del programa.
include "Declare.asm"
include "Keyboard.asm"
include "Logical.asm"
include "Rom.asm"
include "Screen.asm"
include "Sprite.asm"
include "Sound.asm"

; -----------------------------------------------------------------------------
; Controla la cuenta atrás del tiempo por turno.
; Se ejecuta cuándo las interrupciones están activas en modo 2.
; -----------------------------------------------------------------------------
org	$6d19 ; 27928	Compatibilidad con 16K
CountDownISR:
	push	af			; Preserva el valor del registro AF.
	push	bc			; Preserva el valor del registro BC.
	push	de			; Preserva el valor del registro DE.
	push	hl			; Preserva el valor del registro HL.
	push	ix			; Preserva el valor del registro IX.

	ld	hl, CountDownTicks	; Apunta HL al contador de ticks. (50*seg).
	ld	a, (hl)			; Carga el valor del contador de ticks en A.
	inc	a			; Incrementa el contador de ticks.		
	
	cp	$32			; Compra si el contador a llegado a 50.
	jr	c, CountDownISR_end	; Si no ha llegado a 50, salta.

	; Ha llegado a 50, ha pasado un segundo.
	ld	a, (CountDown)		; Carga el valor de la cuenta atrás en A.
	dec	a			; Decrementa A, resta un segundo.
	daa				; Ajuste BCD.
	ld	(CountDown), a		; Carga el valor en memoria.
	
	cp	$04			; Comprueba si quedan menos de 4 segundos.
	jr	nc, CountDownISR_reset	; Si no quedan menos de 4 segundos, salta.
	ld	a, $01
	ld	(SwCountDown), a	; Activa el indicador para que suene la alarma.

CountDownISR_reset:
	xor	a			; Pone A a 0. Reinicia el contador.			

CountDownISR_end:
	ld	(hl), a			; Carga el valor de A en el contador de ticks.

	pop	ix			; Recupera el valor del registro IX.
	pop	hl			; Recupera el valor del registro HL.
	pop	de			; Recupera el valor del registro DE.
	pop	bc			; Recupera el valor del registro BC.
	pop	af			; Recupera el valor del registro AF.
	

	ei				; Reactiva las interrupciones.
	reti				; Sale.

end $5dad