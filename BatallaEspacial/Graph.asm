; -----------------------------------------------------------------------------
; Graph.asm
;
; Archivo que contiene la declaración de gráficos definidos por el usuario
; y los gráficos de los personajes.
; Contiene también las rutinas de carga de gráficos.
; -----------------------------------------------------------------------------

; -----------------------------------------------------------------------------
; Limpia los gráficos no generales
;
; Altera el valor de los registros B y HL
; -----------------------------------------------------------------------------
ClearUdgsExtension:
	LD B, udgsExtensionEnd - udgsExtension
	LD HL, udgsExtension
	
ClearUdgsExtension_loop:
	LD (HL), 0
	INC HL
	DJNZ ClearUdgsExtension_loop

	RET

; -----------------------------------------------------------------------------
; Carga los gráficos definidos por el usuario
;
; Altera el valor del registro HL
; -----------------------------------------------------------------------------
LoadUdgs:
	LD HL, udgsCommon
	LD (UDGDIR), HL

	RET

; -----------------------------------------------------------------------------
; Carga los gráficos definidos por el usuario relativos a los enemigos
;
; Entrada: levelCount -> Dependiendo del nivel, carga uno o otros enemigos
;
; Altera el valor de los registros A, BC, DE y HL
; -----------------------------------------------------------------------------
LoadUdgsEnemies:
	CALL ClearUdgsExtension

	LD A, (levelCount)
	CP $01	
	JP Z, LoadUdgsEnemies_1

	CP $02
	JP Z, LoadUdgsEnemies_2

	CP $03
	JP Z, LoadUdgsEnemies_3

	CP $04
	JP Z, LoadUdgsEnemies_4

	CP $05
	JP Z, LoadUdgsEnemies_5

	CP $06
	JP Z, LoadUdgsEnemies_6

	CP $07
	JP Z, LoadUdgsEnemies_7

	CP $08
	JP Z, LoadUdgsEnemies_8

	CP $09
	JP Z, LoadUdgsEnemies_9

	CP $10
	JP Z, LoadUdgsEnemies_10

	CP $11	
	JP Z, LoadUdgsEnemies_11

	CP $12
	JP Z, LoadUdgsEnemies_12

	CP $13
	JP Z, LoadUdgsEnemies_13

	CP $14
	JP Z, LoadUdgsEnemies_14

	CP $15
	JP Z, LoadUdgsEnemies_15

	CP $16
	JP Z, LoadUdgsEnemies_16

	CP $17
	JP Z, LoadUdgsEnemies_17

	CP $18
	JP Z, LoadUdgsEnemies_18

	CP $19
	JP Z, LoadUdgsEnemies_19

	CP $20
	JP Z, LoadUdgsEnemies_20

	CP $21	
	JP Z, LoadUdgsEnemies_21

	CP $22
	JP Z, LoadUdgsEnemies_22

	CP $23
	JP Z, LoadUdgsEnemies_23

	CP $24
	JP Z, LoadUdgsEnemies_24

	CP $25
	JP Z, LoadUdgsEnemies_25

	CP $26
	JP Z, LoadUdgsEnemies_26

	CP $27
	JP Z, LoadUdgsEnemies_27

	CP $28
	JP Z, LoadUdgsEnemies_28

	CP $29
	JP Z, LoadUdgsEnemies_29

	CP $30
	JP Z, LoadUdgsEnemies_30

LoadUdgsEnemies_1:
	LD HL, udgsEnemiesLevel1
	LD BC, udgsEnemiesLevel1End - udgsEnemiesLevel1

	JP LoadUdgsEnemies_end

LoadUdgsEnemies_2:
	LD HL, udgsEnemiesLevel2
	LD BC, udgsEnemiesLevel2End - udgsEnemiesLevel2

	JP LoadUdgsEnemies_end

LoadUdgsEnemies_3:
	LD HL, udgsEnemiesLevel3
	LD BC, udgsEnemiesLevel3End - udgsEnemiesLevel3

	JP LoadUdgsEnemies_end

LoadUdgsEnemies_4:
	LD HL, udgsEnemiesLevel4
	LD BC, udgsEnemiesLevel4End - udgsEnemiesLevel4

	JP LoadUdgsEnemies_end

LoadUdgsEnemies_5:
	LD HL, udgsEnemiesLevel5
	LD BC, udgsEnemiesLevel5End - udgsEnemiesLevel5

	JP LoadUdgsEnemies_end

LoadUdgsEnemies_6:
	LD HL, udgsEnemiesLevel6
	LD BC, udgsEnemiesLevel6End - udgsEnemiesLevel6

	JP LoadUdgsEnemies_end

LoadUdgsEnemies_7:
	LD HL, udgsEnemiesLevel7
	LD BC, udgsEnemiesLevel7End - udgsEnemiesLevel7

	JP LoadUdgsEnemies_end

