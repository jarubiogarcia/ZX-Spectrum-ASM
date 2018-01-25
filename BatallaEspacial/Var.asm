;------------------------------------------------------------------------------
; Var.asm
;
; Contiene las variables
;------------------------------------------------------------------------------

; -----------------------------------------------------------------------------
; Indicadores 1
;
; Bit 0 -> se está pintando la nave			0 = No, 1 = Si
; Bit 1 -> disparo activo					0 = No, 1 = Si
; Bit 2 -> cuenta atrás activa				0 = No, 1 = Si
; Bit 3 -> la pausa activa					0 = No, 1 = Si
; Bit 4 -> cambio de ciclos para enemigos	0 = No, 1 = Si
; Bit 6 y 7 -> rotar 2 veces a izquierda para poner el valor en bits 0 y 1.
;				1 Teclado
;				2 Sinclair 1
;				3 Sinclair 2
; -----------------------------------------------------------------------------
flags1:
	DB %00000000

; -----------------------------------------------------------------------------
; Variables de control
; -----------------------------------------------------------------------------
; Ciclos de reloj pasados (50*Segundo)
ticks:		
	DB	0

; Segundos que han pasado desde la última vez que se cambian los ciclos de reloj
; que deben pasar para que se vuelvan a animar los enemigos (Velocidad) o
; para la cuenta atrás
seconds:		
	DB	0

; Ciclos de reloj que han pasado desde la última vez que se animaron los enemigos
enemiesCiclesCount:	
	DB	0
; Ciclos de reloj que deben pasar para que se vuelvan a animar los enemigos
enemiesCiclesMax:	
	DB	5

; Utilizado para generar números pseudo-aleatorios
seed:
	DW 0

; -----------------------------------------------------------------------------
; Información de la partida
; -----------------------------------------------------------------------------
enemiesCount:		
	DB	0
enemiesCountIni:
	DB	$20
enemiesTitle:		
	DB	"Enemigos", 0

levelCount:			
	DB	0
levelTitle:			
	DB	"Nivel", 0
levelType:
	DB	0

livesCount:			
	DB	0
livesExtra:
	DW 0
livesTitle:			
	DB	"Vidas", 0

scoreCount:
	DB	0, 0, 0
scoreTitle:
	DB	"Puntos", 0

; -----------------------------------------------------------------------------
; Pantalla de presentación y otros mensajes
; -----------------------------------------------------------------------------
gameControls:
	DEFM "Z - Izquierda        X - Derecha", 13, 13, "          V - Disparo", 0

gameOverTitle:
	DEFM "Has perdido todas tus naves, no", 13
	DEFM "has podido salvar a la Tierra.", 13, 13
	DEFM "El planeta ha sido invadido por", 13 
	DEFM "los alienigenas.", 13, 13
	DEFM "Puedes volver a intentarlo.", 13, 13
	DEFM "De ti depende salvar la Tierra.", 0

gamePresentation:
	DEFM "Las naves alienigenas atacan la", 13
	DEFM "tierra, el futuro depende de ti.", 13, 13
	DEFM "Destruye todos los enemigos que", 13 
	DEFM "puedas, y protege el planeta.", 13, 13

gameTitle:
	DEFM "Batalla espacial", 0

gameToContinue:
	DEFM "continuar", 0
gameExit:
	DEFM "Pulse 0 para salir", 0
gameToStart:
	DEFM "empezar", 0

gameWaitEnter:
	DEFM "Pulsa Enter para", 0

gameWin:
	DEFM "Enhorabuea, has destruido a los", 13
	DEFM "alienigenas. Salvaste la Tierra.", 13, 13
	DEFM "Los habitantes del planeta te", 13
	DEFM "estaran eternamente agradecidos.", 0

; -----------------------------------------------------------------------------
; Declaraciones de los gráficos de los distintos personajes
; y la configuración de coordenadas (Y, X)
; -----------------------------------------------------------------------------

; -----------------------------------------------------------------------------
; Nave
; -----------------------------------------------------------------------------
shipGraph:
	DB 144
shipCoord:
	DB 5, 17
shipCoordIni:
	DB 5, 17

