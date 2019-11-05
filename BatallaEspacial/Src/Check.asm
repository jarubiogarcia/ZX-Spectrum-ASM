;------------------------------------------------------------------------------
; Check.asm
;
; Contiene las rutinas de comprobación
;------------------------------------------------------------------------------

;------------------------------------------------------------------------------
; Evalúa si se ha producido alguna colisión
;
; Destruye el valor de los registros A, BC, DE y HL
;------------------------------------------------------------------------------
CheckCrash:
	; Carga en A los indicadores 1
	; Evalúa si el disparo está activo, bit 1
	LD A, (flags1)
	BIT 1, A

	; Si el disparo no está activo comprueba si hay colisión con la nave
	JP Z, CheckCrash_ship

	; Obtiene el número de enemigos
	LD B, enemiesConfigIni  - enemiesConfig
	
	; Divide entre dos, hay dos bytes por enemigo
	SRA B
	
	; Obtiene la dirección de memoria de la coordenada Y del primer enemigo
	LD HL, enemiesConfig
	
	; Evalúa si hay alguna colisión
	CALL CheckCrash_fireEnemies
	
	; Comprueba si hay colisión con la nave
	JP CheckCrash_ship

;------------------------------------------------------------------------------
; Evalúa si hay colisión entre el disparo y algún enemigo	
;------------------------------------------------------------------------------
CheckCrash_fireEnemies:
	; Carga en A la coordenada Y del disparo
	LD A, (fireCoord)

	; La carga en D
	LD D, A
	
	; Carga en A la coordenada Y del enemigo
	; También contiene si el enemigo está activo
	LD A, (HL)
	
	; Comprueba si el enemigo está activo, y si no lo está salta
	BIT 7, A
	JR Z, CheckCrash_fireEnemiesNoCrash
	
	; Se queda con la coordenada Y del enemigo
	AND %00011111
	
	; Lo compara con la coordenada Y del disparo y si no son iguales, salta
	CP D
	JR NZ, CheckCrash_fireEnemiesNoCrash
	
	; Como las coordenadas Y son las mismas, compara las coordenadas X
	; Carga la coordenada X del disparo en A
	LD A, (fireCoord+1)
	
	; La carga en D
	LD D, A
	
	; Avanza a la posición de memoria de la coordenada X del enemigo y la carga en A
	INC HL
	LD A, (HL)
	
	; Se queda con la coordenada X del enemigo, ya que también tiene los indicadores de dirección de movimiento
	AND %00111111
	
	; Lo compara con la coordenada X del disparo y si no son iguales, salta
	CP D
	JR NZ, CheckCrash_fireEnemiesLoop
	
	; Son iguales
	; Vuelve a la posición de memoria de la coordenada Y del enemigo
	DEC HL
	
	; Desactiva al enemigo
	RES 7, (HL)

	; Suena la exploxión del enemigo
	CALL EnemiesCrashSound

	; Carga los flags y desactiva el disparo
	LD A, (flags1)
	RES 1, A

	; Resta un enemigo y suma cinco puntos
	LD A, (enemiesCount)
	DEC A
	DAA ; Intrucción necesaria siempre que se opera con nómeros BCD
	LD (enemiesCount), A

	; Suma 5 puntos en el byte 3 de la puntuación. Importante sumar en hexadecimal (entre $00 y $99)
	; Aunque el valor de 5 decimal y hexadecimal son el mismo, se pone en hexadecimal por clarifical
	; que se trabaja con nómeros en formaro BCD
	LD A, (scoreCount+2)
	ADD A, $05
	DAA ; Intrucción necesaria siempre que se opera con números BCD
	LD (scoreCount+2), A

	; Hace suma con acarreo en el byte 2 de la puntuación
	LD A, (scoreCount+1)
	ADC A, 0
	DAA ; Intrucción necesaria siempre que se opera con números BCD
	LD (scoreCount+1), A

	; Hace suma con acarreo en el byte 1 de la puntuación
	LD A, (scoreCount)
	ADC A, 0
	DAA ; Intrucción necesaria siempre que se opera con números BCD
	LD (scoreCount), A

	; Añade 5 puntos al contador para ver si da una vida extra
	; En este caso no se trabaja con números BCD pués no se va a imprimir
	LD HL, (livesExtra)
	LD BC, 5
	ADD HL, BC
	LD (livesExtra), HL
	
	; Si se ha llegado a 500, se da una vida extra y se pone a 0 el contador para vida extra
	; Para que se llegue a 500 el byte superior de livesExtra debe valer $01 y el inferior $F4
	LD A, H
	CP $01
	JR NZ, CheckCrash_fireEnemiesCrash

	LD A, L
	CP $F4
	JR NZ, CheckCrash_fireEnemiesCrash

	; Se pone el contador de vida extra a 0	
	LD HL, 0
	LD (livesExtra), HL

	; Se da una vida extra. livesCount es un número BCD pués se imprime
	LD A, (livesCount)
	ADD A, $01
	DAA ; Intrucción necesaria siempre que se opera con números BCD
	LD (livesCount), A