LoadUdgsEnemies_8:
	LD HL, udgsEnemiesLevel8
	LD BC, udgsEnemiesLevel8End - udgsEnemiesLevel8

	JP LoadUdgsEnemies_end

LoadUdgsEnemies_9:
	LD HL, udgsEnemiesLevel9
	LD BC, udgsEnemiesLevel9End - udgsEnemiesLevel9

	JP LoadUdgsEnemies_end

LoadUdgsEnemies_10:
	LD HL, udgsEnemiesLevel10
	LD BC, udgsEnemiesLevel10End - udgsEnemiesLevel10

	JP LoadUdgsEnemies_end

LoadUdgsEnemies_11:
	LD HL, udgsEnemiesLevel11
	LD BC, udgsEnemiesLevel11End - udgsEnemiesLevel11

	JP LoadUdgsEnemies_end

LoadUdgsEnemies_12:
	LD HL, udgsEnemiesLevel12
	LD BC, udgsEnemiesLevel12End - udgsEnemiesLevel12

	JP LoadUdgsEnemies_end

LoadUdgsEnemies_13:
	LD HL, udgsEnemiesLevel13
	LD BC, udgsEnemiesLevel13End - udgsEnemiesLevel13

	JP LoadUdgsEnemies_end

LoadUdgsEnemies_14:
	LD HL, udgsEnemiesLevel14
	LD BC, udgsEnemiesLevel14End - udgsEnemiesLevel14

	JP LoadUdgsEnemies_end

LoadUdgsEnemies_15:
	LD HL, udgsEnemiesLevel15
	LD BC, udgsEnemiesLevel15End - udgsEnemiesLevel15

	JP LoadUdgsEnemies_end

LoadUdgsEnemies_16:
	LD HL, udgsEnemiesLevel16
	LD BC, udgsEnemiesLevel16End - udgsEnemiesLevel16

	JP LoadUdgsEnemies_end

LoadUdgsEnemies_17:
	LD HL, udgsEnemiesLevel17
	LD BC, udgsEnemiesLevel17End - udgsEnemiesLevel17

	JP LoadUdgsEnemies_end

LoadUdgsEnemies_18:
	LD HL, udgsEnemiesLevel18
	LD BC, udgsEnemiesLevel18End - udgsEnemiesLevel18

	JP LoadUdgsEnemies_end

LoadUdgsEnemies_19:
	LD HL, udgsEnemiesLevel19
	LD BC, udgsEnemiesLevel19End - udgsEnemiesLevel19

	JP LoadUdgsEnemies_end

LoadUdgsEnemies_20:
	LD HL, udgsEnemiesLevel20
	LD BC, udgsEnemiesLevel20End - udgsEnemiesLevel20

	JP LoadUdgsEnemies_end

LoadUdgsEnemies_21:
	LD HL, udgsEnemiesLevel21
	LD BC, udgsEnemiesLevel21End - udgsEnemiesLevel21

	JP LoadUdgsEnemies_end

LoadUdgsEnemies_22:
	LD HL, udgsEnemiesLevel22
	LD BC, udgsEnemiesLevel22End - udgsEnemiesLevel22

	JP LoadUdgsEnemies_end

LoadUdgsEnemies_23:
	LD HL, udgsEnemiesLevel23
	LD BC, udgsEnemiesLevel23End - udgsEnemiesLevel23

	JP LoadUdgsEnemies_end

LoadUdgsEnemies_24:
	LD HL, udgsEnemiesLevel24
	LD BC, udgsEnemiesLevel24End - udgsEnemiesLevel24

	JP LoadUdgsEnemies_end

LoadUdgsEnemies_25:
	LD HL, udgsEnemiesLevel25
	LD BC, udgsEnemiesLevel25End - udgsEnemiesLevel25

	JP LoadUdgsEnemies_end

LoadUdgsEnemies_26:
	LD HL, udgsEnemiesLevel26
	LD BC, udgsEnemiesLevel26End - udgsEnemiesLevel26

	JP LoadUdgsEnemies_end

LoadUdgsEnemies_27:
	LD HL, udgsEnemiesLevel27
	LD BC, udgsEnemiesLevel27End - udgsEnemiesLevel27

	JP LoadUdgsEnemies_end

LoadUdgsEnemies_28:
	LD HL, udgsEnemiesLevel28
	LD BC, udgsEnemiesLevel28End - udgsEnemiesLevel28

	JP LoadUdgsEnemies_end

LoadUdgsEnemies_29:
	LD HL, udgsEnemiesLevel29
	LD BC, udgsEnemiesLevel29End - udgsEnemiesLevel29

	JP LoadUdgsEnemies_end

LoadUdgsEnemies_30:
	LD HL, udgsEnemiesLevel30
	LD BC, udgsEnemiesLevel30End - udgsEnemiesLevel30

	JP LoadUdgsEnemies_end

LoadUdgsEnemies_end:
	LD DE, udgsExtension
	LDIR

	RET