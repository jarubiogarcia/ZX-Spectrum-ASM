Check CEA35629
Auto 8224

# Run-time Variables

Var puntos: Num = 5
Var tiempo: Num = 10
Var jugadores: Num = 1
Var winj1: Num = 0
Var winj2: Num = 0
Var tablas: Num = 0
Var jugador: Num = 1
Var cuadrados: Num = 0
Var cuadrado: Num = 0
Var posx: Num = 0
Var posy: Num = 0
Var posx2: Num = 0
Var posy2: Num = 0
Var ganador: Num = 0
Var linea: Num = 0
Var decimas: Num = 0
Var segundos: Num = 0
Var c: NumArray(9, 2) = 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
Var n: NumFOR = 0, 9, 1, 1310, 2
Var l$: Str = "\\\\#013"
Var k$: Str = " "
Var j$: StrArray(2, 8) = "                "

# End Run-time Variables

  10 REM ********************
  20 REM *** Tres en raya ***
  30 REM ********************
  40 LET puntos=5: LET tiempo=10: LET jugadores=1
  50 LET winj1=0: LET winj2=0: LET tablas=0: LET jugador=1: LET cuadrados=0: LET cuadrado=0: LET posx=0: LET posy=0: LET posx2=0: LET posy2=0: LET ganador=0: LET linea=0: LET decimas=0: LET segundos=0: LET n=0: DIM j$(2,8): LET k$="": DIM c(9,2)
  60 BORDER 0: PAPER 0: INK 7
  70 GO SUB 1000
  80 IF winj1>=puntos OR winj2>=puntos OR tablas>=puntos*2 THEN GO SUB 4900: GO SUB 5100: GO TO 50
  90 GO SUB 1200
 100 LET decimas=10: LET segundos=tiempo
 200 REM **************************
 210 REM *** Bucle del programa ***
 220 REM **************************
 230 PRINT AT 20,1; INK jugador+4;"Turno para ";j$(jugador,1 TO 8)
 240 IF jugadores=1 AND jugador=2 THEN GO SUB 3000: GO TO 310
 250 PRINT AT 13,2; INK 3;segundos;" ";AT 13,29;segundos;" "
 260 PAUSE 4: LET decimas=decimas-1: GO SUB 5000: IF segundos<1 THEN LET decimas=10: LET segundos=tiempo: GO TO 200
 270 LET k$=INKEY$()
 280 IF k$=CHR$ 32 THEN GO TO 10
 290 IF k$<"1" OR k$>"9" OR k$="" THEN GO TO 250
 300 LET cuadrado=VAL k$
 310 GO SUB 1500: REM *** Envia a comprobar el movimiento
 320 GO SUB 1800: REM *** Envia a comprobar si hay ganador
 330 IF ganador<0 THEN PRINT INK 2;AT 20,22;"TABLAS!!!": LET tablas=tablas+1: GO SUB 4900: BEEP 0.2,3: PAUSE 100: PRINT AT 20,17;"         ": GO TO 80
 340 IF ganador=0 THEN GO TO 200
 350 IF ganador=1 THEN LET winj1=winj1+1
 360 IF ganador=2 THEN LET winj2=winj2+1
 370 GO SUB 4900: PRINT INK 4;AT 20,1;"Ha ganado ";j$(ganador,1 TO 8);"     ": BEEP 0.1,1: BEEP 0.1,2: BEEP 0.1,3: PAUSE 100: PRINT AT 20,1;"                           ": GO TO 80
