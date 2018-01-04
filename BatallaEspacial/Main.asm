; Programa realizado siguiendo el curso https://wiki.speccy.org/cursos/ensamblador/indice
; Se ha realizado al llegar al capítulo https://wiki.speccy.org/cursos/ensamblador/interrupciones
; Hay varias partes de código que están directamente copiadas del curso, por lo que no se especifican todas
; Se ha tomado la rutina de impresión de números BCD de las fichas de código máquina de MicroHobby
; La rutina Ramdom se ha sido tomada de http://old8bits.blogspot.com.es/2016/04/como-escribir-juegos-para-el-zx_18.html
; Si falta alguien a quien nombrar, que lo haga saber y se incluirá
; Solo funciona en 48K y +

	ORG 32768

INCLUDE "Const.asm"

Main:
	; Carga los gráficos definidos por el usuario		
	CALL LoadUdgs

	; Activa la pausa
	LD HL, flags1
	SET 3, (HL)

	; Genera una tabla de 257 valores "$F1" desde $FE00 a $FF00
	; para que sea compatible con todos los modelos y si hay algún dispositivo conectado
	LD HL, $FE00
	LD A, $F1
	LD (HL), A		; Carga $F1 en $FE00
	LD DE, $FE01	; DE apunta a $FE01
	LD BC, 256		; Realiza 256 LDI para copiar $F1
	LDIR			; en toda la tabla de vectores de int.

	; Instala las rutinas ISR en las interrupciones
	DI
	LD A, $FE
	LD I, A
	IM 2
	EI 

Game:
	LD A, 5
	LD (enemiesCiclesMax), A

	; Limpia la pantalla
	CALL ClsScreen

	; Abre el canal 2 para imprimir en la pantalla superior
	LD A, 2
	CALL ROMOPENCHAN

	; Pinta el título
	LD B, 24
	LD C, 25
	CALL Locate

	LD HL, gameTitle
	CALL PaintString

	; Pinta la presentación
	LD B, 20
	LD C, 33
	CALL Locate

	LD HL, gamePresentation
	CALL PaintString

	; Pinta los controles
	LD B, 10
	LD C, 33
	CALL Locate

	LD HL, gameControls
	CALL PaintString

	; Pinta pulse Enter para empezar
	LD B, 4
	LD C, 29
	CALL Locate

	LD HL, gameWaitEnter
	CALL PaintString
	LD A, " "
	RST $10
	LD HL, gameToStart
	CALL PaintString
	
	; Pinta pulse 0 para salir
	LD B, 2
	LD C, 26
	CALL Locate

	LD HL, gameExit
	CALL PaintString

	; Espera a que se pulse Enter ó 0
	CALL WaitKey

Game_start:
	; Inicia los datos de la partida
	CALL ResetEnemiesConfig
	CALL InitGame
	CALL InitLevel

Game_loop:
	; Evalúa si se cambia de ciclo y se cambia el color
	LD A, (flags1)
	BIT 4, A
	JR Z, Game_testEnemies

	; Se desactiva el bit de cambio de ciclo
	RES 4, A
	LD (flags1), A

	; Se cambia la dirección de movimiento de los enemigos
	CALL ResetEnemiesDir

Game_testEnemies:
	; En enemiesCiclesMax está el número de ciclos que deben pasar para que se animen los enemigos
	LD A, (enemiesCiclesMax)
	LD B, A
	
	; En enemiesCiclesCount está el número de ciclos pasados desde la última animación de enemigos
	LD A, (enemiesCiclesCount)
	
	; Lo compara con B, que es donde está el número de ciclos que deben pasar
	CP B
	
	; Si no se ha llegado al número de ciclos entre actualizaciones, salta
	JR C, Game_ship

; -----------------------------------------------------------------------------	
; Imprime los enemigos
; -----------------------------------------------------------------------------
Game_enemies:
	CALL EnemiesMoveSound

	CALL DeleteEnemies
	
	CALL AnimeEnemies
	
	CALL PaintEnemies
	
	; Pone en número de ciclos pasados a 0
	LD A, 0
	LD (enemiesCiclesCount), A

	CALL CheckCrash

	CALL PaintShip

Game_ship:
	CALL CheckKey
	
	; Si el disparo está activo, mueve el disparo, si no se está moviendo
	LD A, (flags1)
	BIT 1, A
	CALL NZ, AnimeFire

	; Evalúa si se está pintando la nave
	; Si es así salta
	LD A, (flags1)
	BIT 0, A
	JR NZ, Game_crash

	; Carga en A las pulsaciones de las teclas
	LD A, D
	
	; Desecha el bit de disparo
	AND 00001111b
	
	; Comprueba si hay algún bit de dirección activo
	OR A
	
	; Si es así, mueve la nave
	CALL NZ, AnimeShip

