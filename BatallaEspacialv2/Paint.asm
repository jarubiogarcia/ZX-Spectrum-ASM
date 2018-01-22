; -----------------------------------------------------------------------------
; Paint.asm
;
; Archivo que contiene las rutinas comunes para pintar en pantalla.
; -----------------------------------------------------------------------------

; -----------------------------------------------------------------------------
; Limpia el área de atributos de la VideoRAM con el atributo especificado.
;
; Entrada:	A	->	Atributo especificado
;					Bits 0-2	Color de tinta
;					Bits 3-5	Color de papel
;					Bit  6		Brillo
;					Bit  7		Parpadeo
;
; Altera el valor de los registros BC, DE y HL.
; -----------------------------------------------------------------------------
ClearAttributes:
	; Carga en HL la primera dirección del área de atributos de la VideoRAM
	; y carga el atributo en ella
	LD HL, VIDEOATTR
	LD (HL), A

	; Carga en DE la segunda dirección del área de atributos de la VideoRAM
	LD DE, VIDEOATTR+1

	; Carga en BC el número de direcciones que se deben copiar
	LD BC, VIDEOATTR_L-1

	; Copia de HL a DE
	LDIR

	; Carga el atributo en la variable de sistema de atributo actual
	; y en la variable del border, que se usa para la pantalla 2 al volver
	; a BASIC
	LD (ATTR_T), A
	LD (BORDCR), A

	RET

; -----------------------------------------------------------------------------
; Limpia la pantalla.
;
; Entrada:	A	->	Patrón usado para el borrado.
;
; Altera el valor de los registros BC, DE y HL.
; -----------------------------------------------------------------------------
ClearScreen:
	; Carga en HL la primera dirección del área gráfica de la VideoRAM
	; y carga el atributo en ella
	LD HL, VIDEORAM
	LD (HL), A

	; Carga en DE la segunda dirección del área fráfica de la VideoRAM
	LD DE, VIDEORAM+1

	; Carga en BC el número de direcciones que se deben copiar
	LD BC, VIDEORAM_L-1

	; Copia de HL a DE
	LDIR

	RET

; -----------------------------------------------------------------------------
; Borra la cuenta atrás
;
; Altera el valor de los registros A y BC
; -----------------------------------------------------------------------------
DeleteCountdown:
	LD B, 14
	LD C, 18
	CALL SetLocation

	LD A, " "
	RST $10
	LD A, " "
	RST $10

	RET

; -----------------------------------------------------------------------------
; Efecto de desvanecimento de la pantalla.
;
; Altera el valor de los registros AF, BC y HL.
; -----------------------------------------------------------------------------
FadeScreen:
	; El bucle exterior se repite 8 veces, 1 por cada scanline
	LD B, 8

FadeScreen_loop1:
	; Preserva BC pues se usa en el bucle interior
	PUSH BC

	; Carga en HL la dirección de inicio del área gráfica de la VideoRAM
	LD HL, VIDEORAM
	; Carga en BC la longitud del área gráfica de la VideoRAM
	LD BC, VIDEORAM_L

FadeScreen_loop2:
	; Carga en A el byte del área gráfica de la VideoRAM apuntado por HL
	LD A, (HL)
	; Comprueba si el byte es 0 = ningún pixel activo
	CP 0
	; Si es 0, no hace nada
	JR Z, FadeScreen_save

	; Comprueba el bit 0 de la dirección de memoria apuntada por HL
	; Si es 0, es par, de lo contrario es impar
	BIT 0, L

	; Si es par salta
	JR Z, FadeScreen_right

	; Es impar; rota un bit a la izquierda
	RLA

	JR FadeScreen_save

FadeScreen_right:
	; Es par, desplaza un bit a la derecha
	SRL A

FadeScreen_save:
	; Carga el byte resultante en la posición de memoria del área gráfica de la VideoRAM
	LD (HL), A
	; Avanza a la siguiente posición de memoria  del área gráfica de la VideoRAM
	INC HL

	; Decrementa en bucle y sige hasta que BC llegue a 0
	DEC BC
	LD A, B
	OR C
	JR NZ, FadeScreen_loop2

	; Recupera el valor de B para el bucle exterior
	POP BC

	; Preserva el valor de BC porque se vuelve a usar para cambiar 
	; el área de atributos de la VideoRAM
	PUSH BC

	; Decrementa el valor de B que puede ir de 8 a 1
	; para asignar un color de tinta de 7 a 0
	DEC B

	; Carga el valor de la tinta en A
	LD A, B

	; Cambia los atributos de la pantalla
	CALL ClearAttributes

	; Recupera el valor de BC para el bucle exterior
	POP BC

	; Hasta que B llegue a 0
	DJNZ FadeScreen_loop1

FadeScreen_end:
	RET