; -----------------------------------------------------------------------------
; Explosión de la nave
; -----------------------------------------------------------------------------
shipCrashGraph:
	DB 146, 147, 148, 149

; -----------------------------------------------------------------------------
; Disparo
; -----------------------------------------------------------------------------
fireGraph:
	DB 145
fireCoord:
	DB 6, 0
fireCoordIni:
	DB 6

; -----------------------------------------------------------------------------
; Enemigos
; -----------------------------------------------------------------------------
enemiesGraphIdx:	DW 	0

; -----------------------------------------------------------------------------
; Gráficos de los enemigos
;
; 00 Left-Up
; 01 Rigth-Up
; 10 Left-Down
; 11 Right-Down
; -----------------------------------------------------------------------------
enemiesGraph:		
	DB 159, 160, 161, 162

; -----------------------------------------------------------------------------
; Marco de la pantalla
; -----------------------------------------------------------------------------
frameBottomGraph:
	DB 155, 156, 156, 156, 156, 156, 156, 156, 156, 156, 156, 156, 156, 156, 156, 156, 156, 156, 156, 156, 156, 156, 156, 156, 156, 156, 156, 156, 156, 156, 156, 157, 0
frameTopGraph:
	DB 150, 151, 151, 151, 151, 151, 151, 151, 151, 151, 151, 151, 151, 151, 151, 151, 151, 151, 151, 151, 151, 151, 151, 151, 151, 151, 151, 151, 151, 151, 151, 152, 0

; -----------------------------------------------------------------------------
; Configuración de los enemigos
;
; 2 bytes por enemigo.
; -----------------------------------------------------------------------------
; Byte 1								|	Byte 2
; -----------------------------------------------------------------------------
; Bit 0 a 4:	Posición Y (24 a 3)		|	Bit 0 a 5:	Posición X (33 a 2)
; Bit 5:		Libre					|	Bit 6:		Dirección horizontal	0 = Left	1 = Right
; Bit 6:		Libre					|	Bit 7:		Dirección vertical		0 = Up		1 = Down
; Bit 7:		Activo 1 = Si, 0 = No	|
; -----------------------------------------------------------------------------
enemiesConfig:
	DB 128+23, 192+32, 128+23, 192+26, 128+23, 192+20, 128+23, 192+14, 128+23, 192+8
	DB 128+20, 128+29, 128+20, 128+23, 128+20, 128+17, 128+20, 128+11, 128+20, 128+5
	DB 128+17, 192+32, 128+17, 192+26, 128+17, 192+20, 128+17, 192+14, 128+17, 192+8
	DB 128+14, 128+29, 128+14, 128+23, 128+14, 128+17, 128+14, 128+11, 128+14, 128+5
enemiesConfigIni:
	DB 128+23, 192+32, 128+23, 192+26, 128+23, 192+20, 128+23, 192+14, 128+23, 192+8
	DB 128+20, 128+29, 128+20, 128+23, 128+20, 128+17, 128+20, 128+11, 128+20, 128+5
	DB 128+17, 192+32, 128+17, 192+26, 128+17, 192+20, 128+17, 192+14, 128+17, 192+8
	DB 128+14, 128+29, 128+14, 128+23, 128+14, 128+17, 128+14, 128+11, 128+14, 128+5
enemiesConfigEnd:
	DB 0

; -----------------------------------------------------------------------------
; Declaración de los gráficos generales
; -----------------------------------------------------------------------------
udgsCommon:
	DB 36, 66, 153, 189, 255, 24, 36, 90		; 144	Nave
	DB 0, 24, 36, 90, 90, 36, 24, 0				; 145	Disparo
	DB 0, 0, 0, 0, 36, 90, 36, 24				; 146	Explosión 1
	DB 0, 0, 0, 20, 42, 52, 36, 24				; 147	Explosión 2
	DB 0, 0, 12, 18, 42, 86, 100, 24			; 148	Explosión 3
	DB 32, 81, 146, 213, 169, 114, 44, 24		; 149	Explosión 4
	DB 63, 106, 255, 184, 243, 167, 239, 174	; 150	Esquina superior izquierda
	DB 255, 170, 255, 0, 255, 255, 0, 0			; 151	Horizontal superior
	DB 252, 174, 251, 31, 205, 231, 245, 119	; 152	Esquina superior derecha
	DB 236, 172, 236, 172, 236, 172, 236, 172	; 153	Lateral izquierda
	DB 53, 55, 53, 55, 53, 55, 53, 55			; 154	Lateral derecha
	DB 238, 175, 231, 179, 248, 223, 117, 63	; 155	Esquina inferior izquierda
	DB 0, 0, 255, 255, 0, 255, 85, 255			; 156	Horizontal inferior
	DB 117, 247, 229, 207, 29, 255, 86, 252		; 157	Esquina inferior derecha
	DB 0, 0, 0, 0, 0, 0, 0, 0					; 158	Blanco

