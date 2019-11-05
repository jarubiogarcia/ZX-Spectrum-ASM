; -----------------------------------------------------------------------------
; Fichero: Rom.asm
;
; Rutinas de la ROM y variables de sistema.
; -----------------------------------------------------------------------------

; Atributos de la pantalla 1, principal.
ATTR_S:         equ $5c8d

; Atributo actual de la pantalla.
ATTR_T:         equ $5c8f

; Atributo del borde y pantalla 2. Usada por BEEPER.
BORDCR:         equ $5c48

; Posición del cursor en pantalla 1. Dos bytes. Si carga en BC -> B = Y, C = X.
CURSOR:         equ $5c88

; Dirección de memoria donde se cargan los gráficos definidos por el usuario.
UDG:            equ $5c7b

; Dirección de memoria donde empieza el área de gráficos de la VideoRAM.
VIDEORAM:       equ $4000

; Longitud del área de gráficos de la VideoRAM.
VIDEORAM_L:     equ $1800

; Dirección de memoria donde empieza el área de atributos de la VideoRAM.
VIDEOATTR:      equ $5800

; Longitud del área de atributos de la VideoRAM.
VIDEOATTR_L:    equ $0300

;-------------------------------------------------------------------------------
; Rutina beeper de la ROM.
;
; Entrada:      HL -> Nota.
;               DE -> Duracion.
;
; Altera el valor de los registros AF, BC, DE, HL e IX.
;-------------------------------------------------------------------------------
BEEPER:         equ $03b5

;-------------------------------------------------------------------------------
; Dibuja una línea desde las coordenadas COORDS.
;
; Entrada: B -> Desplazamiento vertical de la línea.
;          C -> Desplazamiento horizontal de la línea.
;          D -> Orientación vertical de la línea. $01 = Arriba, $FF = Abajo.
;          E -> Orientación horizontal de la línea. $01 = Izquierda, $FF = Derecha.
; Altera el valor de los registros AF, BC y HL.
;-------------------------------------------------------------------------------
DRAW:		equ $24ba

;-------------------------------------------------------------------------------
; Dirección de memoria donde están los flags de estado del teclado cuando 
; no están activas las interrupciones.
;
; Bit 3 = 1 entrada en modo L, 0 entrada en modo K.
; Bit 5 = 1 se ha pulsado una tecla, 0 no se ha pulsado.
; Bit 6 = 1 carácter numérico, 0 alfanumérico.
;-------------------------------------------------------------------------------
FLAGS_KEY:	equ $5c3b

;-------------------------------------------------------------------------------
; Dirección de memoria dónde está la última tecla pulsada
; cuando no están activas las interruciones.
;-------------------------------------------------------------------------------
LAST_KEY:	equ $5c08

;-------------------------------------------------------------------------------
; Rutina locate de la ROM.
;
; Entrada:      B -> Coordenada Y.
;               C -> Coordenada X.
;
; Para esta rutina, la esquina superior izquierda de la pantalla es 24, 33.
; (0-21) (0-31)
;-------------------------------------------------------------------------------
LOCATE:         equ $0dd9

;-------------------------------------------------------------------------------
; Rutina de la ROM que abre el canal de la pantalla.
;
; Entrada:      A -> Canal (1 = Pantalla 2, 2 = Pantalla 1).
;-------------------------------------------------------------------------------
OPENCHAN:       equ $1601