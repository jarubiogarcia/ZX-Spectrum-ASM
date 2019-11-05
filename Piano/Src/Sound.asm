; -----------------------------------------------------------------------------
; Sound.asm
;
; Rutinas y declaraciones relacionadas con el sonido.
; -----------------------------------------------------------------------------

; -----------------------------------------------------------------------------
; Hace sonar una nota
;
; Entrada:	HL = Nota
;		DE = Duración
; -----------------------------------------------------------------------------
Beep:
	; Preserva el valor de los registros ya que la rutina BEEPER de la ROM
	; los altera
	PUSH AF
	PUSH BC
	PUSH DE
	PUSH HL
	PUSH IX
	
	CALL BEEPER
	
	; Recupera el valor de los registros
	POP IX
	POP HL
	POP DE
	POP BC
	POP AF
	
	RET
	
; ------------------------------------------------------------------------------
; Duraciones de las notas
; ------------------------------------------------------------------------------
; Valor por el que multiplicar
REDONDA:		EQU	$04
BLANCA:			EQU	$02

; Indiferente multiplicar o dividir
NEGRA:			EQU	$01

; Valor por el que dividir
CORCHEA:		EQU	$02
SEMICORCHEA:		EQU	$04
FUSA:			EQU	$08
SEMIFUSA:		EQU	$10

; ------------------------------------------------------------------------------
; Duraciones de los silencios en milisegundos (Número de NOP a ejecutar)
; ------------------------------------------------------------------------------
SILENCIO1000:	EQU	$FFFF
SILENCIO0500:	EQU	$7FFF
SILENCIO0250:	EQU	$3FFF
SILENCIO0200:	EQU	$3333
SILENCIO0125:	EQU	$23E8
SILENCIO0100:	EQU	$199A
SILENCIO0062:	EQU	$003E
SILENCIO0050:	EQU	$0CCD
SILENCIO0040:	EQU	$0A3D
SILENCIO0030:	EQU	$0788
SILENCIO0025:	EQU	$0666
SILENCIO0020:	EQU	$051E
SILENCIO0015:	EQU	$03E1
SILENCIO0012:	EQU	$0333
SILENCIO0010:	EQU	$028F
SILENCIO0005:	EQU	$0148
SILENCIO0002_5:	EQU	$00A4
SILENCIO0002:	EQU	$0083
SILENCIO0001_2:	EQU	$0052
SILENCIO0001:	EQU	$0042

; ------------------------------------------------------------------------------
; Notas
; A		B		C		D		E		F		G
; La	Si		Do		Re		Mi		Fa		Sol
;
; S = sotenido
; 0 a 4 = escala. 0 más graves, 4 más aguda
; ------------------------------------------------------------------------------
F_0: 			EQU	$27A0
FS_0: 			EQU	$2508
G_0: 			EQU	$237C
GS_0: 			EQU	$2164
A_0: 			EQU	$1EF4
AS_0: 			EQU	$1D59
B_0: 			EQU	$1BE6
C_1: 			EQU	$1A2C
CS_1: 			EQU	$18A6
D_1: 			EQU	$174B
DS_1: 			EQU	$1613
E_1: 			EQU	$14B9
F_1: 			EQU	$1386
FS_1: 			EQU	$1275
G_1: 			EQU	$1180
GS_1: 			EQU	$1079
A_1: 			EQU	$0F6B
AS_1: 			EQU	$0E9D
B_1: 			EQU	$0DC6
C_2: 			EQU	$0D07
CS_2: 			EQU	$0C44
D_2: 			EQU	$0B96
DS_2: 			EQU	$0AE8
E_2: 			EQU	$0A4D
F_2: 			EQU	$09B4
FS_2: 			EQU	$092B
G_2: 			EQU	$08A5
GS_2: 			EQU	$0823
A_2: 			EQU	$07A6
AS_2: 			EQU	$0737
B_2: 			EQU	$06D4
C_3: 			EQU	$066E
CS_3: 			EQU	$060D
D_3: 			EQU	$05B7
DS_3: 			EQU	$0560
E_3: 			EQU	$0513
F_3: 			EQU	$04C7
FS_3: 			EQU	$0483
G_3: 			EQU	$0440
GS_3: 			EQU	$0400
A_3: 			EQU	$03C4
AS_3: 			EQU	$038C
B_3: 			EQU	$0359
C_4: 			EQU	$0326
CS_4:			EQU	$02F7
D_4: 			EQU	$02CB
DS_4: 			EQU	$02A1
E_4: 			EQU	$0279
F_4:			EQU	$0254
FS_4: 			EQU	$0231
G_4: 			EQU	$0210
GS_4: 			EQU	$01F1
A_4: 			EQU	$01D3
AS_4: 			EQU	$01B7
B_4: 			EQU	$019D