; -----------------------------------------------------------------------------
; Declaración de los gráficos a usar además de los generales
; Se copian los gráficos de los enemigos, dependiendo de los niveles
; -----------------------------------------------------------------------------
udgsExtension:
	DB 0, 0, 0, 0, 0, 0, 0, 0					; 159
	DB 0, 0, 0, 0, 0, 0, 0, 0					; 160
	DB 0, 0, 0, 0, 0, 0, 0, 0					; 161
	DB 0, 0, 0, 0, 0, 0, 0, 0					; 162
udgsExtensionEnd:	
	DB 0
; -----------------------------------------------------------------------------
; Declaración de los enemigos en el nivel 1
; Antes de inicializar el nivel hay que copiarlos a udgsExtension
; -----------------------------------------------------------------------------
udgsEnemiesLevel1:
	DB 140, 66, 45, 29, 180, 190, 70, 48		; Left/Up
	DB 49, 66, 180, 184, 45, 125, 98, 12		; Rigth/Up
	DB 48, 70, 190, 180, 29, 45, 66, 140		; Left/Down
	DB 12, 98, 125, 45, 184, 180, 66, 49		; Rigth/Down
udgsEnemiesLevel1End:
	DB 0

; -----------------------------------------------------------------------------
; Declaración de los enemigos en el nivel 2
; Antes de inicializar el nivel hay que copiarlos a udgsExtension
; -----------------------------------------------------------------------------
udgsEnemiesLevel2:
	DB 192, 251, 105, 93, 123, 20, 74, 121		; Left/Up
	DB 3, 223, 150, 186, 222, 40, 82, 158		; Rigth/Up
	DB 121, 74, 20, 123, 93, 105, 251, 192		; Left/Down
	DB 158, 82, 40, 222, 186, 150, 223, 3		; Rigth/Down
udgsEnemiesLevel2End:
	DB 0

; -----------------------------------------------------------------------------
; Declaración de los enemigos en el nivel 3
; Antes de inicializar el nivel hay que copiarlos a udgsExtension
; -----------------------------------------------------------------------------
udgsEnemiesLevel3:
	DB 252, 132, 180, 175, 153, 247, 20, 28		; Left/Up
	DB 63, 33, 45, 245, 153, 239, 40, 56		; Rigth/Up
	DB 28, 20, 247, 153, 175, 180, 132, 252		; Left/Down
	DB 56, 40, 239, 153, 245, 45, 33, 63		; Rigth/Down
udgsEnemiesLevel3End:
	DB 0

; -----------------------------------------------------------------------------
; Declaración de los enemigos en el nivel 4
; Antes de inicializar el nivel hay que copiarlos a udgsExtension
; -----------------------------------------------------------------------------
udgsEnemiesLevel4:
	DB 242, 149, 152, 254, 57, 85, 146, 77		; Left/Up
	DB 79, 169, 25, 127, 156, 170, 73, 178		; Rigth/Up
	DB 77, 146, 85, 57, 254, 152, 149, 242		; Left/Down
	DB 178, 73, 170, 156, 127, 25, 169, 79		; Rigth/Down
udgsEnemiesLevel4End:
	DB 0