CheckCrash_fireEnemiesCrash:
	; Refresca la información de la partida
	PUSH BC
	PUSH HL
	CALL PaintInfoGame
	POP HL
	POP BC

	; Termina la comprobación de colisión entre enemigo y disparo
	JR CheckCrash_fireEnemiesEnd
	
CheckCrash_fireEnemiesNoCrash:	
	; Avanza hasta la posición de memoria de la coordenada X del enemigo
	INC HL
	
CheckCrash_fireEnemiesLoop:
	; Avanza hasta la posición de memoria de la coordenada Y del siguiente enemigo
	INC HL
	
	; Sigue en el bucle hasta que el contador de enemigos sea 0
	DEC B
	JR NZ, CheckCrash_fireEnemies

CheckCrash_fireEnemiesEnd:
	; Ha terminado la comprobación de colisión entre disparo y enemigos
	RET

;------------------------------------------------------------------------------
; Evalúa si hay colisión entre la nave y algún enemigo	
;------------------------------------------------------------------------------
CheckCrash_ship:
	; Carga en A la coordenada Y de la nave
	LD A, (shipCoord)
	
	; La carga en D
	LD D, A
	
	; Carga en A la coordenada X de la nave
	LD A, (shipCoord+1)
	
	; La carga en E
	LD E, A
	
	; Obtiene el número de enemigos
	LD B, enemiesConfigIni  - enemiesConfig
	
	; Divide entre dos, hay dos bytes por enemigo
	SRA B
	
	; Obtiene la dirección de memoria de la coordenada Y del primer enemigo
	LD HL, enemiesConfig
	
	; Evalúa si hay alguna colisión
	CALL CheckCrash_shipEnemies

	RET

CheckCrash_shipEnemies:
	; Carga en A la coordenada Y del enemigo
	; También contiene si el enemigo está activo
	LD A, (HL)
	
	; Comprueba si el enemigo está activo, y si no lo está salta
	BIT 7, A
	JR Z, CheckCrash_shipEnemiesNoCrash
	
	; Se queda con la coordenada Y del enemigo
	AND %00011111
	
	; Lo compara con la coordenada Y de la nave y si no son iguales, salta
	CP D
	JR NZ, CheckCrash_shipEnemiesNoCrash
	
	; Como las coordenadas Y son las mismas, compara las coordenadas X
	; Avanza a la posición de memoria de la coordenada X del enemigo y la carga en A
	INC HL
	LD A, (HL)
	
	; Se queda con la coordenada X del enemigo, también contiene los indicadores de dirección del movimiento
	AND %00111111
	
	; Lo compara con la coordenada X de la nave y si no son iguales, salta
	CP E
	JR NZ, CheckCrash_shipEnemiesLoop
	
	; Son iguales
	; Vuelve a la posición de memoria de la coordenada Y del enemigo
	DEC HL
	
	; Restaura los ciclos a pasar para animar a los enemigos
	LD A, 5
	LD (enemiesCiclesMax), A
	LD (enemiesCiclesCount), A

	; Restaura el tiempo a pasar para el cambio de velocidad de los enemigos
	LD A, 0
	LD (ticks), A
	LD (seconds), A

	; Desactiva el enemigo
	RES 7, (HL)

	; Resta un enemigo y una vida
	LD A, (enemiesCount)
	SUB $1
	DAA ; Intrucción necesaria siempre que se opera con números BCD
	LD (enemiesCount), A

	LD A, (livesCount)
	SUB $1
	DAA ; Intrucción necesaria siempre que se opera con números BCD
	LD (livesCount), A

	; Borra el disparo
	CALL DeleteFire

	; Carga las coordenadas de la nave en BC
	LD B, D
	LD C, E

	; Sonido de explosión de la nave
	CALL ShipCrashSound

	; Anima la explosión de la nave
	CALL AnimeCrashShip

	; Si no hay vidas se sale
	CP 0
	JR Z, CheckCrash_shipEnemiesEnd

	; Imprime la información de la partida
	CALL PaintInfoGame
		
	; Imprime la nave
	CALL PaintShip

	; Limpia los enemigos
	CALL DeleteEnemies

	; Reinicia las posiciones de los enemigos
	CALL ResetActiveEnemiesConfig

	; Reinicia la dirección de movimiento de los enemigos
	CALL ResetEnemiesDir

	; Sale del bucle
	JR CheckCrash_shipEnemiesEnd
	
CheckCrash_shipEnemiesNoCrash:	
	; Avanza hasta la posición de memoria de la coordenada X del enemigo
	INC HL

