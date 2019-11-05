org $5dad

; ------------------------------------------------------------------------------
; Punto de entrada del programa
; ------------------------------------------------------------------------------
Start:
	; Carga las notas por defecto
	CALL LoadScale
	
	; Carga la duración por defecto
	LD A, SEMICORCHEA
	LD (_interval), A
	
	; Pinta la pantalla principal
	CALL PrintScreen
	
; ------------------------------------------------------------------------------
; Bucle del programa
; ------------------------------------------------------------------------------
Play:
	; Lee el teclado
	; Lee la semifila Cs-V 1111 1110
	LD A, $FE
	IN A, ($FE)
	; Carga el valor en memoria
	LD (_keysCsV), A
	
	; Lee la semifila A-G 1111 1101
	LD A, $FD
	IN A, ($FE)
	; Carga el valor en memoria
	LD (_keysAG), A
	
	; Lee la semifila Q-T 1111 1011
	LD A, $FB
	IN A, ($FE)
	; Carga el valor en memoria
	LD (_keysQT), A

	; Lee la semifila 1-5 1111 0111
	LD A, $F7
	IN A, ($FE)
	; Carga el valor en memoria
	LD (_keys15), A

	; Lee la semifila 0-6 1110 1111
	LD A, $EF
	IN A, ($FE)
	; Carga el valor en memoria
	LD (_keys06), A

	; Lee la semifila P-Y 1101 1111
	LD A, $DF
	IN A, ($FE)
	; Carga el valor en memoria
	LD (_keysPY), A
	
	; Lee la semifila B-Space
	LD A, $7F
	IN A, ($FE)

; Comprueba si se ha pulsado la tecla de modo continuo (N)	
legato:
	; Carga la dirección de la varible _legato en HL
	LD HL, _legato
	
	; Evalúa si se ha pulsado la tecla N = continuo
	BIT 3, A
	JR NZ, staccato

	; Si se ha pulsado cambia el valor a la variable _legato
	LD (HL), $01

; Comprueba si se ha pulsado la tecla de modo discontinuo (M)	
staccato:
	; Evalúa si se ha pulsado la tecla M = discontinuo
	BIT 2, A
	JR NZ, changeScale1
	
	; Si se ha pulsado cambia el valor a la variable _legato
	LD (HL), $00
	
; ------------------------------------------------------------------------------
; Comprueba si ha pulsado alguna tecla para cambiar de escala (A, S, D, F)
; ------------------------------------------------------------------------------
changeScale1:
	; Carga la dirección de memoria donde se han guardado las pulsaciones 
	; de la semifila A-G
	LD A, (_keysAG)
	
	; Comprueba si se ha pulsado la tecla A. Si no se ha pulsado salta
	BIT $00, A
	JR NZ, changeScale2
	
	; Carga en A y en memoria el valor para cargar la escala 1
	LD A, $01
	LD (_scale), A
	
	; Carga la escala 1
	CALL LoadScale
	
	; Salta para comprobar si se ha pulsado alguna tecla para cambiar la duración
	JR changeDurationNegra

changeScale2:
	; Comprueba si se ha pulsado la tecla S. Si no se ha pulsado salta
	BIT $01, A
	JR NZ, changeScale3
	
	; Carga en A y en memoria el valor para cargar la escala 2
	LD A, $02
	LD (_scale), A
	
	; Carga la escala 2
	CALL LoadScale
	
	; Salta para comprobar si se ha pulsado alguna tecla para cambiar la duración
	JR changeDurationNegra
	
changeScale3:
	; Comprueba si se ha pulsado la tecla D. Si no se ha pulsado salta
	BIT $02, A
	JR NZ, changeScale4
	
	; Carga en A y en memoria el valor para cargar la escala 3
	LD A, $03
	LD (_scale), A
	
	; Carga la escala 3
	CALL LoadScale
	
	JR changeDurationNegra
	
changeScale4:
	; Comprueba si se ha pulsado la tecla F. Si no se ha pulsado salta
	BIT $03, A
	JR NZ, changeDurationNegra
	
	; Carga en A y en memoria el valor para cargar la escala 4
	LD A, $04
	LD (_scale), A
	
	; Carga la escala 4
	CALL LoadScale

