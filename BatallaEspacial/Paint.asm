; -----------------------------------------------------------------------------
; Paint.asm
;
; Archivo que contiene las rutinas comunes para pintar en pantalla.
; -----------------------------------------------------------------------------

; -----------------------------------------------------------------------------
; Limpia la pantalla.
;
; Altera el valor de los registros A, BC, DE y HL.
; -----------------------------------------------------------------------------
ClsScreen:
	; Pone el borde en negro
	LD A, 0
	OUT ($FE), A

	; Limpia la pantalla con fondo negro, brillo y tinta según velocidad de enemigos en la pantalla 1
	LD HL, 23693
	LD A, %01000110
	LD (HL), A

	; Fondo negro, brillo y tinta blanca en la pantalla 2
	LD HL, 23624
	LD (HL), %01000111

	; Limpia la pantalla
	CALL ROMCLS

	RET

; -----------------------------------------------------------------------------
; Borra la cuenta atrás
;
; Altera el valor de los registros A y BC
; -----------------------------------------------------------------------------
DeleteCountdown:
	LD B, 14
	LD C, 18
	CALL Locate

	LD A, " "
	RST $10
	LD A, " "
	RST $10

	RET

; -----------------------------------------------------------------------------
; Obtiene la dirección de memoria del atributo del carácter (f, c) especificado.
;
; Por David Weeb
;
; Entrada:	B = Fila, C = Columna
; Salida: 	HL = Direccion del atributo
;
; Altera el valor de los registros A y HL
; -----------------------------------------------------------------------------
GetAttributeOffsetLR:
	LD A, B			; Pone en A la fila (000FFFFFb)
	RRCA
	RRCA
	RRCA			; Desplaza A 3 veces (A = A >> 3) FFF000FFb
	AND 3			; A = A AND 00000011 = los 2 bits más altos de la fila (000FFFFFb -> 000000FFb)
	ADD A, $58		; Pone los bits 15-10 como 010110b y los dos siguientes como la parte más alta de la fila
	LD H, A			; Lo carga en el byte alto de HL
	LD A, B			; Recupera de nuevo la fila en A
	AND 7			; Se queda con los dos bits que faltan
	RRCA
	RRCA
	RRCA			; Lo rota para colocarlos en su ubicación final (<<5 = >>3)
	ADD A, C		; Suma el número de columna
	LD L, A			; Lo coloca en L
	
	RET				; HL = 010110FFFFFCCCCCb

; -----------------------------------------------------------------------------
; Posiciona el cursor en pantalla.
;
; Entrada:	B = Y.
;			C = X.
; -----------------------------------------------------------------------------
Locate:
	; Preserva los registros debido a que la rutina ROMLOCATE de la ROM los altera.
	PUSH AF
	PUSH DE
	PUSH HL

	; Llama a la rutina ROMLOCATE de la ROM
	CALL ROMLOCATE

	; Restaura los registros
	POP HL
	POP DE
	POP AF
	
	RET

; -----------------------------------------------------------------------------
; Imprime el valor de números BCD
;
; Entrada:	B -> Número de bytes
;			HL -> Dirección de memoria del primer byte
;
; Altera el valor de los registros A, B y HL
; -----------------------------------------------------------------------------
PaintBCD:
	; Carga en A el código ASCII de 0 -> 00110000b
	LD A, "0"		

	; Se queda con el primer dígito, parte alta del byte
	RLD				

	; Preserva el acumulador
	PUSH AF			
	
	; Imprime el primer dígito
	RST $10			

	; Recupera el acumulador
	POP AF			

	; Se queda con el segundo dígito, parte baja del byte
	RLD

	; Preserva el acumulador
	PUSH AF			

	; Imprime el segundo dígito
	RST $10			

	; Recupera el acumulador
	POP AF			
	
	; Restablece el byte
	RLD

	; Se posiciona en el siguiente byte
	INC HL			

	; Hasta que B sea 0
	DJNZ PaintBCD	

	RET

; -----------------------------------------------------------------------------
; Pinta la cuenta atrás
;
; Altera el valor de los registros BC y HL
; -----------------------------------------------------------------------------
PaintCountdown:
	; Posiciona el cursor
	LD B, 14
	LD C, 18
	CALL Locate

	; Carga la dirección de memoria de los segundos en HL
	LD HL, seconds

	; Se debe imprimir solo un byte
	LD B, 1

	; Inprime los segundos
	CALL PaintBCD

	RET