CheckCrash_shipEnemiesLoop:
	; Avanza hasta la posición de memoria de la coordenada Y del siguiente enemigo
	INC HL
	
	; Sigue en el bucle hasta que el contador de enemigos sea 0
	DEC B
	JR NZ, CheckCrash_shipEnemies

CheckCrash_shipEnemiesEnd:
	; Ha terminado la comprobación de colisión entre disparo y enemigos
	RET

; -----------------------------------------------------------------------------
; Evalúa si se ha pulsado alguna de la teclas de dirección.
; Las teclas de dirección son:
;	Z 	->	Izquierda
;	X 	->	Derecha
;	V	->	Disparo
; También compatibilidad con joystick Sinclair 1, Sinclair 2 o Kempston.
;
; Retorna:	D	->	Teclas pulsadas.
;			Bit 0	->	Izquierda
;			Bit 1	->	Derecha
;			Bit 2	->	Arriba
;			Bit 3	->	Abajo
;			Bit 5	->	Disparo
;
; Altera el valor de los registros A, B y HL
; -----------------------------------------------------------------------------
CheckKey:
	; Reinicia D
	LD D, 0
	
	; Carga los flags para comprobar el tipo de controles
	LD A, (flags1)
	; Se queda con los flags de los controles
	AND $C0

CheckKey_keyboard:
	; Comprueba si los controles son el teclado
	CP $00
	; Si no se ha seleccionado el teclado, salta
	JR NZ, CheckKey_sinclair1
	; Lee el teclado
	LD A, $FE
	CALL GetKey

CheckKey_keyboard_Fire:
	; Comprueba si se ha pulsado el disparo
	BIT 4, A
	; Si no se ha pulsado el disparo salta
	JR Z, CheckKey_keyboard_Right
	; Activa el bit del disparo
	SET 2, D

CheckKey_keyboard_Right:	
	; Comprueba si se ha pulsado derecha
	BIT 2, A
	; Si no se ha pulsado el disparo salta
	JR Z, CheckKey_keyboard_Left
	; Activa el bit de derecha
	SET 1, D

CheckKey_keyboard_Left:
	; Comprueba si se ha pulsado izquierda
	BIT 1, A
	; Si no se ha pulsado el disparo salta
	JR Z, CheckKey_continue
	; Activa el bit de izquierda
	SET 0, D
	JR CheckKey_continue

CheckKey_sinclair1:
	; Comprueba si los controles son joystick sinclair 1
	CP $80
	; Si no se la seleccionado sinclair 1, salta
	JR NZ, CheckKey_sinclair2
	; Lee el teclado
	LD A, $EF
	CALL GetKey

CheckKey_sinclair1_Fire:
	; Comprueba si se ha pulsado el disparo
	BIT 0, A
	; Si no se ha pulsado el disparo salta
	JR Z, CheckKey_sinclair1_Right
	; Activa el bit del disparo
	SET 2, D

CheckKey_sinclair1_Right:	
	; Comprueba si se ha pulsado derecha
	BIT 3, A
	; Si no se ha pulsado el disparo salta
	JR Z, CheckKey_sinclair1_Left
	; Activa el bit de derecha
	SET 1, D

CheckKey_sinclair1_Left:
	; Comprueba si se ha pulsado izquierda
	BIT 4, A
	; Si no se ha pulsado izquierda salta
	JR Z, CheckKey_continue
	; Activa el bit de izquierda
	SET 0, D
	JR CheckKey_continue

CheckKey_sinclair2:
	; Comprueba si los controles son joystick sinclair 2
	CP $C0
	; Si no se la seleccionado sinclair 1, salta
	JR NZ, CkeckKey_kempston
	; Lee el teclado
	LD A, $F7
	CALL GetKey

CheckKey_sinclair2_Fire:
	; Comprueba si se ha pulsado el disparo
	BIT 4, A
	; Si no se ha pulsado el disparo salta
	JR Z, CheckKey_sinclair2_Right
	; Activa el bit del disparo
	SET 2, D

CheckKey_sinclair2_Right:	
	; Comprueba si se ha pulsado derecha
	BIT 1, A
	; Si no se ha pulsado el disparo salta
	JR Z, CheckKey_sinclair2_Left
	; Activa el bit de derecha
	SET 1, D

CheckKey_sinclair2_Left:
	; Comprueba si se ha pulsado izquierda
	BIT 0, A
	; Si no se ha pulsado izquierda salta
	JR Z, CheckKey_continue
	; Activa el bit de izquierda
	SET 0, D
	JR CheckKey_continue

CkeckKey_kempston:
	; Lee el puerto del Joystick Kempston
	;;LD BC, $1F
	IN A, ($1F)

