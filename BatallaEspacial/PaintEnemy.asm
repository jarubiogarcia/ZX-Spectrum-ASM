; -----------------------------------------------------------------------------
; PaintEnemy.asm
;
; Archivo que contiene las rutinas para pintar todo lo relacionado con los enemigos
; -----------------------------------------------------------------------------

; -----------------------------------------------------------------------------
; Anima los enemigos, "calcula las nuevas posiciones"
;
; Altera el valor de los registros A, BC, DE, HL
; -----------------------------------------------------------------------------
AnimeEnemies:
	; Carga en D el número de enemigos
	LD D, enemiesConfigIni - enemiesConfig

	; Carga en HL la primera dirección de memoria donde está la configuración de los enemigos
	LD HL, enemiesConfig

	; Divide el valor de D entre 2 ya que tenemos 2 bytes por enemigo
	SRA D

AnimeEnemies_loop:
	; Carga en A el byte donde está la coordenada Y del enemigo
	LD B, (HL)
	
	; El bit 7 indica si el enemigo se debe pintar
	BIT 7, B
	
	; Si está a 0 no se pinta, tampoco se mueve
	JR Z, AnimeEnemies_noMove

	; Avanza a la posición de memoria donde está la coordenada X del enemigo
	; y los indicadores de dirección del movimiento
	INC HL
	
	; Y carga el valor en C
	LD C, (HL)
	
	; Se vuelve a posicionar en la dirección de memoria donde está la coordenada Y
	DEC HL
	
; Calcula la coordenada Y y el posible cambio de dirección
AnimeEnemies_posY:
	; Carga en A la coordenada Y
	LD A, B
	
	; Se queda solo con la coordenada desechando los bits 5 a 7
	AND %00011111
	
	; Evalúa si el enemigo se desplaza hacia arriba o hacia abajo
	BIT 7, C
	
	; Si el resultado es 0 arriba, 1 abajo
	JR NZ, AnimeEnemies_posY_down
	
	; El enemigo se está moviendo hacia arriba
	; Comprueba si ha llegado al margen superior
	CP 23
	
	; Si se ha llegado al margen superior, se cambia de dirección y no se cambia la coordenada Y
	JR Z, AnimeEnemies_posY_upOwerflow
	
	; Incrementa en uno la coordenada Y
	INC A
	
	JR AnimeEnemies_posY_end
	
AnimeEnemies_posY_upOwerflow:
	; Cambia la dirección, el enemigo se debe mover hacia abajo
	SET 7, C
	
	JR AnimeEnemies_posY_end
	
AnimeEnemies_posY_down:
	; El enemigo se está moviendo hacia la abajo
	; Comprueba si ha llegado al margen inferior
	CP 5
	
	; Si se ha llegado al margen inferior, se cambia de dirección y no se cambia la coordenada Y
	JR Z, AnimeEnemies_posY_downOwerflow
	
	; Incrementa en uno la coordenada Y
	DEC A
	
	JR AnimeEnemies_posY_end
	
AnimeEnemies_posY_downOwerflow:
	; Cambia la dirección, el enemigo se debe mover hacia arriba
	RES 7, C
	
AnimeEnemies_posY_end:
	; Carga en E la coordenada Y
	LD E, A
	
	; Carga en A el valor original de la coordenada Y con el resto de bits
	LD A, B
	
	; Se queda con los bit 7, 6, y 5
	AND %11100000
	
	; Pone la coordenada Y
	OR E

	; Carga en B el resultado final
	LD B, A
	
	; Carga en memoria el resultado
	; La coordenada Y y la dirección vertical ya están calculadas
	LD (HL), B
	
; Calcula la coordenada X y el posible cambio de dirección
AnimeEnemies_posX:
	; Vuelve a avanzar a la posición de memoria donde está la coordenada X del enemigo
	INC HL
	
	; Carga en A el valor de la coordenada X y las direcciones de movimento
	LD A, C
	
	; Se queda solo con la coordenada X desechando los bits 6 a 7
	AND %00111111
	
	; Evalúa si el enemigo se desplaza hacia izquierda o hacia derecha
	BIT 6, C
	
	; Si el resultado es 0 izquierda, 1 derecha
	JR NZ, AnimeEnemies_posX_right
	
	; El enemigo se está moviendo hacia la izquierda
	; Comprueba si ha llegado al margen izquierdo
	CP 32
	
	; Si se ha llegado al margen izquierdo, se cambia de dirección y no se cambia la coordenada X
	JR Z, AnimeEnemies_posX_leftOwerflow
	
	; Incrementa en uno la coordenada X
	INC A
	
	JR AnimeEnemies_posX_end
	