; ------------------------------------------------------------------------------
; Notas - Frecuencia
;
; La frecuencia marca la duraci�n de la nota.
; Las fecuencias aqu� mostradas hacen que las notas duren un segundo
; Para cambiar la duraci�n, hay que multiplicar o dividir por negra, fusa, etc.
; 
; fs_0_fq * redonda
; fs_0_fq * blanca
; fs_0_fq * negra, tmbi�n se puede dividir
; fs_0_fq / corchea
; fs_0_fq / semicorchea
; fs_0_fq / fusa
; fs_0_fq / semifusa
; ------------------------------------------------------------------------------
F_0_FQ: 		EQU $002B
FS_0_FQ: 		EQU $002E
G_0_FQ: 		EQU $0030
GS_0_FQ: 		EQU $0033
A_0_FQ: 		EQU $0037
AS_0_FQ: 		EQU $003A
B_0_FQ: 		EQU $003D
C_1_FQ: 		EQU $0041
CS_1_FQ: 		EQU $0045
D_1_FQ: 		EQU $0049
DS_1_FQ: 		EQU $004D
E_1_FQ: 		EQU $0052
F_1_FQ: 		EQU $0057
FS_1_FQ: 		EQU $005C
G_1_FQ: 		EQU $0061
GS_1_FQ: 		EQU $0067
A_1_FQ: 		EQU $006E
AS_1_FQ: 		EQU $0074
B_1_FQ: 		EQU $007B
C_2_FQ: 		EQU $0082
CS_2_FQ: 		EQU $008A
D_2_FQ: 		EQU $0092
DS_2_FQ: 		EQU $009B
E_2_FQ: 		EQU $00A4
F_2_FQ: 		EQU $00AE
FS_2_FQ: 		EQU $00B8
G_2_FQ: 		EQU $00C3
GS_2_FQ: 		EQU $00CF
A_2_FQ: 		EQU $00DC
AS_2_FQ: 		EQU $00E9
B_2_FQ: 		EQU $00F6
C_3_FQ: 		EQU $0105
CS_3_FQ: 		EQU $0115
D_3_FQ: 		EQU $0125
DS_3_FQ: 		EQU $0137
E_3_FQ: 		EQU $0149
F_3_FQ: 		EQU $015D
FS_3_FQ: 		EQU $0171
G_3_FQ: 		EQU $0187
GS_3_FQ: 		EQU $019F
A_3_FQ: 		EQU $01B8
AS_3_FQ: 		EQU $01D2
B_3_FQ: 		EQU $01ED
C_4_FQ: 		EQU $020B
CS_4_FQ: 		EQU $022A
D_4_FQ: 		EQU $024B
DS_4_FQ: 		EQU $026E
E_4_FQ: 		EQU $0293
F_4_FQ: 		EQU $02BA
FS_4_FQ: 		EQU $02E4
G_4_FQ: 		EQU $0310
GS_4_FQ: 		EQU $033E
A_4_FQ: 		EQU $0370
AS_4_FQ: 		EQU $03A4
B_4_FQ: 		EQU $03DB