;------------------------------------------------------------------------------
; Const.asm
;
; Contiene las constantes
;------------------------------------------------------------------------------

; -----------------------------------------------------------------------------
; Declaraciones de variables de sistema
; -----------------------------------------------------------------------------
; Variable de sistema donde están los atributos de la pantalla 1, principal.
ATTR_S:		EQU	$5C8D

; Variable de sistema donde está el atributo actual
ATTR_T:		EQU	$5C8F	

; Variable de sistema donde se guarda el borde. También usada por BEEPER.
; También se guardan aquí los atributos de la pantalla 2, últimas 2 líneas
BORDCR:		EQU $5C48

; Dirección de memoria donde se cargan los gráficos definidos por el usuario.
UDG:		EQU $5C7B

; -----------------------------------------------------------------------------
; Declaraciones de la VideoRAM
; -----------------------------------------------------------------------------
; Primera dirección de memoria del área de gráficos de la VideoRAM
VIDEORAM:	EQU $4000

; Longitud del área de gráficos de la VideoRAM
VIDEORAM_L:	EQU $1800

; Primera dirección de memoria del área de atributos de la VideoRAM
VIDEOATTR:	EQU	$5800

; Longitud del área de atributos de la VideoRAM
VIDEOATTR_L:EQU $300

; -----------------------------------------------------------------------------
; Declaraciones de rutinas de la ROM
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
; Rutina beeper de la ROM.
;
; Entrada:	HL	->	Nota.
;			DE	->	Duración.
;
; Altera el valor de los registros AF, BC, DE, HL e IX.
; -----------------------------------------------------------------------------
BEEPER:		EQU $03B5	

; -----------------------------------------------------------------------------
; Rutina locate de la ROM.
;
; Entrada:	B	->	Coordenada Y.
;			C	->	Coordenada X.
;
; Para esta rutina, la esquina superior izquierda de la pantalla es (24, 33).
;
; Altera el valor de los registros AF, DE y HL.
; -----------------------------------------------------------------------------
LOCATE:		EQU $0DD9	

; -----------------------------------------------------------------------------
; Rutina de la ROM que abre el canal de la pantalla.
;
; Entrada:	A	->	Canal. 1 = Pantalla 2, 2 = pantalla 1.
;
; -----------------------------------------------------------------------------
OPENCHAN:	EQU $1601