1000 REM **********************
1010 REM *** Menu principal ***
1020 REM **********************
1030 CLS
1040 PRINT AT 0,10; INK 7;"Tres en Raya": PRINT AT 3,8; INK 5;"0. Empezar": PRINT AT 5,8; INK 6;"1. Jugadores:": PRINT AT 7,8; INK 6;"2. Puntos:": PRINT AT 9,8; INK 6;"3. Tiempo:"
1050 PRINT AT 5,23; INK 2;jugadores: PRINT AT 7,23; INK 2;puntos: PRINT AT 9,23; INK 2;tiempo;" "
1060 LET k$=INKEY$(): IF k$="" THEN GO TO 1060
1070 IF k$<"0" OR k$>"3" THEN GO TO 1060
1080 IF k$="1" THEN LET jugadores=jugadores+1: IF jugadores>2 THEN LET jugadores=1
1090 IF k$="2" THEN LET puntos=puntos+1: IF puntos>5 THEN LET puntos=1
1100 IF k$="3" THEN LET tiempo=tiempo+5: IF tiempo>30 THEN LET tiempo=5
1110 IF k$<>"0" THEN GO SUB 2200: GO TO 1050
1120 GO SUB 2300
1130 IF jugadores=1 THEN LET j$(2,1 TO 8)="Spectrum"
1140 IF jugadores=2 THEN LET jugador=2: GO SUB 2300: LET jugador=1
1150 RETURN
1200 REM ************************************
1210 REM *** Pinta tablero e inicia punto ***
1220 REM ************************************
1230 CLS
1240 IF puntos<2 THEN PRINT AT 0,5; INK 7;"Tres en Raya a ";puntos;" punto"
1250 IF puntos>1 THEN PRINT AT 0,5; INK 7;"Tres en Raya a ";puntos;" puntos"
1260 PRINT AT 2,12; INK 2;"Tablas"
1270 INK 2: PRINT AT 2,1;j$(1,1 TO 8): INK 5: PLOT 10,140: DRAW 10,-10: PLOT 20,140: DRAW -10,-10
1280 INK 2: PRINT AT 2,22;j$(2,1 TO 8): INK 6: CIRCLE 185,135,7
1290 INK 4: PLOT 105,120: DRAW 0,-100: PLOT 145,120: DRAW 0,-100: PLOT 65,90: DRAW 120,0: PLOT 65,50: DRAW 120,0
1300 INK 3: PRINT AT 6,10;"1": PRINT AT 6,15;"2": PRINT AT 6,20;"3": PRINT AT 11,10;"4": PRINT AT 11,15;"5": PRINT AT 11,20;"6": PRINT AT 16,10;"7": PRINT AT 16,15;"8": PRINT AT 16,20;"9"
1310 FOR n=1 TO 9: LET c(n,1)=0: LET c(n,2)=0: NEXT n
1320 LET ganador=0: LET cuadrados=0
1330 GO SUB 4900
1340 RETURN
1500 REM *******************************
1510 REM *** Comprobacion movimiento ***
1520 REM *******************************
1530 IF c(cuadrado,1)+c(cuadrado,2)>0 THEN PRINT AT 20,22; INK 2;"Error": BEEP 0.5,-10: PAUSE 100: PRINT AT 20,22;"     ": GO TO 1680
1540 LET decimas=10: LET segundos=tiempo
1550 LET c(cuadrado,jugador)=1
1560 IF cuadrado=1 THEN LET posx=80: LET posy=110
1570 IF cuadrado=2 THEN LET posx=120: LET posy=110
1580 IF cuadrado=3 THEN LET posx=160: LET posy=110
1590 IF cuadrado=4 THEN LET posx=80: LET posy=70
1600 IF cuadrado=5 THEN LET posx=120: LET posy=70
1610 IF cuadrado=6 THEN LET posx=160: LET posy=70
1620 IF cuadrado=7 THEN LET posx=80: LET posy=35
1630 IF cuadrado=8 THEN LET posx=120: LET posy=35
1640 IF cuadrado=9 THEN LET posx=160: LET posy=35
1650 IF jugador=1 THEN INK 5: PLOT posx,posy: DRAW 10,-10: PLOT posx+10,posy: DRAW -10,-10
1660 IF jugador=2 THEN INK 6: CIRCLE posx+5,posy-5,7
1670 LET jugador=jugador+1: LET cuadrados=cuadrados+1: LET k$="": IF jugador>2 THEN LET jugador=1
1680 RETURN
1800 REM *******************************
1810 REM *** Comprobacion de ganador ***
1820 REM *******************************
1830 IF cuadrados<3 THEN GO TO 1990
1840 REM **************************************
1850 REM *** Comprueba si hay algun ganador ***
1860 REM **************************************
1870 FOR n=1 TO 2
1880 IF c(1,n)=1 AND c(2,n)=1 AND c(3,n)=1 THEN LET ganador=n: LET linea=1
1890 IF c(4,n)=1 AND c(5,n)=1 AND c(6,n)=1 THEN LET ganador=n: LET linea=2
1900 IF c(7,n)=1 AND c(8,n)=1 AND c(9,n)=1 THEN LET ganador=n: LET linea=3
1910 IF c(1,n)=1 AND c(4,n)=1 AND c(7,n)=1 THEN LET ganador=n: LET linea=4
1920 IF c(2,n)=1 AND c(5,n)=1 AND c(8,n)=1 THEN LET ganador=n: LET linea=5
1930 IF c(3,n)=1 AND c(6,n)=1 AND c(9,n)=1 THEN LET ganador=n: LET linea=6
1940 IF c(1,n)=1 AND c(5,n)=1 AND c(9,n)=1 THEN LET ganador=n: LET linea=7
1950 IF c(3,n)=1 AND c(5,n)=1 AND c(7,n)=1 THEN LET ganador=n: LET linea=8
1960 NEXT n
1970 IF ganador>0 THEN GO SUB 2000
1980 IF cuadrados>8 AND ganador=0 THEN LET ganador=-1
1990 RETURN
2000 REM *******************************************
2010 REM *** Dibuja la linea de las tres en raya ***
2020 REM *******************************************
2030 IF linea=1 THEN LET posx=70: LET posy=105: LET posx2=110: LET posy2=0: REM *** Linea horizontal 1 a 3 ***
2040 IF linea=2 THEN LET posx=70: LET posy=65: LET posx2=110: LET posy2=0: REM *** Linea horizontal 4 a 6 ***
2050 IF linea=3 THEN LET posx=70: LET posy=30: LET posx2=110: LET posy2=0: REM *** Linea horizontal 7 a 8 ***
2060 IF linea=4 THEN LET posx=85: LET posy=120: LET posx2=0: LET posy2=-100: REM *** Linea vertical 1 a 7
2070 IF linea=5 THEN LET posx=125: LET posy=120: LET posx2=0: LET posy2=-100: REM *** Linea vertical 2 a 8
2080 IF linea=6 THEN LET posx=165: LET posy=120: LET posx2=0: LET posy2=-100: REM *** Linea vertical 3 a 9
2090 IF linea=7 THEN LET posx=70: LET posy=120: LET posx2=105: LET posy2=-100: REM *** Linea diagonal 1 a 9
2100 IF linea=8 THEN LET posx=180: LET posy=120: LET posx2=-105: LET posy2=-100: REM *** Linea diagonal 3 a 7
2110 PLOT posx,posy: DRAW posx2,posy2: RETURN
2200 REM ****************************************
2210 REM *** Espera que no haya tecla pulsada ***
2220 REM ****************************************
2230 LET k$=INKEY$()
2240 IF k$<>"" THEN GO TO 2230
2250 RETURN
2300 REM *******************
2310 REM *** Pide nombre ***
2320 REM *******************
2330 PRINT INK 4;AT 15,1;"Nombre del jugador ";jugador
2340 FOR n=1 TO 8
2350 LET l$=INKEY$(): IF l$="" THEN GO TO 2350: REM Solicita una tecla
2360 IF l$=CHR$ 12 AND n>1 THEN LET j$(jugador,n-1 TO n-1)=" ": PRINT AT 15,20+n;" ": LET n=n-1: GO SUB 2200: GO TO 2350: REM Ha pulsado la tecla borrar
2370 IF l$=CHR$ 13 AND n>1 THEN LET n=8: GO TO 2400: REM Ha pulsado la tecla enter
2380 IF l$<"A" OR (l$>"Z" AND l$<"a") OR l$>"z" THEN GO SUB 2200: GO TO 2350: REM *** La tecla pulsada no es una letra ***
2390 LET j$(jugador,n TO n)=l$: PRINT INK 3;AT 15,21+n;l$
2400 GO SUB 2200
2410 NEXT n
2420 PRINT AT 15,22;"        "
2430 RETURN
3000 REM *******************************
3010 REM *** Movimiento del Spectrum ***
3020 REM *******************************
3030 PRINT AT 13,2;"  ";AT 13,29;"  ": PAUSE 21
3040 IF cuadrados=0 THEN LET cuadrado=1+INT (RND*8): GO TO 4750
3050 IF cuadrados<2 AND c(5,1)=0 THEN LET cuadrado=5: GO TO 4750
3100 REM *************************************************
3110 REM *** Movimiento ofensivo, comprueba para ganar ***
3120 REM *************************************************
3130 REM *** Evalua posibilidad en horizontal 1-3
3140 IF c(1,1)+c(2,1)+c(3,1)>0 OR c(1,2)+c(2,2)+c(3,2)<2 THEN GO TO 3190
3150 FOR n=1 TO 3
3160 GO SUB 4800
3170 NEXT n
3180 GO TO 4750
3190 REM *** Evalua posibilidad en horizontal 4-6
3200 IF c(4,1)+c(5,1)+c(6,1)>0 OR c(4,2)+c(5,2)+c(6,2)<2 THEN GO TO 3310
3210 FOR n=4 TO 6
3220 GO SUB 4800
3230 NEXT n
3240 GO TO 4750
3250 REM *** Evalua posibilidad en horizontal 7-9
3260 IF c(7,1)+c(8,1)+c(9,1)>0 OR c(7,2)+c(8,2)+c(9,2)<2 THEN GO TO 3310
3270 FOR n=7 TO 9
3280 GO SUB 4800
3290 NEXT n
3300 GO TO 4750
3310 REM *** Evalua posibilidad en vertical 1-7
3320 IF c(1,1)+c(4,1)+c(7,1)>0 OR c(1,2)+c(4,2)+c(7,2)<2 THEN GO TO 3370
3330 FOR n=1 TO 7 STEP 3
3340 GO SUB 4800
3350 NEXT n
3360 GO TO 4750
3370 REM *** Evalua posibilidad en vertical 2-8
3380 IF c(2,1)+c(5,1)+c(8,1)>0 OR c(2,2)+c(5,2)+c(8,2)<2 THEN GO TO 3430
3390 FOR n=2 TO 8 STEP 3
3400 GO SUB 4800
3410 NEXT n
3420 GO TO 4750
3430 REM *** Evalua posibilidad en vertical 3-9
3440 IF c(3,1)+c(6,1)+c(9,1)>0 OR c(3,2)+c(6,2)+c(9,2)<2 THEN GO TO 3490
3450 FOR n=3 TO 9 STEP 3
3460 GO SUB 4800
3470 NEXT n
3480 GO TO 4750
3490 REM *** Evalua posibilidad en diagonal 1-9
3500 IF c(1,1)+c(5,1)+c(9,1)>0 OR c(1,2)+c(5,2)+c(9,2)<2 THEN GO TO 3550
3510 FOR n=1 TO 9 STEP 4
3520 GO SUB 4800
3530 NEXT n
3540 GO TO 4750
3550 REM *** Evalua posibilidad en diagonal 3-7
3560 IF c(3,1)+c(5,1)+c(7,1)>0 OR c(3,2)+c(5,2)+c(7,2)<2 THEN GO TO 3700
3570 FOR n=3 TO 7 STEP 2
3580 GO SUB 4800
3590 NEXT n
3600 GO TO 4750
3700 REM ****************************
3710 REM *** Movimiento defensivo ***
3720 REM ****************************
3730 REM *** Horizontal 1-3 ***
3740 IF c(1,1)+c(2,1)+c(3,1)<2 OR c(1,2)+c(2,2)+c(3,2)>0 THEN GO TO 3770
3750 FOR n=1 TO 3: GO SUB 4800: NEXT n
3760 GO TO 4750
3770 REM *** Horizontal 4-6 ***
3780 IF c(4,1)+c(5,1)+c(6,1)<2 OR c(4,2)+c(5,2)+c(6,2)>0 THEN GO TO 3810
3790 FOR n=4 TO 6: GO SUB 4800: NEXT n
3800 GO TO 4750
3810 REM *** Horizontal 7-9 ***
3820 IF c(7,1)+c(8,1)+c(9,1)<2 OR c(7,2)+c(8,2)+c(9,2)>0 THEN GO TO 3850
3830 FOR n=7 TO 9: GO SUB 4800: NEXT n
3840 GO TO 4750
3850 REM *** Vertical 1-7 ***
3860 IF c(1,1)+c(4,1)+c(7,1)<2 OR c(1,2)+c(4,2)+c(7,2)>0 THEN GO TO 3890
3870 FOR n=1 TO 7 STEP 3: GO SUB 4800: NEXT n
3880 GO TO 4750
3890 REM *** Vertical 2-8 ***
3900 IF c(2,1)+c(5,1)+c(8,1)<2 OR c(2,2)+c(5,2)+c(8,2)>0 THEN GO TO 3930
3910 FOR n=2 TO 8 STEP 3: GO SUB 4800: NEXT n
3920 GO TO 4750
3930 REM *** Vertical 3-9 ***
3940 IF c(3,1)+c(6,1)+c(9,1)<2 OR c(3,2)+c(6,2)+c(9,2)>0 THEN GO TO 3970
3950 FOR n=3 TO 9 STEP 3: GO SUB 4800: NEXT n
3960 GO TO 4750
3970 REM *** Diagonal 1-9 ***
3980 IF c(1,1)+c(5,1)+c(9,1)<2 OR c(1,2)+c(5,2)+c(9,2)>0 THEN GO TO 4010
3990 FOR n=1 TO 9 STEP 4: GO SUB 4800: NEXT n
4000 GO TO 4750
4010 REM *** Diagonal 3-7 ***
4020 IF c(3,1)+c(5,1)+c(7,1)<2 OR c(3,2)+c(5,2)+c(7,2)>0 THEN GO TO 4050
4030 FOR n=3 TO 7 STEP 2: GO SUB 4800: NEXT n
4040 GO TO 4750
4050 REM *** Comprueba si jugador 1 intenta jugada diagonal ***
4060 IF c(1,1)+c(9,1)<2 AND c(3,1)+c(7,1)<2 THEN GO TO 4120
4070 REM *** Jugador 1 intenta jugada diagonal. Bloqueo en cruz ***
4080 IF c(4,1)+c(4,2)=0 THEN LET cuadrado=4: GO TO 4750
4090 IF c(6,1)+c(6,2)=0 THEN LET cuadrado=6: GO TO 4750
4100 IF c(2,1)+c(2,2)=0 THEN LET cuadrado=2: GO TO 4750
4110 IF c(8,1)+c(8,2)=0 THEN LET cuadrado=4: GO TO 4750
4120 REM *** Evalua si jugador 1 intenta jugada a esquina y cruz ***
4130 IF c(1,1)+c(6,1)=2 AND c(3,1)+c(3,2)=0 THEN LET cuadrado=3: GO TO 4750
4140 IF c(3,1)+c(4,1)=2 AND c(6,1)+c(6,2)=0 THEN LET cuadrado=6: GO TO 4750
4150 IF c(6,1)+c(7,1)=2 AND c(9,1)+c(9,2)=0 THEN LET cuadrado=9: GO TO 4750
4160 IF c(4,1)+c(9,1)=2 AND c(7,1)+c(7,2)=0 THEN LET cuadrado=7: GO TO 4750
4170 IF (c(1,1)+c(8,1)=2 OR c(2,1)+c(7,1)=2) AND c(4,1)+c(4,2)=0 THEN LET cuadrado=4: GO TO 4750
4180 IF (c(2,1)+c(9,1)=2 OR c(3,1)+c(8,1)=2) AND c(6,1)+c(6,2)=0 THEN LET cuadrado=6: GO TO 4750
4200 REM ***************************
4210 REM *** Movimiento ofensivo ***
4220 REM ***************************
4230 REM *** Evalua si hay espacio en horizontal 1-3
4240 IF c(1,1)+c(2,1)+c(3,1)<>0 OR c(1,2)+c(2,2)+c(3,2)>1 THEN GO TO 4290
4250 FOR n=1 TO 3
4260 GO SUB 4800
4270 NEXT n
4280 GO TO 4750
4290 REM *** Evalua si hay espacio en horizontal 4-6
4300 IF c(4,1)+c(5,1)+c(6,1)<>0 OR c(4,2)+c(5,2)+c(6,2)>1 THEN GO TO 4350
4310 FOR n=4 TO 6
4320 GO SUB 4800
4330 NEXT n
4340 GO TO 4750
4350 REM *** Evalua si hay espacio en horizontal 7-9
4360 IF c(7,1)+c(8,1)+c(9,1)<>0 OR c(7,2)+c(8,2)+c(9,2)>1 THEN GO TO 4410
4370 FOR n=7 TO 9
4380 GO SUB 4800
4390 NEXT n
4400 GO TO 4750
4410 REM *** Evalua si hay espacio en vertical  1-7
4420 IF c(1,1)+c(4,1)+c(7,1)<>0 OR c(1,2)+c(4,2)+c(7,2)>1 THEN GO TO 4470
4430 FOR n=1 TO 7 STEP 3
4440 GO SUB 4800
4450 NEXT n
4460 GO TO 4750
4470 REM *** Evalua si hay espacio en vertical  2-8
4480 IF c(2,1)+c(5,1)+c(8,1)<>0 OR c(2,2)+c(5,2)+c(8,2)>1 THEN GO TO 4530
4490 FOR n=2 TO 8 STEP 3
4500 GO SUB 4800
4510 NEXT n
4520 GO TO 4750
4530 REM *** Evalua si hay espacio en vertical  3-9
4540 IF c(3,1)+c(6,1)+c(9,1)<>0 OR c(3,2)+c(6,2)+c(9,2)>1 THEN GO TO 4590
4550 FOR n=3 TO 9 STEP 3
4560 GO SUB 4800
4570 NEXT n
4580 GO TO 4750
4590 REM *** Evalua si hay espacio en diagonal 1-9
4600 IF c(1,1)+c(5,1)+c(9,1)<>0 OR c(1,2)+c(5,2)+c(9,2)>1 THEN GO TO 4650
4610 FOR n=1 TO 9 STEP 4
4620 GO SUB 4800
4630 NEXT n
4640 GO TO 4750
4650 REM *** Evalua si hay espacio en diagonal 3-7
4660 IF c(3,1)+c(5,1)+c(7,1)<>0 OR c(3,2)+c(5,2)+c(7,2)>1 THEN GO TO 4710
4670 FOR n=3 TO 7 STEP 2
4680 GO SUB 4800
4690 NEXT n
4700 GO TO 4750
4710 REM *** Busca hueco libre
4720 FOR n=1 TO 9
4730 GO SUB 4800
4740 NEXT n
4750 RETURN
4800 REM ***************************************************
4810 REM *** Evalua si la celda esta libre, desde bucles ***
4820 REM ***************************************************
4830 IF c(n,1)+c(n,2)=0 THEN LET cuadrado=n: LET n=9
4840 RETURN
4900 REM ******************
4910 REM *** Puntuacion ***
4920 REM ******************
4930 PRINT INK 5;AT 4,5;winj1
4940 PRINT INK 7;AT 4,15;tablas;" "
4950 PRINT INK 6;AT 4,26;winj2
4960 RETURN
5000 REM ********************
5010 REM *** Temporizador ***
5020 REM ********************
5030 LET decimas=decimas-1
5040 IF decimas<1 THEN LET decimas=10: LET segundos=segundos-1: IF segundos<4 THEN BEEP 0.1,0.1
5050 IF segundos<1 THEN PRINT AT 13,2;"0 ";AT 13,2;"0 ": PRINT AT 20,1; INK 2;"Pierde turno!!!           ": BEEP 0.5,-10: LET jugador=jugador+1
5060 IF jugador>2 THEN LET jugador=1
5070 RETURN
5100 REM **********************
5110 REM *** Fin de partida ***
5120 REM **********************
5130 PRINT AT 20,1;"                                "
5140 PRINT AT 21,7; PAPER 0; INK 7; FLASH 1;"Partida terminada"
5150 PAUSE 0
5160 RETURN