Game_crash:
	CALL CheckCrash

Game_loopEnd:
	LD A, (livesCount)
	CP 0
	JR Z, Game_over

	LD A, (enemiesCount)
	CP 0
	JR NZ, Game_loop

	LD A, (levelCount)
	CP $30
	JR Z, Game_win

	ADD A, $1
	DAA
	LD (levelCount), A
	
	LD A, (levelType)
	INC A
	LD (levelType), A
	CP 5
	JR C, Game_loopChangeLevel

	LD A, 1
	LD (levelType), A

Game_loopChangeLevel:
	LD A, (enemiesCountIni)
	LD (enemiesCount), A

	CALL ResetEnemiesConfig

	CALL InitLevel

	JP Game_loop

Game_over:
	; Activa la pausa
	LD A, (flags1)
	AND 00001000b
	LD (flags1), A

	; Limpia la pantalla
	LD A, 5
	LD (enemiesCiclesMax), A
	CALL ClsScreen

	; Pinta la información de la partida
	CALL PaintInfoGame

	; Pinta el título
	LD B, 24
	LD C, 25
	CALL Locate

	LD HL, gameTitle
	CALL PaintString

	; Pinta game over
	LD B, 20
	LD C, 33
	CALL Locate

	LD HL, gameOverTitle
	CALL PaintString

	; Pinta pulse Enter para continuar
	LD B, 7
	LD C, 30
	CALL Locate

	LD HL, gameWaitEnter
	CALL PaintString
	LD A, " "
	RST $10
	LD HL, gameToContinue
	CALL PaintString

	; Pinta pulse 0 para salir
	LD B, 5
	LD C, 26
	CALL Locate

	LD HL, gameExit
	CALL PaintString

	; Espera a que se pulse Enter ó 0
	CALL WaitKey

	JP Game

Game_win:
	; Activa la pausa
	LD A, (flags1)
	AND 00001000b
	LD (flags1), A

	; Limpia la pantalla
	LD A, 5
	LD (enemiesCiclesMax), A
	CALL ClsScreen

	; Pinta la información de la partida
	CALL PaintInfoGame

	; Pinta el fin de la partida
	LD B, 20
	LD C, 33
	CALL Locate

	LD HL, gameWin
	CALL PaintString

	; Pinta pulse Enter para continuar
	LD B, 7
	LD C, 30
	CALL Locate

	LD HL, gameWaitEnter
	CALL PaintString
	LD A, " "
	RST $10
	LD HL, gameToContinue
	CALL PaintString

	; Pinta pulse 0 para salir
	LD B, 5
	LD C, 26
	CALL Locate

	LD HL, gameExit
	CALL PaintString

	; Espera a que se pulse Enter ó 0
	CALL WaitKey

	JP Game

; -----------------------------------------------------------------------------
; Inicia los datos de la partida
;
; Altera el valor de los registros A y HL
; -----------------------------------------------------------------------------
InitGame:
	LD A, 1
	LD (levelType), A

	; Formato numérico BCD
	LD A, (enemiesCountIni)
	LD (enemiesCount), A

	LD A, 5
	LD (enemiesCiclesMax), A

	LD A, $01
	LD (levelCount), A

	LD A, $05
	LD (livesCount), A

	LD A, 0
	LD (livesExtra), A
	LD (livesExtra+1), A

	LD A, $00
	LD (scoreCount+2), A
	LD (scoreCount+1), A
	LD (scoreCount), A

	RET

; -----------------------------------------------------------------------------
; Inicia el nivel
;
; Altera el valor de los registros A
; -----------------------------------------------------------------------------
InitLevel:
	; Restaura los ciclos a pasar para animar a los enemigos
	LD A, 5
	LD (enemiesCiclesMax), A
	LD (enemiesCiclesCount), A

	; Restaura el tiempo a pasar para el cambio de velocidad de los enemigos
	LD A, 0
	LD (ticks), A
	LD (seconds), A

	; Activa la pausa
	LD HL, flags1
	SET 3, (HL)

	; Limpia la pantalla
	CALL ClsScreen

	; Imrime la información de la partida
	CALL PaintInfoGame

	; Pinta el marco
	CALL PaintFrame

	; Pinta la nave
	LD A, (shipCoordIni)
	LD (shipCoord), A

	LD A, (shipCoordIni+1)
	LD (shipCoord+1), A

	CALL PaintShip

	; Inicia los datos para hacer la cuenta atrás
	LD A, 0
	LD (ticks), A
	LD A, 3
	LD (seconds), A

	CALL PaintCountdown

	; Activa la cuenta atrás y la pausa
	LD A, (flags1)
	; Pone los flags de cuenta atrás y pausa a 0
	AND 11110011b
	; Pone los flags de cuenta atrás y pausa a 1
	OR 00001100b
	LD (flags1), A