AnimeEnemies_posX_leftOwerflow:
	; Cambia la dirección, el enemigo se debe mover hacia la derecha
	SET 6, C
	
	JR AnimeEnemies_posX_end
	
AnimeEnemies_posX_right:
	; El enemigo se está moviendo hacia la derecha
	; Comprueba si ha llegado al margen derecho
	CP 3
	
	; Si se ha llegado al margen derecho, se cambia de dirección y no se cambia la coordenada X
	JR Z, AnimeEnemies_posX_rightOwerflow
	
	; Decrementa en uno la coordenada X
	DEC A
	
	JR AnimeEnemies_posX_end
	
AnimeEnemies_posX_rightOwerflow:
	; Cambia la dirección, el enemigo se debe mover hacia la izquierda
	RES 6, C
	
AnimeEnemies_posX_end:
	; Carga en E la coordenada X
	LD E, A
	
	; Carga en A el valor original de la coordenada X y los bits de dirección del movimiento
	LD A, C
	
	; Se queda con los bits de dirección del movimineto, bits 6 a 7
	AND %11000000
	
	; Pone coordenada X
	OR E
	
	; Carga en C el resultado final
	LD C, A
	
	; Carga en memoria el resultado
	; La coordenada X y la dirección horizontal ya están calculadas
	LD (HL), C
	
	JR AnimeEnemies_end
	
AnimeEnemies_noMove:	
	; Avanza a la dirección de memoria donde está la coordenada X del enemigo
	; Esto se hace para que finalmente se quede posicionado en la dirección 
	; de memoria donde está la coordenada Y del siguiente enemigo, en MoveEnemies_end
	INC HL

AnimeEnemies_end:
	; Se sitúa en la dirección de memoria de la coordenada Y del siguiente enemigo
	INC HL
	
	; Decrementa el número de enemigos
	DEC D
	
	; Continua en el bucle hasta que D sea 0
	JR NZ, AnimeEnemies_loop
	
	RET

; -----------------------------------------------------------------------------
; Borra los enemigos
;
; Altera el valor de los registros A, D, BC y HL
; -----------------------------------------------------------------------------	
DeleteEnemies:
	; Carga en D el número de enemigos
	LD D, enemiesConfigIni - enemiesConfig

	; Carga en HL la primera dirección de memoria donde está la configuración de los enemigos
	LD HL, enemiesConfig

	; Divide el valor de D entre 2 ya que hay 2 bytes por enemigo
	SRA D
	
DeleteEnemies_loop:	
	; Carga en A el byte donde está la coordenada Y del enemigo
	LD A, (HL)
	
	; Si el enemigo no está activo salta al siguiente
	BIT 7, A
	JR NZ, DeleteEnemies_loop1

	; Si llega aquí el enemigo no está activo
	; Avanza a la dirección de memoria donde está la coordenada Y del siguiente enemigo
	INC HL
	INC HL

	; Salta para procesar el siguiente enemigo
	JR DeleteEnemies_loop2

DeleteEnemies_loop1:
	; Se queda solo con la posición Y, despreciando los bits 5 a 7
	AND %00011111
	
	; Carga la coordenada Y en B
	LD B, A
	
	; Avanza a la dirección de memoria donde está la coordenada X del enemigo
	INC HL
	
	; Carga en A el byte donde está la coordenada X del enemigo
	LD A, (HL)
	
	; Se queda con la posición X, despreciando los bits 6 y 7
	AND %00111111
	
	; Carga la coordenada X en C
	LD C, A
	
	; Posiciona el cursor
	CALL Locate
	
	; Borra el enemigo
	LD A, " "
	RST $10
	
	; Se sitúa en la dirección de memoria de la coordenada Y del siguiente enemigo
	INC HL