; -----------------------------------------------------------------------------
; Declaración de los enemigos en el nivel 5
; Antes de inicializar el nivel hay que copiarlos a udgsExtension
; -----------------------------------------------------------------------------
udgsEnemiesLevel5:
	DB 118, 153, 164, 212, 71, 189, 138, 76		; Left/Up
	DB 110, 153, 37, 43, 226, 189, 81, 50		; Rigth/Up
	DB 76, 138, 189, 71, 212, 164, 153, 118		; Left/Down
	DB 50, 81, 189, 226, 43, 37, 153, 110		; Rigth/Down
udgsEnemiesLevel5End:
	DB 0

; -----------------------------------------------------------------------------
; Declaración de los enemigos en el nivel 6
; Antes de inicializar el nivel hay que copiarlos a udgsExtension
; -----------------------------------------------------------------------------
udgsEnemiesLevel6:
	DB 152, 102, 89, 170, 182, 73, 90, 36		; Left/Up
	DB 25, 102, 154, 85, 109, 146, 90, 36		; Rigth/Up
	DB 36, 90, 73, 182, 170, 89, 102, 152		; Left/Down
	DB 36, 90, 146, 109, 85, 154, 102, 25		; Rigth/Down
udgsEnemiesLevel6End:
	DB 0

; -----------------------------------------------------------------------------
; Declaración de los enemigos en el nivel 7
; Antes de inicializar el nivel hay que copiarlos a udgsExtension
; -----------------------------------------------------------------------------
udgsEnemiesLevel7:
	DB 4, 114, 93, 116, 46, 190, 76, 32			; Left/Up
	DB 32, 78, 186, 46, 116, 125, 50, 4			; Rigth/Up
	DB 32, 76, 190, 46, 116, 93, 114, 4			; Left/Down
	DB 4, 50, 125, 116, 46, 186, 78, 32			; Rigth/Down
udgsEnemiesLevel7End:
	DB 0

; -----------------------------------------------------------------------------
; Declaración de los enemigos en el nivel 8
; Antes de inicializar el nivel hay que copiarlos a udgsExtension
; -----------------------------------------------------------------------------
udgsEnemiesLevel8:
	DB 0, 124, 90, 104, 124, 79, 38, 4			; Left/Up
	DB 0, 62, 90, 22, 62, 242, 100, 32			; Rigth/Up
	DB 4, 38, 79, 124, 104, 90, 124, 0			; Left/Down
	DB 32, 100, 242, 62, 22, 90, 62, 0			; Rigth/Down
udgsEnemiesLevel8End:
	DB 0

; -----------------------------------------------------------------------------
; Declaración de los enemigos en el nivel 9
; Antes de inicializar el nivel hay que copiarlos a udgsExtension
; -----------------------------------------------------------------------------
udgsEnemiesLevel9:
	DB 224, 216, 182, 110, 91, 54, 60, 08		; Left/Up
	DB 7, 27, 109, 118, 218, 108, 60, 16		; Rigth/Up
	DB 8, 60, 54, 91, 110, 182, 216, 224		; Left/Down
	DB 16, 60, 108, 218, 118, 109, 27, 7		; Rigth/Down
udgsEnemiesLevel9End:
	DB 0

; -----------------------------------------------------------------------------
; Declaración de los enemigos en el nivel 10
; Antes de inicializar el nivel hay que copiarlos a udgsExtension
; -----------------------------------------------------------------------------
udgsEnemiesLevel10:
	DB 224, 206, 191, 60, 115, 117, 106, 44		; Left/Up
	DB 7, 115, 253, 60, 206, 174, 86, 52		; Rigth/Up
	DB 44, 106, 117, 115, 60, 191, 206, 224		; Left/Down
	DB 52, 86, 174, 206, 60, 253, 115, 7		; Rigth/Down
udgsEnemiesLevel10End:
	DB 0

; -----------------------------------------------------------------------------
; Declaración de los enemigos en el nivel 11
; Antes de inicializar el nivel hay que copiarlos a udgsExtension
; -----------------------------------------------------------------------------
udgsEnemiesLevel11:
	DB 224, 222, 191, 124, 123, 117, 106, 44	; Left/Up
	DB 7, 123, 253, 62, 222, 174, 86, 52		; Rigth/Up
	DB 44, 106, 117, 123, 124, 191, 222, 224	; Left/Down
	DB 52, 86, 174, 222, 62, 253, 123, 7		; Rigth/Down
