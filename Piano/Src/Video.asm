; -----------------------------------------------------------------------------
; Video.asm
;
; Rutinas relacionadas con la pantalla.
;
; Al usar la rutina locate de la ROM, la esquina superior izquierda son las 
; coordenadas Y = 24 ($18), X = 33 ($21).
;
; La pantalla queda dividida en 2, la parte superior Y = 24 hasta 3
; y la parte inferior Y = 24 hasta 23. Las demás líneas provocan scroll.
; La parte superior es donde se introducen los comandos desde BASIC.
;
; Las columnas van de 33 a 1.
;
; Los atributos de color son carácter a caráter y se codifican así:
; Bit 7 = Flash 0/1
; Bit 6 = Brillo 0/1
; Bits 5, 4, 3 = Paper y Border 0 a 7
; Bits 2, 1, 0 = Ink 0 a 7
; -----------------------------------------------------------------------------

; -----------------------------------------------------------------------------
; Limpia el área de atributos de la VideoRAM con el atributo especificado.
;
; Entrada:	A	->	Atributo especificado
;
; bit 7 = Flash 1/0
; bit 6 = Bright 1/0
; bits 5, 4, 3 = Paper de 0 a 7
; bits 2, 1, 0 = Ink de 0 a 7
; -----------------------------------------------------------------------------
ClearAttributes:
	; Preserva el valor de los registros
	PUSH BC
	PUSH DE
	PUSH HL

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

	; Recupera el valor de los registros
	POP HL
	POP DE
	POP BC

	RET

; -----------------------------------------------------------------------------
; Limpia el área gráfica de la VideoRAM con el patrón especificado.
;
; Entrada:	A	->	Patrón especificado, patrón de píxeles. 0 = borrar
; -----------------------------------------------------------------------------
ClearScreen:
	; Preserva el valor de los registros
	PUSH BC
	PUSH DE
	PUSH HL

	; Carga en HL la primera dirección del área gráfica de la VideoRAM
	; y carga el atributo en ella
	LD HL, VIDEORAM
	LD (HL), A

	; Carga en DE la segunda dirección del área gráfica de la VideoRAM
	LD DE, VIDEORAM+1

	; Carga en BC el número de direcciones que se deben copiar
	LD BC, VIDEORAM_L-1

	; Copia de HL a DE
	LDIR

	; Recupera el valor de los registros
	POP HL
	POP DE
	POP BC

	RET

; ------------------------------------------------------------------------------
; Pinta la pantalla
;
; Altera el valor de los registros A, BC, DE y HL
; ------------------------------------------------------------------------------
PrintScreen:
	; Pone tinta blanca y fondo azul para pantalla 2
	; La pantalla 2 son las dos últimas líneas de la pantalla
	LD A, $0F
	LD (BORDCR), A
	
	; Pone el borde en azul
	LD A, $01
	CALL SetBorder
	
	; Pone el fondo en azul y la tinta en rojo
	LD A, $0A
	CALL ClearAttributes
	
	; Limpia la pantalla
	LD A, $00
	CALL ClearScreen
	
	; Carga los gráficos definidos por el usuario
	LD HL, _udgs
	LD (UDG), HL
	
printTitle:
	; Situal el cursor
	LD B, $18
	LD C, $18
	CALL SetLocation
	
	; Imprime el título
	LD HL, _title
	CALL PrintString

printPiano:
	; Impime la parte superior del piano
	; Se imprimen ocho líneas iguales
	LD D, $08
	
	; Desde Y = $14 (20), X = $1F (31)
	LD B, $14
	LD C, $1F
	
printPianoUp_loop:
	; Posiciona el cursor
	CALL SetLocation
	
	; Cambia la tinta a blanco
	LD A, $07
	CALL SetInk
	
	; RST $10 imprime el ascii cargado en A en la posición actual del cursor
	LD A, $90
	RST $10
	
	LD A, $91
	RST $10
	
	LD A, $92
	RST $10
	
	; Cambia la tinta a negro
	LD A, $00
	CALL SetInk
	
	LD A, $91
	RST $10
	
	LD A, $91
	RST $10
	
	; Cambia la tinta a blanco
	LD A, $07
	CALL SetInk
	
	LD A, $90
	RST $10
	
	LD A, $92
	RST $10
	
	; Cambia la tinta a negro
	LD A, $00
	CALL SetInk
	
	LD A, $91
	RST $10
	
	LD A, $91
	RST $10
	
	; Cambia la tinta a blanco
	LD A, $07
	CALL SetInk
	
	LD A, $90
	RST $10
	
	LD A, $91
	RST $10
	
	LD A, $92
	RST $10
	
	LD A, $90
	RST $10
	
	LD A, $91
	RST $10
	
	LD A, $92
	RST $10
	
	; Cambia la tinta a negro
	LD A, $00
	CALL SetInk
	
	LD A, $91
	RST $10
	
	LD A, $91
	RST $10
	
	; Cambia la tinta a blanco
	LD A, $07
	CALL SetInk
	
	LD A, $90
	RST $10
	
	LD A, $92
	RST $10
	
	; Cambia la tinta a negro
	LD A, $00
	CALL SetInk
	
	LD A, $91
	RST $10
	
	LD A, $91
	RST $10
	
	; Cambia la tinta a blanco
	LD A, $07
	CALL SetInk
	
	LD A, $90
	RST $10
	
	LD A, $92
	RST $10
	
	; Cambia la tinta a negro
	LD A, $00
	CALL SetInk
	
	LD A, $91
	RST $10
	
	LD A, $91
	RST $10
	
	; Cambia la tinta a blanco
	LD A, $07
	CALL SetInk
	
	LD A, $90
	RST $10
	
	LD A, $91
	RST $10
	
	LD A, $92
	RST $10
	
	; Sitúa B en la siguiente línea. Y = B
	DEC B
	
	; Mientras D no llegue a 0
	DEC D
	JP NZ, printPianoUp_loop