DeleteEnemies_loop2:	
	; Decrementa D, número de enemigos a borrar
	DEC D
	
	; Sigue en el bucle mientras D no sea 0
	JR NZ, DeleteEnemies_loop
	
	RET

; -----------------------------------------------------------------------------
; Pinta los enemigos
;
; Altera el valor de los registros A, BC, D y HL
; -----------------------------------------------------------------------------	
PaintEnemies:
	; Carga en memoria la primera dirección de memoria de los carácteres de los enememigos
	LD HL, enemiesGraph
	LD (enemiesGraphIdx), HL

	; Carga en D el número de enemigos
	LD D, enemiesConfigIni - enemiesConfig
	
	; Carga en HL la primera dirección de memoria donde está la configuración de los enemigos
	LD HL, enemiesConfig

	; Divide el resultado entre 2 ya que tenemos 2 bytes por enemigo
	SRA D

PaintEnemies_loop:	
	; Carga en A el byte donde está la coordenada Y del enemigo
	LD A, (HL)
	
	; El bit 7 indica si el enemigo se debe pintar
	; Si está a 0 no se pinta
	BIT 7, A
	JR Z, PaintEnemies_noPrint
	
	; Se queda solo con la posición Y, desechando los bits 5 a 7
	AND %00011111
	
	; Carga la coordenada Y en B
	LD B, A
	
	; Avanza a la dirección de memoria donde está la coordenada X del enemigo
	INC HL
	
	; Carga en A el byte donde está la coordenada X del enemigo
	LD A, (HL)
	
	; Se queda con la posición X, desechando los bits 6 y 7
	AND %00111111
	
	; Carga la coordenada X en C
	LD C, A
	
	; Sube a pila la coordenada actual del enemigo para luego colorear el carácter
	PUSH BC

	; Posiciona el cursor
	CALL Locate
	
	; Carga en A el byte donde está la dirección de movimiento del enemigo
	; Es el mismo byte donde está la coordenada X
	LD A, (HL)
	
	; Se queda con la dirección de movimiento
	AND %11000000
	
	; Lo rota dos veces hacia la izquierda para dejar el valor en los bits 0 y 1
	; y usarlo como índice para obtener el carácter
	RLCA
	RLCA
	
	; Carga en BC la primera dirección de memoria de los carácteres de los enememigos
	LD BC, (enemiesGraphIdx)
	
	; Si el índice es 0, BC ya apunta el primer carácter
	CP 0
	JR Z, PaintEnemies_print
	
	; Avanza BC hasta la posición de memoria del carácter que marca 
	; la dirección de movimiento del enemigo
PaintEnemies_graph:
	INC BC
	DEC A

	; Sigue en el bucle hasta que A sea 0
	JR NZ, PaintEnemies_graph
	
; Imprime el carácter correspondiente
PaintEnemies_print:
	LD A, (BC)
	RST $10

	; Recupera la coordenada actual del enemigo
	POP BC

	PUSH HL

	; Colorea el carácter dónde se ha pintado el enemigo
	LD A, (enemiesCiclesMax)
	CALL SetInkLR

	POP HL

	JR PaintEnemies_end
	
; No se imprime el enemigo
PaintEnemies_noPrint:
	; Avanza a la dirección de memoria donde está la coordenada X del enemigo
	; Esto se hace para que finalmente se quede posicionado en la dirección 
	; de memoria donde está la coordenada Y del siguiente enemigo, en PaintEnemies_end
	INC HL
	
PaintEnemies_end:
	; Se sitúa en la dirección de memoria de la coordenada Y del siguiente enemigo
	INC HL

	; Decrementa D, número de enemigos a pintar
	DEC D
	
	; Sigue en el bucle hasta que D sea 0
	JR NZ, PaintEnemies_loop

	RET

; -----------------------------------------------------------------------------
; Resetea la configuración de los enemigos activos
; 
; Altera el valor de los registros A, BC, DE y HL
; -----------------------------------------------------------------------------
ResetActiveEnemiesConfig:
	PUSH AF
	PUSH BC
	PUSH DE
	PUSH HL

	; Carga en HL la dirección de memoria de la configuración de los enemigos
	LD HL, enemiesConfig

	; Carga en DE la dirección de memoria de la configuración inicial de los enemigos
	LD DE, enemiesConfigIni

	; Carga en B el número de enemigos
	LD B, enemiesConfigIni - enemiesConfig

	; Lo divide entre dos, hay dos bytes por enemigo
	SRA B

