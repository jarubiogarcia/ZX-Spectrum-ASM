;------------------------------------------------------------------------------
; Const.asm
;
; Contiene las constantes
;------------------------------------------------------------------------------

; Dirección de memoria dónde está la rutina beeper de la rom
ROMBEEPER:		EQU $03B5
; Dirección de memoria dónde está la rutina cls de la rom
ROMCLS:			EQU	$0DAF ; $0D6B
; Dirección de memoria donde está la rutina locate de la rom
ROMLOCATE:		EQU	$0DD9
; Dirección de memoria donde está la rutina de abrir canal de la VideoRAM
ROMOPENCHAN:	EQU	$1601
; Dirección de memoria dónde cargar los gráficos definidos por el usuario
UDGDIR:			EQU		$5C7B