; ------------------------------------------------------------------------------
; Comprueba si ha pulsado alguna tecla para cambiar de duración (Z, X, C, V)
; ------------------------------------------------------------------------------
changeDurationNegra:
	; Carga la dirección de memoria donde se han guardado las pulsaciones 
	; de la semifila Cs-V
	LD A, (_keysCsV)
	
	; Comprueba si se ha pulsado la tecla Z. Si no se ha pulsado salta
	BIT $01, A
	JR NZ, changeDurationCorchea
	
	; Carga en memoria el valor para cargar la duración de negra
	LD A, NEGRA
	LD (_interval), A
	
	JR playC
	
changeDurationCorchea:
	; Comprueba si se ha pulsado la tecla X. Si no se ha pulsado salta
	BIT $02, A
	JR NZ, changeDurationSemicorchea
	
	; Carga en memoria el valor para cargar la duración de corchea
	LD A, CORCHEA
	LD (_interval), A
	
	JR playC
	
changeDurationSemicorchea:
	; Comprueba si se ha pulsado la tecla C. Si no se ha pulsado salta
	BIT $03, A
	JR NZ, changeDurationFusa
	
	; Carga en memoria el valor para cargar la duración de semicorchea
	LD A, SEMICORCHEA
	LD (_interval), A
	
	JR playC
	
changeDurationFusa:
	; Comprueba si se ha pulsado la tecla V. Si no se ha pulsado salta
	BIT $04, A
	JR NZ, playC
	
	; Carga en memoria el valor para cargar la duración de fusa
	LD A, FUSA
	LD (_interval), A
	
; ------------------------------------------------------------------------------	
; DO
; ------------------------------------------------------------------------------
playC:
	; Carga en B el valor de _legato (modo continuo / discontinuo)
	LD A, (_legato)
	LD B, A
	
	; Comprueba si está pulsada la tecla Q
	LD A, (_keysQT)
	BIT $00, A
	JR NZ, playCs

	; Carga en HL la nota DO
	LD HL, (_c)
	
	; Carga en DE la frecuencia
	LD DE, (_c_fq)
	
	; Carga en A el intervalo
	LD A, (_interval)
	
	; Divide la frecuencia entre el intervalo para calcular la duración.
	; Deja el resultado en DE
	CALL Divide
	
	; Hace sonar la nota
	CALL Beep

	; Comprueba si está en modo continuo
	LD A, B
	CP $00
	JP Z, playStaccato
	
; ------------------------------------------------------------------------------
; DO#
; ------------------------------------------------------------------------------
playCs:
	; Comprueba si está pulsada la tecla 2
	LD A, (_keys15)
	BIT $01, A
	JR NZ, playD

	; Carga en HL la nota DO#
	LD HL, (_cs)
	
	; Carga en DE la frecuencia
	LD DE, (_cs_fq)
	
	; Carga en A el intervalo
	LD A, (_interval)
	
	; Divide la frecuencia entre el intervalo para calcular la duración
	; Deja el resultado en DE
	CALL Divide
	
	; Hace sonar la nota
	CALL Beep

	; Comprueba si está en modo continuo
	LD A, B
	CP $00
	JP Z, playStaccato
	
; ------------------------------------------------------------------------------
; RE
; ------------------------------------------------------------------------------
playD:
	; Comprueba si está pulsada la tecla W
	LD A, (_keysQT)
	BIT $01, A
	JR NZ, playDs
	
	; Carga en HL la nota RE
	LD HL, (_d)
	
	; Carga en DE la frecuencia
	LD DE, (_d_fq)
	
	; Carga en A el intervalo
	LD A, (_interval)
	
	; Divide la frecuencia entre el intervalo para calcular la duración
	; Deja el resultado en DE
	CALL Divide
	
	; Hace sonar la nota
	CALL Beep

	; Comprueba si está en modo continuo
	LD A, B
	CP $00
	JP Z, playStaccato
	