CheckKey_kempston_Fire:
	; Comprueba si se ha pulsado el disparo
	BIT 4, A
	; Si no se ha pulsado el disparo salta
	JR Z, CheckKey_kempston_Right
	; Activa el bit del disparo
	SET 2, D

CheckKey_kempston_Right:	
	; Comprueba si se ha pulsado derecha
	BIT 0, A
	; Si no se ha pulsado el disparo salta
	JR Z, CheckKey_kempston_Left
	; Activa el bit de derecha
	SET 1, D

CheckKey_kempston_Left:
	; Comprueba si se ha pulsado izquierda
	BIT 1, A
	; Si no se ha pulsado el disparo salta
	JR Z, CheckKey_continue
	; Activa el bit de izquierda
	SET 0, D

CheckKey_continue:
	; Carga los controles pulsado en A
	LD A, D
	; Comprueba si se ha pulsado algo
	OR A
	; Si no se ha pulsado ninguna tecla, se va
	RET Z
	
CheckKey_fire:
	; Comprueba si se ha pulsado el disparo
	BIT 2, A
	
	; Si no se ha pulsado, sale
	JR Z, CheckKey_end
	
	; Comprueba si el disparo ya está activo, el bit 1 a 1
	; En el caso de que no está activo hay que activarlo y posicionarlo donde está la nave
	LD HL, flags1
	LD B, (HL)
	BIT 1, B
	JR NZ, CheckKey_end
	
	; Activa el fuego y asigna a coordenada Y inicial y lo pone en memoria
	SET 1, (HL)

	LD HL, fireCoordIni
	LD B, (HL)
	LD HL, fireCoord
	LD (HL), B
	
	; Preserva AF pues se utilza A
	PUSH AF
	
	; Carga la coordenada X de la nave
	LD A, (shipCoord+1)
	
	; Pone en memoria la coordenada X del disparo
	LD (fireCoord+1), A
	
	; Hay que imprimir el disparo
	CALL PaintFire
	
	; Hay que hacer sonar el disparo
	CALL FireSound

	; Restaura AF
	POP AF

CheckKey_end:
	; Se queda solo con los bit de izquierda y derecha
	AND %00000011
	
	; Comprueba si están los dos activos
	CP 3
	
	; Si no están lo dos activos, sale
	RET NZ
	
	; Desactiva los bits de izquierda y derecha por estar los dos activos
	AND $04
	LD D, A
	
	RET

; -----------------------------------------------------------------------------
; Lee las pulsaciones del teclado de la semifila especificada
; 
; Entrada:	A -> Semifila a leer.
;
; Salida:	A -> Teclas pulsadas.
; -----------------------------------------------------------------------------
GetKey:
	; Lee el puerto del teclado
	IN A, ($FE)
	
	; Invierte los bits para que los pulsados queden a 1
	CPL

	RET

; -----------------------------------------------------------------------------
; Selección de los controles para jugar.
;	1 = Teclado, 2 = Kempston, 3 = Sinclair 1, 4 = Sinclair 2
;
; Altera el valor de de los bits 6 y 7 flags1 y de los registros A y D
; -----------------------------------------------------------------------------
SelectControls:
	; Carga en A la semifila 1-5.
	LD A, $F7

	; Obtiene las teclas pulsadas
	CALL GetKey

	; Usa D para almacenar temporalmente la opción
SelectControls_keys:
	; Comprueba si se han seleccionado teclas
	BIT $00, A
	JR Z, SelectControls_kempston
	LD D, $00
	JR SelectControls_end

SelectControls_kempston:
	; Comprueba si se ha seleccionado joystick kempston
	BIT $01, A
	JR Z, SelectControls_sinclair1
	LD D, $40
	JR SelectControls_end

SelectControls_sinclair1:
	; Comprueba si se ha seleccionado joystick sinclair 1
	BIT $02, A
	JR Z, SelectControls_sinclair2
	LD D, $80
	JR SelectControls_end

SelectControls_sinclair2:
	; Comprueba si se ha seleccionado joystick sinclair 2
	BIT $03, A
	JR Z, SelectControls
	LD D, $C0

SelectControls_end:
	LD A, (flags1)  ; Obtiene los flags
	AND $3F		; Omite los flags de los controles
	OR D		; Agrega los flags de los controles
	LD (flags1), A	; Actualiza flags en memoria
	RET

; -----------------------------------------------------------------------------
; Espera la pulsación de la tecla Enter
;
; Salida:	A -> Tecla pulsada
; -----------------------------------------------------------------------------
WaitKey:
	; Carga en A la semifila ENTER-H
	LD A, $BF

	; Obtiene las teclas pulsadas
	CALL GetKey

	; Comprueba si se ha pulsado Enter. Importante pues varía según ISSUE
	AND %00000001
	
	; Si se ha pulsado Enter sale
	JR Z, WaitKey
	
	RET