udgsEnemiesLevel11End:
	DB 0

; -----------------------------------------------------------------------------
; Declaración de los enemigos en el nivel 12
; Antes de inicializar el nivel hay que copiarlos a udgsExtension
; -----------------------------------------------------------------------------
udgsEnemiesLevel12:
	DB 224, 254, 247, 108, 95, 126, 108, 40		; Left/Up
	DB 7, 127, 239, 54, 250, 126, 54, 20		; Rigth/Up
	DB 40, 108, 126, 95, 108, 247, 254, 224		; Left/Down
	DB 20, 54, 126, 250, 54, 239, 127, 7		; Rigth/Down
udgsEnemiesLevel12End:
	DB 0

; -----------------------------------------------------------------------------
; Declaración de los enemigos en el nivel 13
; Antes de inicializar el nivel hay que copiarlos a udgsExtension
; -----------------------------------------------------------------------------
udgsEnemiesLevel13:
	DB 7, 108, 126, 52, 111, 251, 174, 140		; Left/Up
	DB 224, 54, 126, 44, 246, 223, 117, 49		; Rigth/Up
	DB 140, 174, 251, 111, 52, 126, 108, 7		; Left/Down
	DB 49, 117, 223, 246, 44, 126, 54, 224		; Rigth/Down
udgsEnemiesLevel13End:
	DB 0

; -----------------------------------------------------------------------------
; Declaración de los enemigos en el nivel 14
; Antes de inicializar el nivel hay que copiarlos a udgsExtension
; -----------------------------------------------------------------------------
udgsEnemiesLevel14:
	DB 33, 26, 150, 117, 76, 60, 98, 144		; Left/Up
	DB 132, 88, 105, 174, 50, 60, 70, 9			; Rigth/Up
	DB 144, 98, 60, 76, 117, 150, 26, 33		; Left/Down
	DB 9, 70, 60, 50, 174, 105, 88, 132			; Rigth/Down
udgsEnemiesLevel14End:
	DB 0

; -----------------------------------------------------------------------------
; Declaración de los enemigos en el nivel 15
; Antes de inicializar el nivel hay que copiarlos a udgsExtension
; -----------------------------------------------------------------------------
udgsEnemiesLevel15:
	DB 4, 2, 13, 20, 40, 176, 64, 32			; Left/Up
	DB 32, 64, 176, 40, 20, 13, 2, 4			; Rigth/Up
	DB 32, 64, 176, 40, 20, 13, 2, 4			; Left/Down
	DB 4, 2, 13, 20, 40, 176, 64, 32			; Rigth/Down
udgsEnemiesLevel15End:
	DB 0

; -----------------------------------------------------------------------------
; Declaración de los enemigos en el nivel 16
; Antes de inicializar el nivel hay que copiarlos a udgsExtension
; -----------------------------------------------------------------------------
udgsEnemiesLevel16:
	DB 48, 72, 190, 185, 124, 46, 39, 19		; Left/Up
	DB 12, 18, 125, 157, 62, 116, 228, 200		; Rigth/Up
	DB 19, 39, 46, 124, 185, 190, 72, 48		; Left/Down
	DB 200, 228, 116, 62, 157, 125, 18, 12		; Rigth/Down
udgsEnemiesLevel16End:
	DB 0

; -----------------------------------------------------------------------------
; Declaración de los enemigos en el nivel 17
; Antes de inicializar el nivel hay que copiarlos a udgsExtension
; -----------------------------------------------------------------------------
udgsEnemiesLevel17:
	DB 192, 223, 54, 124, 88, 119, 102, 68		; Left/Up
	DB 3, 251, 108, 62, 26, 238, 102, 34		; Rigth/Up
	DB 68, 102, 119, 88, 124, 54, 223, 192		; Left/Down
	DB 34, 102, 238, 26, 62, 108, 251, 3		; Rigth/Down
udgsEnemiesLevel17End:
	DB 0

