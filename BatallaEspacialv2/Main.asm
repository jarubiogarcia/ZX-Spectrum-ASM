; Programa realizado siguiendo el curso https://wiki.speccy.org/cursos/ensamblador/indice
; Se ha realizado al llegar al capítulo https://wiki.speccy.org/cursos/ensamblador/interrupciones
; Hay varias partes de código que están directamente copiadas del curso, por lo que no se especifican todas
; Se ha tomado la rutina de impresión de números BCD de las fichas de código máquina de MicroHobby, microficha G24
; La rutina Ramdom se ha tomado de http://old8bits.blogspot.com.es/2016/04/como-escribir-juegos-para-el-zx_18.html
; La rutina BCD2Bin se ha tomado de https://www.msx.org/forum/development/msx-development/bcdhex-conversion-asm
; Si falta alguien a quien nombrar, que lo haga saber y se incluirá

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
	;LD HL, $FE00
	;LD A, $F1
	;LD (HL), A		; Carga $F1 en $FE00
	;LD DE, $FE01	; DE apunta a $FE01
	;LD BC, 256		; Realiza 256 LDI para copiar $F1
	;LDIR			; en toda la tabla de vectores de int.

	; Instala las rutinas ISR en las interrupciones
	;DI
	;LD A, $FE
	;LD I, A
	;IM 2
	;EI 

	; Se usa esta forma de cargar la rutina ISR
	; para ver el resultado real en KB del tap resultante.
	; Usando la forma comentada ocupa siempre algo más de 29KB, debido a las directivas ORG
	LD HL, MainISR
	DI
	LD ($FEFF), HL
	LD A, $FE
	LD I, A
	IM 2
	EI

Game:
	LD A, 5
	LD (enemiesCiclesMax), A

	; Abre el canal 2 para imprimir en la pantalla superior
	LD A, 2
	CALL OPENCHAN

	; Limpia el área gráfica
	LD A, 0
	CALL ClearScreen

	; Limpia el área de atributos
	LD A, %01000111
	CALL ClearAttributes

	; Asigna el color del borde
	LD A, 0
	CALL SetBorder

	; Pinta el título
	LD A, 2
	CALL SetInk

	LD B, 24
	LD C, 25
	CALL SetLocation

	LD HL, gameTitle
	CALL PaintString

	; Pinta la presentación
	LD A, 6
	CALL SetInk

	LD B, 20
	LD C, 33
	CALL SetLocation

	LD HL, gamePresentation
	CALL PaintString

	; Pinta los controles
	LD A, 3
	CALL SetInk

	LD B, 10
	LD C, 33
	CALL SetLocation

	LD HL, gameControls
	CALL PaintString

	; Pinta pulse Enter para empezar
	LD A, 4
	CALL SetInk

	LD B, 4
	LD C, 29
	CALL SetLocation

	LD HL, gameWaitEnter
	CALL PaintString
	LD A, " "
	RST $10
	LD HL, gameToStart
	CALL PaintString
	
	; Pinta pulse 0 para salir
	LD A, 7
	CALL SetInk

	LD B, 2
	LD C, 26
	CALL SetLocation

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
	; Reproduce el sonido de los enemigos al moverse
	CALL EnemiesMoveSound

	; Borra los enemigos
	CALL DeleteEnemies
	
	; Calcula las nueva posiciones de los enemigos
	CALL AnimeEnemies
	
	; Pinta los enemigos
	CALL PaintEnemies
	
	; Pone el número de ciclos pasados a 0
	LD A, 0
	LD (enemiesCiclesCount), A

	; Comprueba si se ha producido alguna colisión
	CALL CheckCrash

	; Pinta la nave
	CALL PaintShip

Game_ship:
	; Comprueba si se ha pulsado alguna tecla de control
	CALL CheckKey
	
	; Si el disparo está activo, mueve el disparo
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
	AND %00001111
	
	; Comprueba si hay algún bit de dirección activo
	OR A
	
	; Si es así, mueve la nave
	CALL NZ, AnimeShip

Game_crash:
	; Comprueba si hay alguna colisión
	CALL CheckCrash

Game_loopEnd:
	; Comprueba si hay 0 vidas. Si es así ¡Game Over!
	LD A, (livesCount)
	CP 0
	JR Z, Game_over

	; Comprueba si hay 0 enemigos. Si no es así sigue en el bucle
	LD A, (enemiesCount)
	CP 0
	JR NZ, Game_loop

	; Comprueba si es el nivel 30. Si es así ¡Has Ganado!
	LD A, (levelCount)
	CP $30
	JP Z, Game_win

	; Incrementa el nivel
	ADD A, $1
	DAA
	LD (levelCount), A

	; Carga el número de enemigos inicial
	LD A, (enemiesCountIni)
	LD (enemiesCount), A

	; Reinicia la configuración de los enemigos
	CALL ResetEnemiesConfig

	; Inicia el nivel
	CALL InitLevel

	; Vuelve al bucle del juego
	JR Game_loop

