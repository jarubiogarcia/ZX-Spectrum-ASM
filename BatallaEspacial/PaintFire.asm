; -----------------------------------------------------------------------------
; PaintFire.asm
;
; Archivo que contiene las rutinas para pintar todo lo relacionado con el disparo
; -----------------------------------------------------------------------------

; -----------------------------------------------------------------------------
; Anima el disparo.
;
; Altera el valor del registro A y HL (OJO CON HL, REVISAR AL DEPURAR)
; -----------------------------------------------------------------------------	
AnimeFire:
	; Borra el disparo de la posición actual
	CALL DeleteFire
	
	; Carga en A la coordenada Y del disparo
	LD A, (fireCoord)
	
	; Comprueba si está en el margen superior
	CP 23

	; Si es así salta a desactivar el disparo
	JR Z, AnimeFire_noAnime
	
	; Incrementa en 1 la coordenada Y del disparo
	INC A

	; La sube a memoria
	LD (fireCoord), A
	
	; Imprime el disparo
	CALL PaintFire
	
	; Sale
	JR AnimeFire_end
	
AnimeFire_noAnime:
	; Desactiva el fuego
	LD HL, flags1
	RES 1, (HL)

AnimeFire_end:
	RET

; -----------------------------------------------------------------------------
; Borra el disparo
;
; Altera el valor del registro A
; -----------------------------------------------------------------------------
DeleteFire:
	; Posiciona el cursor en las coordenadas del disparo
	CALL LocateFire
	
	; Borra el disparo
	LD A, " "
	RST $10
	
	RET

; -----------------------------------------------------------------------------
; Transforma las coordenadas de tipo LOCATE ROM a coordenadas de tipo 
; pantalla
;
; Entrada:	BC -> Coordenadas Y, X de tipo LOCATE ROM
; Salida:	BC -> Coordenadas Y, X de tipo pantalla
; -----------------------------------------------------------------------------
LocateCoordToScreenCoord:
	LD A, 24
	SUB B
	LD B, A

	LD A, 33
	SUB C
	LD C, A

	RET

; -----------------------------------------------------------------------------
; Posiciona el cursor en la posición del disparo
;
; Altera el valor de los registros BC y HL
; -----------------------------------------------------------------------------
LocateFire:
	; Obtiene la coordenada Y del disparo y la carga en B
	LD HL, fireCoord
	LD B, (HL)
	
	; Avanza a la posición de memoria donde está la coordenada X del disparo y la carga en B
	INC HL
	LD C, (HL)
	
	; Posiciona el cursor
	CALL Locate
	
	RET

; -----------------------------------------------------------------------------
; Pinta el disparo
;
; Altera el valor del registro A
; -----------------------------------------------------------------------------
PaintFire:
	; Posiciona el cursor en las coordenadas del disparo
	CALL LocateFire

	; Imprime el disparo
	LD A, (fireGraph)
	RST $10

	; Obtiene las coordenadas actuales del disparo
	LD HL, fireCoord
	LD B, (HL)
	INC HL
	LD C, (HL)

	; Pone el carácter dónde se ha pintado el disparo en rojo
	LD A, 2
	CALL SetInkLR

	RET