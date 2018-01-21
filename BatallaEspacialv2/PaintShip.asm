; -----------------------------------------------------------------------------
; PaintShip.asm
;
; Archivo que contiene las rutinas para pintar todo lo relacionado con la nave
; -----------------------------------------------------------------------------

; -----------------------------------------------------------------------------
; Imprime la explosión de la nave
;
; Entrada:	BC = Coordenadas de la explosión
;
; Altera el valor de los registros A, DE y HL
; -----------------------------------------------------------------------------
AnimeCrashShip:
	; Asigna color de tinta para la explosión
	LD A, 2
	CALL SetInk

	; El bucle se repite 32 veces
	LD D, 32

	; En E se calcula que gráfico, de los 4, se imprime
	LD E, 0

	; Carga la dirección de memoria del primer carácter de la explosión
	LD HL, shipCrashGraph

AnimeCrashShip_loop:
	; Posiciona el cursor
	CALL SetLocation

	; Carga en A el carácter de la explosión a pintar
	LD A, (HL)

	; Pinta el carácter
	RST $10

	PUSH BC
	PUSH HL

	; Obtiene las coordenadas actuales de la nave
	LD HL, shipCoord
	LD B, (HL)
	INC HL
	LD C, (HL)

	POP HL
	POP BC

	; Avanza a la posición de memoria del siguiente 
	INC HL

	; Incrementa E
	; Mientras sea menor de 4, no se reincia
	INC E
	LD A, E
	CP 4
	JR C, AnimeCrashShip_end

	; Si llega aquí, E = 4, vuelve a poner a 0 
	; y vuelve a cargar en HL la dirección de memoria del primer carácter de la explosión
	LD E, 0
	LD HL, shipCrashGraph

AnimeCrashShip_end:
	; Decrementa D
	DEC D

	; Retardo
	HALT

	; Mientras D != 0 sigue en el bucle
	JR NZ, AnimeCrashShip_loop

	RET

; -----------------------------------------------------------------------------
; Anima la nave.
;
; Entrada:	D	->	Animaciones a realizar.
;
;			Bit 0	->	Izquierda
;			Bit 1	->	Derecha
;			Bit 2	->	Arriba
;			Bit 3	->	Abajo
;			Bit 5	->	Disparo
;
; Altera el valor de los registros A, D y HL
; -----------------------------------------------------------------------------
AnimeShip:
	; Activa el indicador que dice que se está pintando la nave
	LD HL, flags1
	SET 0, (HL)
	
	; Obtiene la coordenada X de la nave
	LD A, (shipCoord+1)
	
	; Evalúa si se mueve a la izquierda
	BIT 0, D
	
	; Si el bit 0 está a 1, se mueve hacia la izquierda
	JR NZ, AnimeShip_left
	
	; Evalúa si se mueve a la derecha
	BIT 1, D
	
	; Si el bit 1 está a 1, se mueve hacia la derecha
	JR NZ, AnimeShip_right
	
	; Si no se mueve ni a izquierda, ni a derecha, sale
	JR AnimeShip_end
	
AnimeShip_left:
	; Comprueba si ya está en el margen izquierdo
	CP 32
	
	; Si está en el margen izquierdo, sale
	JR Z, AnimeShip_end
	
	; Incremeta en 1 la coordenda X
	INC A
	
	; Mueve la nave
	JR AnimeShip_move
	
AnimeShip_right:
	; Comprueba si ya está en el margen derecho
	CP 3
	
	; Si está en el margen derecho, sale
	JR Z, AnimeShip_end
	
	; Decremeta en 1 la coordenda X y manda a mover
	DEC A
	
AnimeShip_move:
	; Carga en D la coordenada X
	LD D, A
	
	; Borra la nave de la posición actual
	CALL DeleteShip
	
	; Carga en A la coordenda X de la nave
	LD A, D
	
	; Pone en memoria las coordenadas actuales de la nave
	LD (shipCoord+1), A
	
	; Imprime la nave
	CALL PaintShip
	
AnimeShip_end:
	RET

; -----------------------------------------------------------------------------
; Borra la nave
;
; Altera el valor del registro A
; -----------------------------------------------------------------------------
DeleteShip:
	; Posiciona el cursor en las coordenadas de la nave
	CALL LocateShip
	
	; Borra la nave
	LD A, " "
	RST $10
	
	RET

; -----------------------------------------------------------------------------
; Posiciona el cursor en la posición de la nave
;
; Altera el valor de los registros A y BC
; -----------------------------------------------------------------------------
LocateShip:
	; Carga las coordenada Y en B
	LD A, (shipCoord)
	LD B, A

	; Carga las coordenada X en B
	LD A, (shipCoord+1)
	LD C, A
	
	; Posiciona el cursor
	CALL SetLocation
	
	RET

; -----------------------------------------------------------------------------
; Pinta la nave
;
; Altera el valor del registro A
; -----------------------------------------------------------------------------
PaintShip:
	; Asigna color de tinta para la nave
	LD A, 7
	CALL SetInk

	; Posiciona el cursor en las coordenadas de la nave
	CALL LocateShip
	
	; Pinta la nave
	LD A, (shipGraph)
	RST $10
	
	; Obtiene las coordenadas actuales de la nave
	LD HL, shipCoord
	LD B, (HL)
	INC HL
	LD C, (HL)

	RET