; ------------------------------------------------------------------------------
; RE#
; ------------------------------------------------------------------------------
playDs:
	; Comprueba si se ha pulsado la tecla 3
	LD A, (_keys15)
	BIT $02, A
	JR NZ, playE

	; Carga en HL la nota RE#
	LD HL, (_ds)
	
	; Carga en DE la frecuencia
	LD DE, (_ds_fq)
	
	; Carga en A el intervalo
	LD A, (_interval)
	
	; Divide la frecuencia entre el intervalo para calcular la duración
	; Deja el resultado en DE
	CALL Divide
	
	; Hace sonar la nota
	CALL Beep

	; Comprueba si está en modo continuo
	LD A, B
	CP $00
	JP Z, playStaccato
	
; ------------------------------------------------------------------------------
; MI
; ------------------------------------------------------------------------------
playE:
	; Comprueba si se ha pulsado la tecla E
	LD A, (_keysQT)
	BIT $02, A
	JR NZ, playF
	
	; Carga en HL la nota MI
	LD HL, (_e)
	
	; Carga en DE la frecuencia
	LD DE, (_e_fq)
	
	; Carga en A el intervalo
	LD A, (_interval)
	
	; Divide la frecuencia entre el intervalo para calcular la duración
	; Deja el resultado en DE
	CALL Divide
	
	; Hace sonar la nota
	CALL Beep

	; Comprueba si está en modo continuo
	LD A, B
	CP $00
	JP Z, playStaccato
	
; ------------------------------------------------------------------------------
; FA
; ------------------------------------------------------------------------------
playF:
	; Comprueba si se ha pulsado la tecla Y
	LD A, (_keysPY)
	BIT $04, A
	JR NZ, playFs

	; Carga en HL la nota FA
	LD HL, (_f)
	
	; Carga en DE la frecuencia
	LD DE, (_f_fq)
	
	; Carga en A el intervalo
	LD A, (_interval)
	
	; Divide la frecuencia entre el intervalo para calcular la duración
	; Deja el resultado en DE
	CALL Divide
	
	; Hace sonar la nota
	CALL Beep

	; Comprueba si está en modo continuo
	LD A, B
	CP $00
	JP Z, playStaccato
	
; ------------------------------------------------------------------------------
; FA#
; ------------------------------------------------------------------------------
playFs:
	; Comprueba si se ha pulsado la tecla 7
	LD A, (_keys06)
	BIT $03, A
	JR NZ, playG

	; Carga en HL la nota FA#
	LD HL, (_fs)
	
	; Carga en DE la frecuencia
	LD DE, (_fs_fq)
	
	; Carga en A el intervalo
	LD A, (_interval)
	
	; Divide la frecuencia entre el intervalo para calcular la duración
	; Deja el resultado en DE
	CALL Divide
	
	; Hace sonar la nota
	CALL Beep

	; Comprueba si está en modo continuo
	LD A, B
	CP $00
	JP Z, playStaccato
	
; ------------------------------------------------------------------------------
; SOL
; ------------------------------------------------------------------------------
playG:
	; Comprueba si se ha pulsado la tecla U
	LD A, (_keysPY)
	BIT $03, A
	JR NZ, playGs

	; Carga en HL la nota SOL
	LD HL, (_g)
	
	; Carga en DE la frecuencia
	LD DE, (_g_fq)
	
	; Carga en A el intervalo
	LD A, (_interval)
	
	; Divide la frecuencia entre el intervalo para calcular la duración
	; Deja el resultado en DE
	CALL Divide
	
	; Hace sonar la nota
	CALL Beep

	; Comprueba si está en modo continuo
	LD A, B
	CP $00
	JP Z, playStaccato
	
; ------------------------------------------------------------------------------
; SOL#
; ------------------------------------------------------------------------------
playGs:
	; Comprueba si se ha pulsado la tecla 8
	LD A, (_keys06)
	BIT $02, A
	JR NZ, playA

	; Carga en HL la nota SOL#
	LD HL, (_gs)
	
	; Carga en DE la frecuencia
	LD DE, (_gs_fq)
	
	; Carga en A el intervalo
	LD A, (_interval)
	
	; Divide la frecuencia entre el intervalo para calcular la duración
	; Deja el resultado en DE
	CALL Divide
	
	; Hace sonar la nota
	CALL Beep

	; Comprueba si está en modo continuo
	LD A, B
	CP $00
	JP Z, playStaccato
	