; Impime la parte inferior del piano, compuesta de 1 + 2 líneas
printDownPiano:
	; Cambia la tinta a blanco
	LD A, $07
	CALL SetInk
	
	; Posiciona el cursor. 
	; B ya está en la línea siguiente por la última iteración
	; del dibujado de la parte superior. Y = B
	CALL SetLocation
	
	; RST $10 imprime el ascii cargado en A en la posición actual del cursor
	LD A, $90
	RST $10
	
	LD A, $91
	RST $10
	
	LD A, $93
	RST $10
	
	LD A, $94
	RST $10
	
	LD A, $95
	RST $10
	
	LD A, $96
	RST $10
	
	LD A, $93
	RST $10
	
	LD A, $94
	RST $10
	
	LD A, $95
	RST $10
	
	LD A, $96
	RST $10
	
	LD A, $91
	RST $10
	
	LD A, $92
	RST $10
	
	LD A, $90
	RST $10
	
	LD A, $91
	RST $10
	
	LD A, $93
	RST $10
	
	LD A, $94
	RST $10
	
	LD A, $95
	RST $10
	
	LD A, $96
	RST $10
	
	LD A, $93
	RST $10
	
	LD A, $94
	RST $10
	
	LD A, $95
	RST $10
	
	LD A, $96
	RST $10
	
	LD A, $93
	RST $10
	
	LD A, $94
	RST $10
	
	LD A, $95
	RST $10
	
	LD A, $96
	RST $10
	
	LD A, $91
	RST $10
	
	LD A, $92
	RST $10
	
	; Sitúa B en la siguiente línea. Y = B
	DEC B

	; Imprime las dos últimas líneas del piano
	LD D, $02	
printDownPiano_loop:
	CALL SetLocation
	
	; Está dos líneas están formadas por 7 repeticiones de un mismo patrón
	LD E, $07
printDownPiano_loop2:
	; RST $10 imprime el ascii cargado en A en la posición actual del cursor
	LD A, $90
	RST $10
	
	LD A, $91
	RST $10
	
	LD A, $91
	RST $10
	
	LD A, $92
	RST $10

	; Mientras E no llegue a 0
	DEC E
	JR NZ, printDownPiano_loop2
	
	; Sitúa B en la siguiente línea. Y = B
	DEC B
	
	; Mientras D no llegue 0
	DEC D
	JR NZ, printDownPiano_loop

; Imprime las instrucciones de uso	
printHelp:
	; Cambia la tinta a cyan
	LD A, $05
	CALL SetInk
	
	; Posiciona el cursor
	LD B, $15
	LD C, $1E
	CALL SetLocation
	
	; RST $10 imprime el ascii cargado en A en la posición actual del cursor
	; Imprime las notas
	LD HL, _notas1
	CALL PrintString
	
	; Posiciona el cursor
	LD B, $16
	CALL SetLocation
	
	LD HL, _notas2
	CALL PrintString
	
	; Posiciona el cursor
	LD B, $09
	CALL SetLocation
	
	; Imprime las teclas para usar el piano
	LD HL, _teclas2
	CALL PrintString
	
	; Posiciona el cursor
	LD B, $08
	CALL SetLocation
	
	LD HL, _teclas1
	CALL PrintString

	; Posiciona el cursor
	LD B, $06
	LD C, $20
	CALL SetLocation
	
	; Cambia la tinta a amarillo
	LD A, $06
	CALL SetInk
	
	; Imprime el resto de teclas de control
	LD HL, _info1
	CALL PrintString
	
	; Posiciona el cursor
	LD B, $05
	CALL SetLocation
	
	LD HL, _info2
	CALL PrintString
	
	; Posiciona el cursor
	LD B, $03
	CALL SetLocation
	
	LD HL, _info4
	CALL PrintString
	
	; Cambia la tinta a magenta
	LD A, $03
	CALL SetInk
	
	; Posiciona el cursor
	LD B, $04
	CALL SetLocation
	
	LD HL, _info3
	CALL PrintString
	
	; Accede a las dos últimas líneas de la pantalla. Pantalla 2
	LD A, $01
	CALL OPENCHAN
	
	; Posiciona el cursor
	LD B, $17
	LD C, $20
	CALL SetLocation
	
	; Cambia la tinta a blanco
	LD A, $07
	CALL SetInk
	
	LD HL, _info5
	CALL PrintString
	
	; Vuelve a la pantalla 1
	LD A, $02
	CALL OPENCHAN
	
	RET