; -----------------------------------------------------------------------------
; Declaración de los enemigos en el nivel 18
; Antes de inicializar el nivel hay que copiarlos a udgsExtension
; -----------------------------------------------------------------------------
udgsEnemiesLevel18:
	DB 2, 113, 105, 87, 47, 30, 158, 120		; Left/Up
	DB 64, 142, 150, 234, 244, 120, 121, 30		; Rigth/Up
	DB 120, 158, 30, 47, 87, 105, 113, 2		; Left/Down
	DB 30, 121, 120, 244, 234, 150, 142, 64		; Rigth/Down
udgsEnemiesLevel18End:
	DB 0

; -----------------------------------------------------------------------------
; Declaración de los enemigos en el nivel 19
; Antes de inicializar el nivel hay que copiarlos a udgsExtension
; -----------------------------------------------------------------------------
udgsEnemiesLevel19:
	DB 32, 127, 230, 78, 94, 121, 120, 68		; Left/Up
	DB 4, 254, 103, 114, 122, 158, 30, 34		; Rigth/Up
	DB 68, 120, 121, 94, 78, 230, 127, 32		; Left/Down
	DB 34, 30, 158, 122, 114, 103, 254, 4		; Rigth/Down
udgsEnemiesLevel19End:
	DB 0

; -----------------------------------------------------------------------------
; Declaración de los enemigos en el nivel 20
; Antes de inicializar el nivel hay que copiarlos a udgsExtension
; -----------------------------------------------------------------------------
udgsEnemiesLevel20:
	DB 54, 47, 219, 190, 124, 219, 246, 100		; Left/Up
	DB 108, 244, 219, 125, 62, 219, 111, 38		; Rigth/Up
	DB 100, 246, 219, 124, 190, 219, 47, 54		; Left/Down
	DB 38, 111, 219, 62, 125, 219, 244, 108		; Rigth/Down
udgsEnemiesLevel20End:
	DB 0

; -----------------------------------------------------------------------------
; Declaración de los enemigos en el nivel 21
; Antes de inicializar el nivel hay que copiarlos a udgsExtension
; -----------------------------------------------------------------------------
udgsEnemiesLevel21:
	DB 0, 112, 110, 84, 43, 52, 40, 8			; Left/Up
	DB 0, 14, 118, 42, 212, 44, 20, 16			; Rigth/Up
	DB 8, 40, 52, 43, 84, 110, 112, 0			; Left/Down
	DB 16, 20, 44, 212, 42, 118, 14, 0			; Rigth/Down
udgsEnemiesLevel21End:
	DB 0

; -----------------------------------------------------------------------------
; Declaración de los enemigos en el nivel 22
; Antes de inicializar el nivel hay que copiarlos a udgsExtension
; -----------------------------------------------------------------------------
udgsEnemiesLevel22:
	DB 0, 120, 110, 86, 109, 59, 52, 12			; Left/Up
	DB 0, 30, 118, 106, 182, 220, 44, 48		; Rigth/Up
	DB 12, 52, 59, 109, 86, 110, 120, 0			; Left/Down
	DB 48, 44, 220, 182, 106, 118, 30, 0		; Rigth/Down
udgsEnemiesLevel22End:
	DB 0

; -----------------------------------------------------------------------------
; Declaración de los enemigos en el nivel 23
; Antes de inicializar el nivel hay que copiarlos a udgsExtension
; -----------------------------------------------------------------------------
udgsEnemiesLevel23:
	DB 12, 2, 61, 53, 172, 184, 64, 48			; Left/Up
	DB 48, 64, 188, 172, 53, 29, 2, 12			; Rigth/Up
	DB 48, 64, 184, 172, 53, 61, 2, 12			; Left/Down
	DB 12, 2, 29, 53, 172, 188, 64, 48			; Rigth/Down
udgsEnemiesLevel23End:
	DB 0

; -----------------------------------------------------------------------------
; Declaración de los enemigos en el nivel 24
; Antes de inicializar el nivel hay que copiarlos a udgsExtension
; -----------------------------------------------------------------------------
udgsEnemiesLevel24:
	DB 0, 119, 110, 86, 42, 116, 123, 66		; Left/Up
	DB 0, 238, 118, 106, 84, 46, 222, 66		; Rigth/Up
	DB 66, 123, 116, 42, 86, 110, 119, 0		; Left/Down
	DB 66, 222, 46, 84, 106, 118, 238, 0		; Rigth/Down
