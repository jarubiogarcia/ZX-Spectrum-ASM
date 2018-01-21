; -----------------------------------------------------------------------------
; Sonido que acompaña la destrucción de los enemigos
; -----------------------------------------------------------------------------
EnemiesCrashSound:
	PUSH AF
	PUSH BC
	PUSH DE
	PUSH HL

	LD HL, 5651
	LD DE, 1
	CALL BEEPER

	LD HL, 6310
	LD DE, 1
	CALL BEEPER

	LD HL, 4998
	LD DE, 1
	CALL BEEPER

	POP HL
	POP DE
	POP BC
	POP AF
	
	RET

; -----------------------------------------------------------------------------
; Sonido que acompaña al movimiento de los enemigos
; -----------------------------------------------------------------------------
EnemiesMoveSound:
	PUSH AF
	PUSH BC
	PUSH DE
	PUSH HL

	LD DE, 0
	LD HL, 10
	CALL BEEPER

	LD DE, 32
	LD HL, 20
	CALL BEEPER

	LD DE, 16
	LD HL, 10
	CALL BEEPER

	LD DE, 48
	LD HL, 30
	CALL BEEPER

	POP AF
	POP BC
	POP DE
	POP HL

	RET

; -----------------------------------------------------------------------------
; Sonido que acompaña el disparo
; -----------------------------------------------------------------------------
FireSound:
	PUSH AF
	PUSH BC
	PUSH DE
	PUSH HL

	LD HL, 100
	LD DE, 1
	CALL BEEPER

	POP HL
	POP DE
	POP BC
	POP AF

	RET

; -----------------------------------------------------------------------------
; Sonido que acompaña la explosión de la nave
; -----------------------------------------------------------------------------
ShipCrashSound:
	PUSH AF
	PUSH BC
	PUSH DE
	PUSH HL

	LD HL, 10144
	LD DE, 43 / 16
	CALL BEEPER
	HALT

	LD HL, 7924
	LD DE, 55 / 16
	CALL BEEPER
	HALT

	LD HL, 5305
	LD DE, 82 / 16
	CALL BEEPER
	HALT

	LD HL, 6700
	LD DE, 65 / 16
	CALL BEEPER
	HALT

	POP HL
	POP DE
	POP BC
	POP AF

	RET