InitLevel_loop:
	; Se trabaja con un retardo de 3 segundos hasta que empieza la acción
	LD A, (seconds)
	CP 0
	JR NZ, InitLevel_loop

	; Pinta los enemigos
	CALL Z, LoadUdgsEnemies

	CALL PaintEnemies

	; Desactiva la cuenta atrás y la pausa
	LD A, (flags1)
	; Pone los flags de cuenta atrás y pausa a 0
	AND 11110011b
	LD (flags1), A

	RET

INCLUDE "Check.asm"
INCLUDE "Graph.asm"
INCLUDE "Paint.asm"
INCLUDE "PaintEnemy.asm"
INCLUDE "PaintFire.asm"
INCLUDE "PaintShip.asm"
INCLUDE "Random.asm"
INCLUDE "Sound.asm"
INCLUDE "Var.asm"

; -----------------------------------------------------------------------------
; Interrupciones
;
; Para evitar problemas, debe ser la última parte del programa
; Se puede usar ETIQUETA EQU $ antes de la rutina y ORG ETIQUETA después
; si se quiere poner código despúes de las rutinas de interrupciones
; -----------------------------------------------------------------------------
	ORG $F1F1	; Asegura la dirección de salto
MainISR:
	PUSH HL
	PUSH DE
	PUSH BC
	PUSH AF

	CALL CountdownISR
	CALL EnemiesISR
	CALL ShipISR

MianISR_end:
	POP AF
	POP BC
	POP DE
	POP HL
	
	EI
	RETI

; -----------------------------------------------------------------------------
; Maneja la cuenta atrás que hay al iniciar cada nivel
; -----------------------------------------------------------------------------
CountdownISR:
	; Comprueba si la cuenta atrás está activa
	; Si no lo está, sale
	LD HL, flags1
	BIT 2, (HL)
	JR Z, CountdownISR_end

	LD A, (ticks)
	INC A
	LD (ticks), A
	CP 50
	JR NZ, CountdownISR_end

	LD A, (0)
	LD (ticks), A

	LD A, (seconds)
	DEC A
	LD (seconds), A

	PUSH AF

	CALL PaintCountdown

	POP AF

	CP 0
	JR NZ, CountdownISR_end

	CALL DeleteCountdown

CountdownISR_end:
	RET

; -----------------------------------------------------------------------------
; Maneja las interrupciones de los enemigos
; -----------------------------------------------------------------------------
EnemiesISR:
	; Evalúa si la pausa está activa.
	; Si lo está, se sale
	LD A, (flags1)
	BIT 3, A
	JR NZ, EnemiesISR_end

	; Aumenta el uno el número de ciclos pasados desde la última animación de enemigos
	LD A, (enemiesCiclesCount)
	INC A
	LD (enemiesCiclesCount), A
	
	; La velocidad de animación de enemigos, (ciclos a pasar desde animaciones)
	; se cambia cada 2 segundos
	LD A, (ticks)
	INC A
	LD (ticks), A
	CP 50
	JR NZ, EnemiesISR_end
	
	LD A, 0
	LD (ticks), A
	
	LD A, (seconds)
	INC A
	LD (seconds), A
	CP 2
	JR NZ, EnemiesISR_end
	
	LD A, 0
	LD (seconds), A
	
	; Carga otra vez los flag y activa el bit para comunicar que se ha cmabiado el ciclo
	LD A, (flags1)
	SET 4, A
	LD (flags1), A

	; Carga el número de ciclos a pasar entre animaciones
	LD A, (enemiesCiclesMax)
	
	; Lo decrementa, para que vaya más rápido (menos ciclos)
	DEC A
	
	; Lo vuelve a cargar en memoria
	LD (enemiesCiclesMax), A

	; Lo compara con 0
	CP 0

	; Si no 0 sale
	JR NZ, EnemiesISR_end
	
	; Pone a 5 el número de ciclos a pasar entre animaciones de enemigos
	; y lo sube a memoria
	LD A, 5
	LD (enemiesCiclesMax), A

EnemiesISR_end:
	RET

; -----------------------------------------------------------------------------
; Maneja las interrupciones de la nave
; -----------------------------------------------------------------------------
ShipISR:
	; Evalúa si la pausa está activa.
	; Si lo está, se sale
	LD A, (flags1)
	BIT 3, A
	JR NZ, ShipISR_end

	; Desactiva el indicador que dice que se está pintando la nave
	; y el indicador de que se está pintando el disparo
	LD HL, flags1
	RES 0, (HL)

ShipISR_end:
	RET

	END 32768