ResetActiveEnemiesConfig_loop:
	; Carga la coordenada Y del enemigo en A
	LD A, (HL)

	; Se queda solo con el indicador de enemigo activo
	AND %10000000

	; Carga el valor en C
	LD C, A

	; Carga la coordenada Y inicial del enemigo en A
	LD A, (DE)

	; Se queda solo con la coordenada
	AND %00011111

	; Resetea la coordenada Y actual con la coordenada inicial
	OR C

	; Carga la coordenada Y resultante en la coordenada Y actual
	LD (HL), A

	; Avanza a la coordenada X actual e inicial
	INC HL
	INC DE

	; Carga la coordenada X inicial del enemigo en A
	LD A, (DE)

	; Carga la coordenada X la coordenada X inicial
	LD (HL), A

	; Avanza a la coordenada Y actual e inicial del siguiente enemigo
	INC HL
	INC DE

	; Mientras B sea mayor que 0
	DJNZ ResetActiveEnemiesConfig_loop

	POP HL
	POP DE
	POP BC
	POP AF

	RET

; -----------------------------------------------------------------------------
; Resetea la configuración de los enemigos
; 
; Altera el valor de los registros BC, DE y HL
; -----------------------------------------------------------------------------
ResetEnemiesConfig:
	; Carga en HL la dirección de memoria de la configuración inicial de los enemigos
	LD HL, enemiesConfigIni

	; Carga en DE la dirección de memoria de la configuración de los enemigos
	LD DE, enemiesConfig

	; Carga en BC el número de direcciones de memoria copiar
	LD BC, enemiesConfigEnd - enemiesConfigIni

	; Copia las direcciones de memoria de configuraciones iniciales de enemigos
	; en las direcciones de memoria de configuraciones de enemigos
	LDIR

	; Pone las direcciones de desplazamiento en las configuraciones de los enemigos de tipos 3
	CALL ResetEnemiesDir

	RET

; -----------------------------------------------------------------------------
; Asigna la dirección de desplazamiento de los enemigos pseudo aleatoriamente
;
; Altera el valor de los resgistros A, BC y HL
; -----------------------------------------------------------------------------
ResetEnemiesDir:
	; Carga en B el número de enemigos
	LD B, enemiesConfigIni - enemiesConfig

	; Carga en HL la primera posición de memoria de las coordenadas
	LD HL, enemiesConfig

	; Divide B entre dos pues son dos bytes por enemigo
	SRA B

ResetEnemiesDir_loop:
	; Obtiene la coordernada Y del enemigo
	; En el bit 7 marca si el enemigo está activo
	LD A, (HL)

	; Si el bit 7 está activo, trata el enemigo
	BIT 7, A
	JR NZ, ResetEnemiesDir_loop1

	; En este caso no está activo. Avanza a la posición de memoria de la coordenada X
	; y salta para tratar el siguiente enemigo
	INC HL

	JR ResetEnemiesDir_loop2

ResetEnemiesDir_loop1:
	; Avanza hasta la posición de memoria de la coordenada X
	; los bits 6 y 7 contienen la dirección de desplazamiento
	INC HL

	; Carga la coordenada en A
	LD A, (HL)

	; Se queda solo con la coordenada
	AND %00111111

	; La carga en C
	LD C, A

	PUSH HL

	; Obtiene un número pseudo aleatorio. Viene en A
	CALL Random

	; El número debe valer máximo 3
	AND 3

	; Rota los bits a derecha para pasar el valor a los bits 6 y 7
	RRCA
	RRCA

	; Incluye el valor de la coordenada X
	OR C

	POP HL

	; Sube la configuración a memoria
	LD (HL), A

ResetEnemiesDir_loop2:
	; Avanza hasta la posición de memoria de la coordenada Y
	; del siguiente enemigo
	INC HL

	; Sigue en el bucle hasta que B valga 0
	DJNZ ResetEnemiesDir_loop

	RET
