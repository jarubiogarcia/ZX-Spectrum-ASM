Siguiendo con el curso https://wiki.speccy.org/cursos/ensamblador/indice, y con el primer capítulo
dedicado a los gráficos leído, aplico lo aprendido al marciano.

He mejorado, creo, alguna cosa y de paso he reducido apróximadamente un 1KB el tamaño.

A continuación detallo los cambios realizados.

Cast.asm
	Añado este fichero con una subrutina, BCD2bin, que convierte números BCD a binario.

Const.asm
	Quito las constantes y se sustituyo por otras nuevas y documentadas.

Graph.asm:
	Reprogramo este fichero. Optimizo la carga de gráficos de los enemigos de cada nivel.
	
Main.asm
	Main
		Combio la carga de la rutina ISR para que el fichero .tap reflege el tamaño real.
		Quito las referencias a levelType porque no se usan.
			El JP final de Game_loopEnd pasa a ser JR.
	Game_win y Game_over
		El primer bloque de estas subrutinas es el mismo. Creo subrutina Game_changeScreen y se llama.
	
Paint.asm
	ClearAttributes
		Añado esta subrutina que limpia el área de atributos de la VideoRAM con el valor dado en A.
	ClearScreen:
		Añado esta subrutina que limpia el área gráfica de la VideoRAM con el patrón dado en A. 0 limpia todo.
		Sustitye a ClsScreen.
	ClsScreen
		Elimino.
	FadeScreen
		Añado esta subrutina que realiza un efecto de desvanecimiento de la pantalla.
	GetAttributeOffsetLR
		Elimino.
	Locate
		Elimino.
	PaintBCD
		Modifico para que no imprima los 0 no significativos, a la izquierda.
		El resultado final es más complejo que el anterior y penaliza algo en el pintado de enemigos.
	SetBorder
		Añado esta subrutina que asigna el color al borde.
	SetInk
		Añado esta subrutina para cambiar el atributo de color. Más sencilla y menos coste que SetInkLR.
		Hace inecesaria la subrutina GetAttributeOffsetLR.
	SetInkLR
		Elimino.
	SetLocation
		Sustituye a Location, es un simple cambio de nombre.
		
PaintEnemy.asm
	PaintEnemies
		Al cambiar la forma de cambiar la tinta de los gráficos, se asigna una sola vez el color, al principio
		de la subrutina, en lugar de tantas veces como enemigos se pintan, que es como se hacía antes.
		Optimiza el rendimiento aunque se ve un poco empañado por la modificación relizada en PaintBCD.
		
PaintFire.asm
	PaintFire
		Igual a PaintEnemies
		
PaintShip.asm
	AnimeCrashShip, PaintShip
		Igual a PaintEnemies
		
Var.asm
	Quito la declaración levelType porque no se usa.
	Quito las etiquetas _end y DB 0 en udgsEnemiesLevel1 ... 30
