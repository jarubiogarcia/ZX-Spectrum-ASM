; -----------------------------------------------------------------------------
; Graph.asm
;
; Contiene las rutinas de carga de gráficos.
; -----------------------------------------------------------------------------

; -----------------------------------------------------------------------------
; Carga los gráficos definidos por el usuario
;
; Altera el valor del registro HL
; -----------------------------------------------------------------------------
LoadUdgs:
	LD HL, udgsCommon
	LD (UDG), HL

	RET

; -----------------------------------------------------------------------------
; Carga los gráficos definidos por el usuario relativos a los enemigos
;
; Entrada: levelCount -> Dependiendo del nivel, carga uno o otros enemigos
;
; Altera el valor de los registros A, BC, DE y HL
; -----------------------------------------------------------------------------
LoadUdgsEnemies:
	; Carga la direccián de los enemigos del nivel 1
	LD HL, udgsEnemiesLevel1

	; Carga el nivel en A y calcula el valor decimal y decrementa 1
	LD A, (levelCount)
	CALL BCD2bin
	DEC A

	; Lo compara con 0, si es 0 carga los gráficos
	CP 0
	JR Z, LoadUdgsEnemies_end

	; Si no es 0 suma 32 bytes hasta llegar al los enemigos del nivel correspondiente
	LD B, A
	LD DE, 32
LoadUdgsEnemies_loop;
	ADD HL, DE
	DJNZ LoadUdgsEnemies_loop

LoadUdgsEnemies_end:
	LD DE, udgsExtension
	LD BC, 32
	LDIR

	RET