; ------------------------------------------------------------------------------
; LA
; ------------------------------------------------------------------------------
playA:
	; Comprueba si se ha pulsado la tecla I
	LD A, (_keysPY)
	BIT $02, A
	JR NZ, playAs

	; Carga en HL la nota LA
	LD HL, (_a)
	
	; Carga en DE la frecuencia
	LD DE, (_a_fq)
	
	; Carga en A el intervalo
	LD A, (_interval)
	
	; Divide la frecuencia entre el intervalo para calcular la duración
	; Deja el resultado en DE
	CALL Divide
	
	; Hace sonar la nota
	CALL Beep

	; Comprueba si está en modo continuo
	LD A, B
	CP $00
	JP Z, playStaccato
	
; ------------------------------------------------------------------------------
; LA#
; ------------------------------------------------------------------------------
playAs:
	; Comprueba si se ha pulsado la tecla 9
	LD A, (_keys06)
	BIT $01, A
	JR NZ, playB

	; Carga en HL la nota LA
	LD HL, (_as)
	
	; Carga en DE la frecuencia
	LD DE, (_as_fq)
	
	; Carga en A el intervalo
	LD A, (_interval)
	
	; Divide la frecuencia entre el intervalo para calcular la duración
	; Deja el resultado en DE
	CALL Divide
	
	; Hace sonar la nota
	CALL Beep

	; Comprueba si está en modo continuo
	LD A, B
	CP $00
	JP Z, playStaccato
	
; ------------------------------------------------------------------------------
; SI
; ------------------------------------------------------------------------------
playB:
	; Comprueba si se ha pulsado la tecla O
	LD A, (_keysPY)
	BIT $01, A
	JR NZ, playLegato

	; Carga en HL la nota LA
	LD HL, (_b)
	
	; Carga en DE la frecuencia
	LD DE, (_b_fq)
	
	; Carga en A el intervalo
	LD A, (_interval)
	
	; Divide la frecuencia entre el intervalo para calcular la duración
	; Deja el resultado en DE
	CALL Divide
	; Hace sonar la nota
	CALL Beep

	; Comprueba si está en modo continuo
	LD A, B
	CP $00
	JP NZ, playLegato
	
playStaccato:
	CALL WaitKeyUp
	
playLegato:
	JP Play
	
; -----------------------------------------------------------------------------
; Carga la configuración de la escala
; -----------------------------------------------------------------------------
LoadScale:
	; Carga en A el indicador de la escala a cargar
	LD A, (_scale)

	; Comprueba si es la escala 2 y salta si es necesario
	CP $02
	JP Z, loadScale2

	; Comprueba si es la escala 3 y salta si es necesario
	CP $03
	JP Z, loadScale3

	; Comprueba si es la escala 4 y salta si es necesario
	CP $04
	JP Z, loadScale4


; -----------------------------------------------------------------------------
; Carga la configuración de las notas de la escala 1
; -----------------------------------------------------------------------------
loadScale1:
	; DO
	LD HL, C_1
	LD (_c), HL
	LD HL, C_1_FQ
	LD (_c_fq), HL

	; DO#
	LD HL, CS_1
	LD (_cs), HL
	LD HL, CS_1_FQ
	LD (_cs_fq), HL

	; RE
	LD HL, D_1
	LD (_d), HL
	LD HL, D_1_FQ
	LD (_d_fq), HL

	; RE#
	LD HL, DS_1
	LD (_ds), HL
	LD HL, DS_1_FQ
	LD (_ds_fq), HL

	; MI
	LD HL, E_1
	LD (_e), HL
	LD HL, E_1_FQ
	LD (_e_fq), HL

	; FA
	LD HL, F_1
	LD (_f), HL
	LD HL, F_1_FQ
	LD (_f_fq), HL

	; FA#
	LD HL, FS_1
	LD (_fs), HL
	LD HL, FS_1_FQ
	LD (_fs_fq), HL

	; SOL
	LD HL, G_1
	LD (_g), HL
	LD HL, G_1_FQ
	LD (_g_fq), HL

	; SOL #
	LD HL, GS_1
	LD (_gs), HL
	LD HL, GS_1_FQ
	LD (_gs_fq), HL

	; LA
	LD HL, A_1
	LD (_a), HL
	LD HL, A_1_FQ
	LD (_a_fq), HL

	; LA #
	LD HL, AS_1
	LD (_as), HL
	LD HL, AS_1_FQ
	LD (_as_fq), HL

	; SI
	LD HL, B_1
	LD (_b), HL
	LD HL, B_1_FQ
	LD (_b_fq), HL

	RET

