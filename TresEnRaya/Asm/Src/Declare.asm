; -----------------------------------------------------------------------------
; Fichero: Declare.asm
;
; Declaraciones de variables, constantes y posiciones de la ROM.
; -----------------------------------------------------------------------------

INKWARNING:		equ $C2	; Tinta para las advertencias.
INKPLAYER1: 		equ $05	; Tinta del jugador 1.
INKPLAYER2: 		equ $06	; Tinta del jugador 2.
INKTIE: 		equ $07	; Tinta del jugador 3.

KEYDEL:			equ $0c	; Tecla Delete
KEYENT:			equ $0d	; Tecla Enter
KEYSPC:			equ $20	; Tecla Space
KEY0:			equ $30	; Tecla 0
KEY1:			equ $31	; Tecla 1
KEY2:			equ $32	; Tecla 2
KEY3:			equ $33	; Tecla 3
KEY4:			equ $34	; Tecla 4
KEY5:			equ $35	; Tecla 5
KEY6:			equ $36	; Tecla 6
KEY7:			equ $37	; Tecla 7
KEY8:			equ $38	; Tecla 8
KEY9:			equ $39	; Tecla 9

WINNERLINE123:		equ $01	; Linea ganadora 123.
WINNERLINE456:		equ $02	; Linea ganadora 456.
WINNERLINE789:		equ $03	; Linea ganadora 789.
WINNERLINE147:		equ $04	; Linea ganadora 147.
WINNERLINE258:		equ $05	; Linea ganadora 258.
WINNERLINE369:		equ $06	; Linea ganadora 369.
WINNERLINE159:		equ $07	; Linea ganadora 159.
WINNERLINE357:		equ $08	; Linea ganadora 357.

Seed:			db $00	; Semilla para números pseudoaleatorios.

; -----------------------------------------------------------------------------
; Parámetros de la partida.
; -----------------------------------------------------------------------------
MaxPlayers:		db $01
MaxPoints:		db $05
MaxSeconds:		db $10
NamePlayer1:		db "        ", $00
NamePlayer2: 		db "        ", $00
NamePlayer2Default: 	db "Spectrum", $00

; -----------------------------------------------------------------------------
; Desarrollo de la partida.
; -----------------------------------------------------------------------------
; Cuenta atrás.
CountDown:		db $00
CountDownTicks:		db $00
SwCountDown:		db $00	; Indica si se emite sonido de aviso en la cuenta atrás.	

; Jugador actual y número total de movimientos.
; Bytes 0-3 -> Jugador actual.
; Bytes 4-7 -> Número de movimientos.
CurrentPlayerMov:	db $00

; Casillas del tablero. Un byte por casilla, del 1 al 9.
; Bit 0 a 1, casilla ocupada por jugador 1.
; Bit 4 a 1, casilla ocupada por jugador 2.
Grid:			db $00, $00, $00, $00, $00, $00, $00, $00, $00

; Puntos de cada jugador y tablas.
PointsPlayer1:		db $00
PointsPlayer2:		db $00
PointsTie:		db $00

; -----------------------------------------------------------------------------
; Sonidos.
; -----------------------------------------------------------------------------
; Fusa Escala 3: a
SoundCountDown:		db $03, $8c, $3a, $00
; Semicorchea Escala 1: b d#
SoundError:		db $0d, $c6, $1e, $16, $13, $13, $00
; Fusa Escala 2: c d e d	Escala 1: c
SoundLostMovement:	db $0d, $07, $10, $0b, $96, $12, $0a, $4d, $14
			db $0b, $96, $12, $1a, $2c, $08, $00
; Fusa Escala 4: b
SoundNextPlayer:	db $01, $9d, $7b, $00
; Fusa Escala 3: c c d c e d c
SoundSpectrum:		db $06, $6e, $20, $06, $6e, $20, $05, $b7, $24
			db $06, $6e, $20, $05, $13, $29, $05, $b7, $24
			db $06, $6e, $20, $00
; Fusa Escala 2: c d b d a d g d f d e d c
SoundTie:		db $0d, $07, $10, $0b, $96, $12, $06, $d4, $1e
			db $0b, $96, $12, $07, $a6, $1b, $0b, $96, $12
			db $08, $a5, $18, $0b, $96, $12, $09, $b4, $15
			db $0b, $96, $12, $0a, $4d, $14, $0b, $96, $12
			db $0d, $07, $10, $00
; Fusa Escala 3: c e g c e g c e f e d e c e g c e g c e f e d c
SoundWinGame:		db $06, $6e, $20, $05, $13, $29, $04, $40, $30
			db $06, $6e, $20, $05, $13, $29, $04, $40, $30
			db $06, $6e, $20, $05, $13, $29, $04, $c7, $2b
			db $05, $13, $29, $05, $b7, $24, $05, $13, $29
			db $06, $6e, $20, $05, $13, $29, $04, $40, $30
			db $06, $6e, $20, $05, $13, $29, $04, $40, $30
			db $06, $6e, $20, $05, $13, $29, $04, $c7, $2b
			db $05, $13, $29, $05, $b7, $24, $06, $6e, $20
			db $00
; -----------------------------------------------------------------------------
; Literales.
; -----------------------------------------------------------------------------
Title:			defm "Tres en raya", $00
Title_1:		defm " a", $00
Title_2:		defm " punto", $00
TitleError:		defm "Casilla ocupada", $00
TitleEspamatica:	defm "Espamatica 2019", $00
TitleGameOver:		defm "Partida finalizada", $00
TitleLostMovement:	defm " pierde turno", $00
TitleOptionStart:	defm "0. Empezar", $00
TitleOptionPlayer:	defm "1. Jugadores", $00
TitleOptionPoint:	defm "2. Puntos", $00
TitleOptionTime:	defm "3. Tiempo", $00
TitlePlayerName:	defm "Nombre del jugador", $00
TitlePlayerName1:	defm " 1: ", $00
TitlePlayerName2:	defm " 2: ", $00
TitlePointFor:		defm "Punto para ", $00	
TitleTie:		defm "Tablas", $00
TitleTurn:		defm "Turno para ", $00

; -----------------------------------------------------------------------------
; Gráficos.
; -----------------------------------------------------------------------------
; Líneas verticales del tablero.
Board_1:		db $20, $20, $20, $20, $97, $20, $20, $20, $20, $97, $20, $20, $20, $20, $00
; Líneas horizontales del tablero.
Board_2:		db $98, $98, $98, $98, $96, $98, $98, $98, $98, $96, $98, $98, $98, $98, $00