; -----------------------------------------------------------------------------
; Imprime una cadena acabada en 0.
;
; Entrada:	HL	->	Direcci�n de la cadena acabada en 0 (NULL)
;
; Altera el valor del registro HL.
; -----------------------------------------------------------------------------
PrintString:
	; Preserva el registro AF
	PUSH AF

printString_loop:
	; Carga en A el car�cter a imprimir
	LD A, (HL)

	; Comprueba si es 0, en cuyo caso finaliza. OR A = 0 si A = 0.
	OR A
	JR Z, printString_end

	; Imprime el car�cter
	RST $10

	; Avanza HL al siguiente caracter de la cadena
	INC HL

	; Repite hasta llegar al final de cadena (0)
	JR printString_loop

printString_end:
	; Recupera el registro AF
	POP AF

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
	AND $07

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
	AND $C7

	; Asigna el color del borde
	OR B

	; Carga el valor en la variable de sistema BORDCR. 
	; Si no se guarda y se usa BEEPER, el borde se pone a 0.
	LD (BORDCR), A

	; Recupera los registros
	POP BC

	RET
	
; -----------------------------------------------------------------------------
; Cambia el color actual de tinta
;
; Entrada:	A	->	Color para la tinta
;
; Altera el valor del registro AF.
; -----------------------------------------------------------------------------
SetInk:
	; Preserva los registros
	PUSH BC

	; Se queda con el color de tinta y la carga en B
	AND $07
	LD B, A

	; Recupera la variable de sistema del atributo actual y desecha la tinta
	LD A, (ATTR_T)
	AND $F8

	; Pone la tinta y actualiza la variables de sistema del atributo actual
	OR B
	LD (ATTR_T), A

	; Recupera los registros
	POP BC

	RET

; -----------------------------------------------------------------------------
; Asigna la posición del cursor.
;
; Entrada:	B	->	Coordenada Y.
;		C	->	Coordenada X.
;
; La esquina superior izquierda está en (24, 33)
; -----------------------------------------------------------------------------
SetLocation:
	; Preserva los registros que LOCATE altera
	PUSH AF
	PUSH DE
	PUSH HL

	; Posiciona el cursor
	CALL LOCATE

	; Recupera los registros
	POP HL
	POP DE
	POP AF

	RET

; ------------------------------------------------------------------------------	
; Literales. Cadenas terminadas en 0 para la rutina PrintString
; ------------------------------------------------------------------------------
_title:		DB "Musica Maestro", 0
_notas1:	DB "c   d    e  f   g   a    b", 0
_notas2:	DB "  c#  d#      f#  g#  a#", 0
_teclas1:	DB "q   w    e  y   u   i    o", 0
_teclas2:	DB "  2   3       7   8   9", 0
_info1:		DB "A = escala 1 - Z = negra", 0
_info2:		DB "S = escala 2 - X = corchea", 0
_info3:		DB "D = escala 3 - C = semicorchea", 0
_info4:		DB "F = escala 4 - V = fusa", 0
_info5:		DB "N = continuo - M = discontinuo", 0

; ------------------------------------------------------------------------------
; Graficos definidos por el usuario
;
; Para convertir de binario a hexadecimal y viceversa, se usa el método
; aprendido de Fran Gallego Durán (Profesor Retroman) 
; https://www.youtube.com/channel/UCSdIAKvPxlB3VlFDCBvI46A
;
; Cada nibble representa un letra, y los bits de cada nibble representan:
; Valor	8	4	2	1
; Bit	0	0	0	0
;
; De esta manera, sumando los bits a 1, se alcanza el valor hexadecimal
; del nibble.
;
;	1	0	1	0
;	8	0	2	0	= 10 = A
; ------------------------------------------------------------------------------
_udgs:
DB	$7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F	; 144	Izquierda
DB	$FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF	; 145	Centro
DB	$FE, $FE, $FE, $FE, $FE, $FE, $FE, $FE	; 146	Derecha
DB	$FE, $FF, $FF, $FF, $FF, $FF, $FF, $FF	; 147	Esquina derecha
DB	$00, $FE, $FE, $FE, $FE, $FE, $FE, $FE	; 148	Arriba derecha
DB	$00, $7F, $7F, $7F, $7F, $7F, $7F, $7F	; 149	Arriba izquierda
DB	$7F, $FF, $FF, $FF, $FF, $FF, $FF, $FF	; 150	Esquina derecha