; -----------------------------------------------------------------------------
; Carga la configuración de las notas de la escala 2
; -----------------------------------------------------------------------------
loadScale2:
	; DO
	LD HL, C_2
	LD (_c), HL
	LD HL, C_2_FQ
	LD (_c_fq), HL

	; DO#
	LD HL, CS_2
	LD (_cs), HL
	LD HL, CS_2_FQ
	LD (_cs_fq), HL

	; RE
	LD HL, D_2
	LD (_d), HL
	LD HL, D_2_FQ
	LD (_d_fq), HL

	; RE#
	LD HL, DS_2
	LD (_ds), HL
	LD HL, DS_2_FQ
	LD (_ds_fq), HL

	; MI
	LD HL, E_2
	LD (_e), HL
	LD HL, E_2_FQ
	LD (_e_fq), HL

	; FA
	LD HL, F_2
	LD (_f), HL
	LD HL, F_2_FQ
	LD (_f_fq), HL

	; FA#
	LD HL, FS_2
	LD (_fs), HL
	LD HL, FS_2_FQ
	LD (_fs_fq), HL

	; SOL
	LD HL, G_2
	LD (_g), HL
	LD HL, G_2_FQ
	LD (_g_fq), HL

	; SOL #
	LD HL, GS_2
	LD (_gs), HL
	LD HL, GS_2_FQ
	LD (_gs_fq), HL

	; LA
	LD HL, A_2
	LD (_a), HL
	LD HL, A_2_FQ
	LD (_a_fq), HL

	; LA #
	LD HL, AS_2
	LD (_as), HL
	LD HL, AS_2_FQ
	LD (_as_fq), HL

	; SI
	LD HL, B_2
	LD (_b), HL
	LD HL, B_2_FQ
	LD (_b_fq), HL

	RET

; -----------------------------------------------------------------------------
; Carga la configuración de las notas de la escala 3
; -----------------------------------------------------------------------------
loadScale3:
	; DO
	LD HL, C_3
	LD (_c), HL
	LD HL, C_3_FQ
	LD (_c_fq), HL

	; DO#
	LD HL, CS_3
	LD (_cs), HL
	LD HL, CS_3_FQ
	LD (_cs_fq), HL

	; RE
	LD HL, D_3
	LD (_d), HL
	LD HL, D_3_FQ
	LD (_d_fq), HL

	; RE#
	LD HL, DS_3
	LD (_ds), HL
	LD HL, DS_3_FQ
	LD (_ds_fq), HL

	; MI
	LD HL, E_3
	LD (_e), HL
	LD HL, E_3_FQ
	LD (_e_fq), HL

	; FA
	LD HL, F_3
	LD (_f), HL
	LD HL, F_3_FQ
	LD (_f_fq), HL

	; FA#
	LD HL, FS_3
	LD (_fs), HL
	LD HL, FS_3_FQ
	LD (_fs_fq), HL

	; SOL
	LD HL, G_3
	LD (_g), HL
	LD HL, G_3_FQ
	LD (_g_fq), HL

	; SOL #
	LD HL, GS_3
	LD (_gs), HL
	LD HL, GS_3_FQ
	LD (_gs_fq), HL

	; LA
	LD HL, A_3
	LD (_a), HL
	LD HL, A_3_FQ
	LD (_a_fq), HL

	; LA #
	LD HL, AS_3
	LD (_as), HL
	LD HL, AS_3_FQ
	LD (_as_fq), HL

	; SI
	LD HL, B_3
	LD (_b), HL
	LD HL, B_3_FQ
	LD (_b_fq), HL

	RET