udgsEnemiesLevel24End:
	DB 0

; -----------------------------------------------------------------------------
; Declaración de los enemigos en el nivel 25
; Antes de inicializar el nivel hay que copiarlos a udgsExtension
; -----------------------------------------------------------------------------
udgsEnemiesLevel25:
	DB 192, 255, 118, 108, 95, 126, 108, 72		; Left/Up
	DB 3, 255, 110, 54, 250, 126, 54, 18		; Rigth/Up
	DB 72, 108, 126, 95, 108, 118, 255, 192		; Left/Down
	DB 18, 54, 126, 250, 54, 110, 255, 3		; Rigth/Down
udgsEnemiesLevel25End:
	DB 0

; -----------------------------------------------------------------------------
; Declaración de los enemigos en el nivel 26
; Antes de inicializar el nivel hay que copiarlos a udgsExtension
; -----------------------------------------------------------------------------
udgsEnemiesLevel26:
	DB 60, 126, 247, 232, 218, 225, 104, 36		; Left/Up
	DB 60, 126, 239, 23, 91, 135, 22, 36		; Rigth/Up
	DB 36, 104, 225, 218, 232, 247, 126, 60		; Left/Down
	DB 36, 22, 135, 91, 23, 239, 126, 60		; Rigth/Down
udgsEnemiesLevel26End:
	DB 0

; -----------------------------------------------------------------------------
; Declaración de los enemigos en el nivel 27
; Antes de inicializar el nivel hay que copiarlos a udgsExtension
; -----------------------------------------------------------------------------
udgsEnemiesLevel27:
	DB 4, 2, 57, 45, 63, 158, 76, 56			; Left/Up
	DB 32, 64, 156, 180, 252, 121, 50, 28		; Rigth/Up
	DB 56, 76, 158, 63, 45, 57, 2, 4			; Left/Down
	DB 28, 50, 121, 252, 180, 156, 64, 32		; Rigth/Down
udgsEnemiesLevel27End:
	DB 0

; -----------------------------------------------------------------------------
; Declaración de los enemigos en el nivel 28
; Antes de inicializar el nivel hay que copiarlos a udgsExtension
; -----------------------------------------------------------------------------
udgsEnemiesLevel28:
	DB 0, 55, 105, 92, 52, 95, 70, 100			; Left/Up
	DB 0, 236, 150, 58, 44, 250, 98, 38			; Rigth/Up
	DB 100, 70, 95, 52, 92, 105, 55, 0			; Left/Down
	DB 38, 98, 250, 44, 58, 150, 236, 0			; Rigth/Down
udgsEnemiesLevel28End:
	DB 0

; -----------------------------------------------------------------------------
; Declaración de los enemigos en el nivel 29
; Antes de inicializar el nivel hay que copiarlos a udgsExtension
; -----------------------------------------------------------------------------
udgsEnemiesLevel29:
	DB 0, 55, 109, 94, 52, 127, 86, 100			; Left/Up
	DB 0, 236, 182, 122, 44, 254, 106, 38		; Rigth/Up
	DB 100, 86, 127, 52, 94, 109, 55, 0			; Left/Down
	DB 38, 106, 254, 44, 122, 182, 236, 0		; Rigth/Down
udgsEnemiesLevel29End:
	DB 0

; -----------------------------------------------------------------------------
; Declaración de los enemigos en el nivel 30
; Antes de inicializar el nivel hay que copiarlos a udgsExtension
; -----------------------------------------------------------------------------
udgsEnemiesLevel30:
	DB 224, 255, 237, 91, 126, 110, 95, 114		; Left/Up
	DB 7, 255, 183, 218, 126, 118, 250, 78		; Rigth/Up
	DB 114, 95, 110, 126, 91, 237, 255, 224		; Left/Down
	DB 78, 250, 118, 126, 218, 183, 255, 7		; Rigth/Down
udgsEnemiesLevel30End:
	DB 0