Game_over:
	; Anima el cambio
	CALL Game_changeScreen

	; Pinta el título
	LD A, 2
	CALL SetInk

	LD B, 24
	LD C, 25
	CALL SetLocation

	LD HL, gameTitle
	CALL PaintString

	; Pinta game over
	LD A, 6
	CALL SetInk

	LD B, 20
	LD C, 33
	CALL SetLocation

	LD HL, gameOverTitle
	CALL PaintString

	; Pinta pulse Enter para continuar
	LD A, 4
	CALL SetInk

	LD B, 7
	LD C, 30
	CALL SetLocation

	LD HL, gameWaitEnter
	CALL PaintString
	LD A, " "
	RST $10
	LD HL, gameToContinue
	CALL PaintString

	; Pinta pulse 0 para salir
	LD A, 7
	CALL SetInk

	LD B, 5
	LD C, 26
	CALL SetLocation

	LD HL, gameExit
	CALL PaintString

	; Espera a que se pulse Enter ó 0
	CALL WaitKey

	; Borra la pantalla
	CALL FadeScreen

	JP Game

Game_win:
	; Anima el cambio
	CALL Game_changeScreen

	; Pinta el título
	LD A, 2
	CALL SetInk

	LD B, 24
	LD C, 25
	CALL SetLocation

	LD HL, gameTitle
	CALL PaintString

	; Pinta el fin de la partida
	LD A, 6
	CALL SetInk

	LD B, 20
	LD C, 33
	CALL SetLocation

	LD HL, gameWin
	CALL PaintString

	; Pinta pulse Enter para continuar
	LD A, 4
	CALL SetInk

	LD B, 7
	LD C, 30
	CALL SetLocation

	LD HL, gameWaitEnter
	CALL PaintString
	LD A, " "
	RST $10
	LD HL, gameToContinue
	CALL PaintString

	; Pinta pulse 0 para salir
	LD A, 7
	CALL SetInk

	LD B, 5
	LD C, 26
	CALL SetLocation

	LD HL, gameExit
	CALL PaintString

	; Espera a que se pulse Enter ó 0
	CALL WaitKey

	; Limpia la pantalla
	CALL FadeScreen

	JP Game

; -----------------------------------------------------------------------------
; Hace el cambio entre partes del juego.
;
; Altera el valor del registro A
; -----------------------------------------------------------------------------
Game_changeScreen:
	; Activa la pausa
	LD HL, flags1
	SET 3, (HL)

	; Pone la velocidad a 5, más lenta
	LD A, 5
	LD (enemiesCiclesMax), A

	; Borra la pantalla
	CALL FadeScreen

	; Pinta la información de la partida
	CALL PaintInfoGame

	RET

; -----------------------------------------------------------------------------
; Inicia los datos de la partida
;
; Altera el valor de los registros A y HL
; -----------------------------------------------------------------------------
InitGame:
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
	; Borra la pantalla
	CALL FadeScreen

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
	CALL ClearScreen

	; Imrime la información de la partida
	CALL PaintInfoGame

	; Pinta el marco de la pantalla
	CALL PaintFrame

	; Pinta la nave
	LD A, (shipCoordIni)
	LD (shipCoord), A

	LD A, (shipCoordIni+1)
	LD (shipCoord+1), A

	; Pinta la nave
	CALL PaintShip

	; Inicia los datos para hacer la cuenta atrás
	LD A, 0
	LD (ticks), A
	LD A, 3
	LD (seconds), A

	; Pinta la cuenta atrás
	CALL PaintCountdown

	; Activa la cuenta atrás
	LD HL, flags1
	SET 2, (HL)

InitLevel_loop:
	; Se trabaja con un retardo de 3 segundos hasta que empieza la acción
	LD A, (seconds)
	CP 0
	JR NZ, InitLevel_loop

	; Pinta los enemigos
	CALL Z, LoadUdgsEnemies

	CALL PaintEnemies

	; Desactiva la cuenta atrás y la pausa
	LD HL, flags1
	RES 2, (HL)
	RES 3, (HL)

	RET

INCLUDE "Cast.asm"
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
;
; No se usa esta modalidad, tal y como se explica en la cara de la ISR
; -----------------------------------------------------------------------------
	; Esta línea es necesaria en la carga de ISR original
	;ORG $F1F1	; Asegura la dirección de salto
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

	; Carga ticks, incrementa y comprueba si ha llegado a 50 / 1 segundo
	; en cuyo caso reinicia y sigue
	; De los contrario salta al fin de la rutina
	LD A, (ticks)
	INC A
	LD (ticks), A
	CP 50
	JR NZ, CountdownISR_end

	LD A, (0)
	LD (ticks), A

	; Ticks a llegado a 50, se decrementa un segundo
	LD A, (seconds)
	DEC A
	LD (seconds), A

	PUSH AF

	; Pinta la cuenta atrá
	CALL PaintCountdown

	POP AF

	; Si no se ha llegado a 0 segundos salta al fin de la rutina
	CP 0
	JR NZ, CountdownISR_end

	; 0 segundos, borra la cuenta atrás
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
	
	; Activa el bit para comunicar que se ha cambiado el ciclo
	LD HL, flags1
	SET 4, (HL)

	; Carga el número de ciclos a pasar entre animaciones
	LD A, (enemiesCiclesMax)
	
	; Lo decrementa, para que vaya más rápido (menos ciclos)
	DEC A
	
	; Lo vuelve a cargar en memoria
	LD (enemiesCiclesMax), A

	; Lo compara con 0
	CP 0

	; Si no es 0 sale
	JR NZ, EnemiesISR_end
	
	; Pone a 5 el número de ciclos a pasar entre animaciones de enemigos
	; y lo sube a memoria. Velocidad más lenta
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