; -----------------------------------------------------------------------------
; Pinta la información de la partida
;
; Altera el valor de los registros A, BC y HL
; -----------------------------------------------------------------------------
PaintInfoGame:
	; Abre el canal 1, para imprimir en la pantalla 2
	LD A, 1
	CALL ROMOPENCHAN
	
	; Títulos
	; Vidas
	; Posiciona el cursor
	LD B, 24
	LD C, 33
	CALL Locate
	; Carga la primera posición de memoria del título
	LD HL, livesTitle
	; Imprime el título
	CALL PaintString
	
	; Puntos
	; Posiciona el cursor, la coordenada Y se mantiene
	LD C, 25
	CALL Locate
	; Carga la primera posición de memoria del título
	LD HL, scoreTitle
	; Imprime el título
	CALL PaintString
	
	; Nivel
	; Posiciona el cursor, la coordenada Y se mantiene
	LD C, 16
	CALL Locate
	; Carga la primera posición de memoria del título
	LD HL, levelTitle
	; Imprime el título
	CALL PaintString
	
	; Enemigos
	; Posiciona el cursor, la coordenada Y se mantiene
	LD C, 9
	CALL Locate
	; Carga la primera posición de memoria del título
	LD HL, enemiesTitle
	; Imprime el título
	CALL PaintString
	
	; Valores
	; Vidas
	; Posiciona el cursor
	LD B, 23
	LD C, 30
	CALL Locate
	; Un byte
	LD B, 1
	; Carga la posición de memoria del contador
	LD HL, livesCount
	; Imprime el contador
	CALL PaintBCD

	; Puntos
	; Posiciona el cursor
	LD B, 23
	LD C, 25
	CALL Locate
	; Tres bytes
	LD B, 3
	; Carga la posición de memoria del contador
	LD HL, scoreCount
	; Imprime el contador
	CALL PaintBCD

	; Nivel
	; Posiciona el cursor
	LD B, 23
	LD C, 13
	CALL Locate
	; Un byte
	LD B, 1
	; Carga la posición de memoria del contador
	LD HL, levelCount
	; Imprime el contador
	CALL PaintBCD

	; Enemigos
	; Posiciona el cursor
	LD B, 23
	LD C, 3
	CALL Locate
	; Un byte
	LD B, 1
	; Carga la posición de memoria del contador
	LD HL, enemiesCount
	; Imprime el contador
	CALL PaintBCD

	; Abre el canal 2, para imprimir en la pantalla 1
	LD A, 2
	CALL ROMOPENCHAN
	
	RET

; -----------------------------------------------------------------------------
; Pinta el marco de la pantalla de juego
;
; Altera el valor de los registros A, BC y HL
; -----------------------------------------------------------------------------
PaintFrame:
	LD B, 24
	LD C, 33
	CALL Locate
	LD HL, frameTopGraph
	CALL PaintString

	LD B, 4
	LD C, 33
	CALL Locate
	LD HL, frameBottomGraph
	CALL PaintString

	LD B, 23
PaintFrame_loop
	LD C, 33
	CALL Locate
	
	LD A, 153
	RST $10

	LD C, 2
	CALL Locate
	
	LD A, 154
	RST $10

	DEC B
	LD A, B
	CP 4
	JR NZ, PaintFrame_loop

	RET

; -----------------------------------------------------------------------------
; Imprime cadenas terminadas en null, DB 0.
;
; Entrada:	HL	->	Primera posición de memoria de la cadena
;
; Altera el valor de los registros A y HL
; -----------------------------------------------------------------------------
PaintString:
	; Carga en A el valor de la posición de memoria que apunta a un carácter de la cadena
	LD A, (HL)

	; Si el valor es 0 se sale
	; OR A solo es 0 si A es 0
	OR A
	JR Z, PaintString_end

	; Imprime el carácter
	RST $10

	; Avanza a la posición de memoria del siguiente carácter
	INC HL

	; Siguiente iteración del bucle
	JR PaintString
	
PaintString_end:

	RET

; -----------------------------------------------------------------------------
; Asigna la tinta en baja resolución.
;
; Entrada:	BC -> Coordenadas Y, X del atributo a asignar. Tipo LOCATE ROM
;			A -> Tinta a asignar
;
; Altera el valor de los registros A, BC y HL
; -----------------------------------------------------------------------------
SetInkLR:
	PUSH AF

	; Las transforma las coordenadas en coordenadas de pantalla
	CALL LocateCoordToScreenCoord

	; Obtiene la dirección de memoria del carácter donde se ha dibujado el disparo
	CALL GetAttributeOffsetLR

	POP AF

	; Carga el valor de A en B
	LD B, A

	; Carga en A el valor actual del atributo
	LD A, (HL)

	; Se queda con flash, brillo y fondo
	AND 11111000b

	; Añade la tinta
	OR B

	; Asigna el atribuo a la dirección de memoria
	LD (HL), A

	RET