; -----------------------------------------------------------------------------
; Carga la configuración de las notas de la escala 4
; -----------------------------------------------------------------------------
loadScale4:
	; DO
	LD HL, C_4
	LD (_c), HL
	LD HL, C_4_FQ
	LD (_c_fq), HL

	; DO#
	LD HL, CS_4
	LD (_cs), HL
	LD HL, CS_4_FQ
	LD (_cs_fq), HL

	; RE
	LD HL, D_4
	LD (_d), HL
	LD HL, D_4_FQ
	LD (_d_fq), HL

	; RE#
	LD HL, DS_4
	LD (_ds), HL
	LD HL, DS_4_FQ
	LD (_ds_fq), HL

	; MI
	LD HL, E_4
	LD (_e), HL
	LD HL, E_4_FQ
	LD (_e_fq), HL

	; FA
	LD HL, F_4
	LD (_f), HL
	LD HL, F_4_FQ
	LD (_f_fq), HL

	; FA#
	LD HL, FS_4
	LD (_fs), HL
	LD HL, FS_4_FQ
	LD (_fs_fq), HL

	; SOL
	LD HL, G_4
	LD (_g), HL
	LD HL, G_4_FQ
	LD (_g_fq), HL

	; SOL #
	LD HL, GS_4
	LD (_gs), HL
	LD HL, GS_4_FQ
	LD (_gs_fq), HL

	; LA
	LD HL, A_4
	LD (_a), HL
	LD HL, A_4_FQ
	LD (_a_fq), HL

	; LA #
	LD HL, AS_4
	LD (_as), HL
	LD HL, AS_4_FQ
	LD (_as_fq), HL

	; SI
	LD HL, B_4
	LD (_b), HL
	LD HL, B_4_FQ
	LD (_b_fq), HL

	RET

; -----------------------------------------------------------------------------
; Divide DE / A.
;
; Entrada:	DE = Dividendo
;		A  = Divisor
;
; Salida:	DE
;
; Altera el valor de los registros A y DE
;
; Rutina tomada http://z80-heaven.wikidot.com/math#toc18
;		En la rutina original divide HL / C
; -----------------------------------------------------------------------------
Divide:
	PUSH BC
	PUSH HL

	LD H, D
	LD L, E
	LD C, A
	LD B, $10
	XOR A

divide_loop:
	ADD HL, HL
	RLA
	CP C
	JR C, divide_loopEnd ; $+$04
	INC L
	SUB C
divide_loopEnd:
	DJNZ divide_loop ; $-$07

	LD D, H
	LD E, L

	POP HL
	POP BC
	
	RET
	
; ------------------------------------------------------------------------------
; Espera que no haya ninguna tecla pulsada
; ------------------------------------------------------------------------------
WaitKeyUp:
	; Lee todo el teclado
	LD A, $00
	IN A, ($FE)
	
	; Se queda solo con los bits de las teclas 0 a 4
	AND $1F
	
	; Si A != 31, se ha pulsado alguna tecla
	CP $1F
	JR NZ, WaitKeyUp
	
	RET
	
; Incluye los ficheros de código
include "System.asm"
include "Video.asm"
include "Sound.asm"

; ------------------------------------------------------------------------------
; Variables del programa
; ------------------------------------------------------------------------------
; Intervalo actual
_interval:	DB 0

; Escala actual
_scale:		DB	$03

; Notas actuales
_c:			DW 0, 0
_cs:		DW 0, 0
_d: 		DW 0, 0
_ds:		DW 0, 0
_e: 		DW 0, 0
_f: 		DW 0, 0
_fs:		DW 0, 0
_g: 		DW 0, 0
_gs: 		DW 0, 0
_a: 		DW 0, 0
_as: 		DW 0, 0
_b: 		DW 0, 0

; Fecuencias actuales
_c_fq:		DW 0, 0
_cs_fq:		DW 0, 0
_d_fq: 		DW 0, 0
_ds_fq:		DW 0, 0
_e_fq: 		DW 0, 0
_f_fq: 		DW 0, 0
_fs_fq:		DW 0, 0
_g_fq: 		DW 0, 0
_gs_fq: 	DW 0, 0
_a_fq: 		DW 0, 0
_as_fq: 	DW 0, 0
_b_fq: 		DW 0, 0

; Indica si el sonido es continuo (legato) o hace falta soltar una tecla para que suene el siguiente (staccato)
_legato	DB $01

; Estado de las semifilas del teclado
_keysCsV:	DB 0
_keysAG: 	DB 0
_keysQT: 	DB 0
_keys15:	DB 0
_keys06:	DB 0
_keysPY: 	DB 0
_keysEnH: 	DB 0
_keysSpB:	DB 0

end $5dad