; -----------------------------------------------------------------------------
; Imprime el valor de números BCD.
; Microficha G24, fichas de código máquina de MicroHobby.
; Se ha modificado para que no imprima los 0 no significativos.
;
; Entrada:	B	->	Número de bytes
;			HL	->	Dirección de memoria del primer byte
;
; Altera el valor de los registros A, BC, D y HL
; -----------------------------------------------------------------------------
PaintBCD:
	; C indica si los 0 son o no significativos
	LD C, 0

PaintBCD_num1:
	; Carga en A el código ASCII de 0 -> 00110000b -> 48
	LD A, "0"		

	; Se queda con el primer dígito, parte alta del byte
	RLD				
	
	; Carga en D el valor de A para hacer las comprobaciones
	LD D, A

PaintBCD_num1Test1:
	; Comprueba si los 0 ya son significativos
	; De ser así imprime el número
	BIT 0, C
	JR NZ, PaintBCD_num1Print

PaintBCD_num1Test2:
	; Comprueba si el dígito es un 0
	; Si es 0 tiene que comprobar si el la unidad
	; Si no es un 0 activa C para que indique que ya son significativos
	CP "0"
	JR Z, PaintBCD_num1Print

	LD C, 1

PaintBCD_num1Print:
	; Recupera el valor de A
	LD A, D

	; Preserva el acumulador
	PUSH AF			

	; Comprueba si es significativo
	; De no ser significativo imprime un espacio
	BIT 0, C
	JR NZ, PaintBCD_num1PrintContinue
	LD A, " "

PaintBCD_num1PrintContinue:
	; Imprime el primer dígito
	RST $10			

	; Recupera el acumulador
	POP AF			

PaintBCD_num2:
	; Se queda con el segundo dígito, parte baja del byte
	RLD

	; Carga en D el valor de A para hacer las comprobaciones
	LD D, A

PaintBCD_num2Test1:
	; Comprueba si los 0 ya son significativos
	; De ser así imprime el número
	BIT 0, C
	JR NZ, PaintBCD_num2Print

PaintBCD_num2Test2:
	; Comprueba si el dígito es un 0
	; Si es 0 tiene que comprobar si el la unidad
	; Si no es un 0 activa C para que indique que ya son significativos
	CP "0"
	JR Z, PaintBCD_num2Test3

	LD C, 1
	JR NZ, PaintBCD_num2Print

PaintBCD_num2Test3:
	; Comprueba si es la unidad B = 1
	; Si es la unidad activa C para que indique que es significativo
	; Si no es la unidad, salta a imprimir para que imprima un blanco
	LD A, B
	CP 1
	JR NZ, PaintBCD_num2Print

	LD C, 1

PaintBCD_num2Print:
	; Recupera el valor de A
	LD A, D

	; Preserva el acumulador
	PUSH AF			

	; Comprueba si es significativo
	; De no ser significativo imprime un espacio
	BIT 0, C
	JR NZ, PaintBCD_num2PrintContinue
	LD A, " "

PaintBCD_num2PrintContinue:
	; Imprime el segundo dígito
	RST $10			

	; Recupera el acumulador
	POP AF			
	
	; Restablece el byte
	RLD

	; Se posiciona en el siguiente byte
	INC HL			

	; Hasta que B sea 0
	DJNZ PaintBCD_num1	

	RET

; -----------------------------------------------------------------------------
; Pinta la cuenta atrás
;
; Altera el valor de los registros BC y HL
; -----------------------------------------------------------------------------
PaintCountdown:
	; Asigna la tinta para la cuenta atrás
	LD A, 3
	CALL SetInk

	; Posiciona el cursor
	LD B, 14
	LD C, 18
	CALL SetLocation

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
	CALL OPENCHAN

	; Asigna los atributos de flash, brillo, paper y tinta
	; Es necesario pues la variable de sistema interfiere con la del borde
	LD A, %00000011
	LD (ATTR_T), A

	; Títulos
	; Vidas

	; Posiciona el cursor
	LD B, 24
	LD C, 33
	CALL SetLocation

	; Carga la primera posición de memoria del título
	LD HL, livesTitle

	; Imprime el título
	CALL PaintString
	
	; Puntos
	; Posiciona el cursor, la coordenada Y se mantiene
	LD C, 25
	CALL SetLocation

	; Carga la primera posición de memoria del título
	LD HL, scoreTitle

	; Imprime el título
	CALL PaintString
	
	; Nivel
	; Posiciona el cursor, la coordenada Y se mantiene
	LD C, 16
	CALL SetLocation

	; Carga la primera posición de memoria del título
	LD HL, levelTitle

	; Imprime el título
	CALL PaintString
	
	; Enemigos
	; Posiciona el cursor, la coordenada Y se mantiene
	LD C, 9
	CALL SetLocation

	; Carga la primera posición de memoria del título
	LD HL, enemiesTitle

	; Imprime el título
	CALL PaintString

	; Valores
	; Vidas
	; Asigna los atributos de flash, brillo, paper y tinta
	; Es necesario pues la variable de sistema interfiere con la del borde
	LD A, %00000111
	LD (ATTR_T), A

	; Posiciona el cursor
	LD B, 23
	LD C, 30
	CALL SetLocation

	; Un byte
	LD B, 1

	; Carga la posición de memoria del contador
	LD HL, livesCount

	; Imprime el contador
	CALL PaintBCD

	; Puntos
	; Asigna los atributos de flash, brillo, paper y tinta
	; Es necesario pues la variable de sistema interfiere con la del borde
	LD A, %00000110
	LD (ATTR_T), A

	; Posiciona el cursor
	LD B, 23
	LD C, 25
	CALL SetLocation

	; Tres bytes
	LD B, 3

	; Carga la posición de memoria del contador
	LD HL, scoreCount

	; Imprime el contador
	CALL PaintBCD

	; Nivel
	; Asigna los atributos de flash, brillo, paper y tinta
	; Es necesario pues la variable de sistema interfiere con la del borde
	LD A, %00000101
	LD (ATTR_T), A

	; Posiciona el cursor
	LD B, 23
	LD C, 13
	CALL SetLocation

	; Un byte
	LD B, 1

	; Carga la posición de memoria del contador
	LD HL, levelCount

	; Imprime el contador
	CALL PaintBCD

	; Enemigos
	; Asigna los atributos de flash, brillo, paper y tinta
	; Es necesario pues la variable de sistema interfiere con la del borde
	LD A, %01000010
	LD (ATTR_T), A

	; Posiciona el cursor
	LD B, 23
	LD C, 3
	CALL SetLocation

	; Un byte
	LD B, 1

	; Carga la posición de memoria del contador
	LD HL, enemiesCount

	; Imprime el contador
	CALL PaintBCD

	; Asigna los atributos de flash, brillo, paper y tinta
	; Es necesario pues la variable de sistema interfiere con la del borde
	LD A, %01000111
	LD (ATTR_T), A
	LD (ATTR_S), A

	; Abre el canal 2, para imprimir en la pantalla 1
	LD A, 2
	CALL OPENCHAN
	
	RET

; -----------------------------------------------------------------------------
; Pinta el marco de la pantalla de juego
;
; Altera el valor de los registros A, BC y HL
; -----------------------------------------------------------------------------
PaintFrame:
	; Asigna la tinta al marco
	LD A, 1
	CALL SetInk

	LD B, 24
	LD C, 33
	CALL SetLocation
	LD HL, frameTopGraph
	CALL PaintString

	LD B, 4
	LD C, 33
	CALL SetLocation
	LD HL, frameBottomGraph
	CALL PaintString

	LD B, 23
PaintFrame_loop
	LD C, 33
	CALL SetLocation
	
	LD A, 153
	RST $10

	LD C, 2
	CALL SetLocation
	
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
; Cambia el color del borde
;
; Entrada:	A	->	Color para el borde
;
; Altera el valor del registro AF.
; -----------------------------------------------------------------------------
SetBorder:
	; Preserva los registros
	PUSH BC

	; Se queda solo con el color
	AND %00000111

	; Cambia el color del borde
	OUT ($FE), A

	; Rota 3 bits a la izquerda para poner en bits de PAPER
	RLCA
	RLCA
	RLCA

	; Carga el color en B
	LD B, A

	; Recupera la variable de sistema BORDCR
	LD A, (BORDCR)

	; Desecha los bits del BORDER
	AND %11000111

	; Asigna el color del borde
	OR B

	; Carga el valor en la variable de sistema BORDCR. 
	; Si no se guarda y se usa BEEPER, el borde se pone a 0.
	LD (BORDCR), A

	; Recupera los registros
	POP BC

	RET

; -----------------------------------------------------------------------------
; Asigna la tinta en baja resolución.
;
; Entrada:	A -> Tinta a asignar
;
; Altera el valor de los registro A.
; -----------------------------------------------------------------------------
SetInk:
	; Preserva los registros
	PUSH BC

	; Se queda con el color de tinta y la carga en B
	AND %00000111
	LD B, A

	; Recupera la variable de sistema del atributo actual y desecha la tinta
	LD A, (ATTR_T)
	AND %11111000

	; Pone la tinta y actualiza la variables de sistema del atributo actual
	OR B
	LD (ATTR_T), A

	; Recupera los registros
	POP BC

	RET

; -----------------------------------------------------------------------------
; Posiciona el cursor en pantalla.
;
; Entrada:	B = Y.
;			C = X.
; -----------------------------------------------------------------------------
SetLocation:
	; Preserva los registros debido a que la rutina ROMLOCATE de la ROM los altera.
	PUSH AF
	PUSH DE
	PUSH HL

	; Llama a la rutina LOCATE de la ROM
	CALL LOCATE

	; Restaura los registros
	POP HL
	POP DE
	POP AF
	
	RET