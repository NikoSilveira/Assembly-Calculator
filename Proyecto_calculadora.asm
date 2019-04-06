.data
mensaje1:	.asciiz "\nIngrese el string con el primer numero (max 50 digitos con 2 decimales):"
mensaje2:	.asciiz "\nIngrese el string con el segundo numero (max 50 digitos con 2 decimales):"
mensaje3:	.asciiz "Atencion: para la resta, primero digite el minuendo y despues el sustraendo"
mensaje4:	.asciiz "\nIngrese el string con el primer numero (max 25 digitos con 2 decimales):"
mensaje5:	.asciiz "\nIngrese el string con el segundo numero (max 25 digitos con 2 decimales):"
opciones:	.asciiz "\nIngrese: (1) para sumar \n\t (2) para restar \n\t (3) para multiplicar \n"
mensajeFinal:	.asciiz "\nResultado: "
negativo:	.asciiz "-"
pregunta:	.asciiz "\nDesea realizar otra operacion? s/n "

empty1:		.space 53 #Array de 53 Bytes para un String de 50 chars + .00
empty2:		.space 53 #Array de 53 Bytes para segundo String
volteado1:	.space 53 #Array que recibe el numero volteado con coma
volteado2:	.space 53 #Array que recibe el numero volteado con coma
hexa1:  	.space 52 #Array con los numeros ajustados en hexadecimal
hexa2:  	.space 52 #Array con ajuste hexadecimal
result: 	.space 53 #resultado final a imprimir (print inverso)

empty3:		.space 28 #Array de 25 + .00
empty4:		.space 28 #Array de 25 + .00
volteado3:	.space 28 #Recibe numero volteado con coma
volteado4:	.space 28 #Recibe numero volteado con coma
hexa3:		.space 27 #Numeros ajustados en hexadecimal
hexa4:		.space 27 #Numeros ajsutados en hexadecimal
result2:	.space 62 #Resultado de multiplicacion
aux:		.space 62 #Vector para almacenar esultadod e multip. individual

.text
.globl main
main:

#INPUT-------
	#Alerta
	li $v0, 4
	la $a0, mensaje3
	syscall

	#Prompt tipo de operacion
	li $v0, 4
	la $a0, opciones
	syscall
	
	#Input del tipo de operacion
	li $v0, 5
	syscall
	move $s7, $v0
	
	#Saltar hacia las instrucciones de la operacion correspondiente
	beq $s7, 1, input1
	beq $s7, 2, input1
	beq $s7, 3, input2
	
	
#INPUT OPS 1--------

	#Sumar o restar
input1:
	#PRIMER NUMERO
	li $v0,4
	la $a0, mensaje1
	syscall
	
	#Input de String
	li $v0, 8
	la $a0, empty1
	li $a1, 51  #Notar que debe ser +1 para que lea 50
	syscall
				
	#Abrir el espacio extra en caso de coma en pos. final o penultima
	addi $t0, $zero, 48
	lb $t6, empty1($t0)
	beq $t6, 0x0000002c, abrir
	
	addi $t0, $zero, 49
	lb $t6, empty1($t0)
	beq $t6, 0x0000002c, abrir
	retornoAbrir:
	
	#SEGUNDO NUMERO
	li $v0,4
	la $a0, mensaje2
	syscall
	
	#Input de String
	li $v0, 8
	la $a0, empty2
	li $a1, 51
	syscall
	
	#Abrir el espacio extra para el segundo numero
	addi $t0, $zero, 48
	lb $t6, empty2($t0)
	beq $t6, 0x0000002c, abrir2
	
	addi $t0, $zero, 49
	lb $t6, empty2($t0)
	beq $t6, 0x0000002c, abrir2
	retornoAbrir2:
	
	
#VALIDACIONES -----------	
	
	#EMPTY 1
	#Detectar si hay una coma y salto
	addi $t0, $zero, 0 #inicializar index
	
loopDecimal:
	beq $t0, 50, exitLoopDecimal
	lb $t6, empty1($t0)
	
	beq $t6, 0x0000000a, verifyEnter #Pasar $s1 a 1 si hay salto
	retornoEnter:
	addi $s2, $t0, 0 #Pos actual guardada en s2
	
	beq $t6, 0x0000000a, exitLoopDecimal
	
	beq $t6, 0x0000002c, verifyColon #Pasar $s0 a 1 si hay coma
	retornoColon:
	
	addi $t0, $t0, 1
	
	j loopDecimal
				
exitLoopDecimal:
	
	#Agregar 0.00
	bne $s0, 1, agregar0
	#Agregar 0 si hay 1 solo decimal
	beq $s0, 1, agregarSolo
	
	retorno0:
	
	#vaciar registros S
	move $s0, $zero
	move $s1, $zero
	move $s2, $zero
	move $s3, $zero
	
	
	#EMPTY2										
	#Detectar si hay una coma o salto
	addi $t0, $zero, 0 #inicializar index
	
loopDecimal2:
	beq $t0, 50, exitLoopDecimal2
	lb $t6, empty2($t0)
	
	beq $t6, 0x0000000a, verifyEnter2 #Pasar $s1 a 1 si hay salto
	retornoEnter2:
	addi $s2, $t0, 0 #Pos actual guardada en s2
	
	beq $t6, 0x0000000a, exitLoopDecimal2
	
	beq $t6, 0x0000002c, verifyColon2 #Pasar $s0 a 1 si hay coma
	retornoColon2:
	
	addi $t0, $t0, 1
	
	j loopDecimal2
exitLoopDecimal2:	
	
	#Agregar 0.00
	bne $s0, 1, agregar02
	#Agregar 0 si hay 1 solo decimal
	beq $s0, 1, agregarSolo2
	
	retorno02:
	
	#vaciar registros S
	move $s0, $zero
	move $s1, $zero
	move $s2, $zero
	move $s3, $zero
	
#ELIM. SALTOS ---------

	addi $s0, $zero, 0
elimSaltos1:
	beq $s0, 53, exitElim1
	
	lb $t1, empty1($s0)
	lb $t2, empty2($s0)
	beq $t1, 0x0000000a, macroAntiSalto1
	returnAnti1:
	beq $t2, 0x0000000a, macroAntiSalto2
	returnAnti2:
	
	addi $s0, $s0, 1
	j elimSaltos1		
exitElim1:							
	
	move $s0, $zero
	
#VOLTEAR --------

	#Voltear empty1
	addi $t0, $zero, 0 #volteado
	addi $t2, $zero, 52 #empty
voltear1:
	beq $t2, -1, exitVoltear1
	lb $t1, empty1($t2)
	beq $t1, $zero, skip1
	
	sb $t1, volteado1($t0)

	addi $t0, $t0, 1
	skip1:
	subi $t2, $t2, 1
	j voltear1
exitVoltear1:

	#Voltear empty2
	addi $t0, $zero, 0 #volteado
	addi $t2, $zero, 52 #empty
voltear2:
	beq $t2, -1, exitVoltear2
	lb $t1, empty2($t2)
	beq $t1, $zero, skip2
	
	sb $t1, volteado2($t0)

	addi $t0, $t0, 1
	skip2:
	subi $t2, $t2, 1
	j voltear2
exitVoltear2:		
					
	
#TRANSFORMAR --------
	#Empty 1
	addi $t0, $zero, 0
	addi $t2, $zero, 0
	
loopTransformar:
	beq $t0, 53, exitTransformar #Mismo tamaño del .space original volteado 53-53
	beq $t0, 2, plusplus
	
	lb $t1, volteado1($t0)
	beq $t1, 0x00000000, exitTransformar

	#Transformar
	subi $t1, $t1, 48 #-48
	
	sb $t1, hexa1($t2)
	
	addi $t2, $t2, 1
	plusplus:
	addi $t0, $t0, 1
	j loopTransformar
exitTransformar:

	
	#Empty 2
	addi $t0, $zero, 0
	addi $t2, $zero, 0
	
loopTransformar2:
	beq $t0, 53, exitTransformar2 #Mismo tamaño del .space original volteado 53-53
	beq $t0, 2, plusplus2
	
	lb $t1, volteado2($t0)
	beq $t1, 0x00000000, exitTransformar2

	#Transformar
	subi $t1, $t1, 48 #-48
	
	sb $t1, hexa2($t2)
	
	addi $t2, $t2, 1
	plusplus2:
	addi $t0, $t0, 1
	j loopTransformar2
exitTransformar2:
	
#SUMAR O RESTAR---------
	beq $s7, 1, Suma
	beq $s7, 2, Resta

#Sumar
Suma:
	addi $s2, $zero, 0
loopSumar:
	beq $s2, 52, exitSumar
	
	lb $t1, hexa1($s2)
	lb $t2, hexa2($s2)
	
	add $s0, $t1, $t2 #Suma - AQUI
	beq $s1, 1, sumarAcarreo #+1
	retornoAcSum2:
	
	addi $s1, $zero, 0 #Reset acarreo false
	
	bgt $s0, 0x00000009, acarreoSuma	#Acarreo true
	retornoAcSum:
	
	sb $s0, result($s2)
	
	bgt $s0, 0, limpiarCeros1 #Limpiar ceros a la izquierda
	retornoLimpiar1:
	
	addi $s2, $s2, 1
	j loopSumar
exitSumar:
	#Vaciar registros s
	move $s0, $zero
	move $s1, $zero
	move $s2, $zero
	
	j exitOps1
	
#Restar
Resta:

#Verificar si minuendo menor que sustraendo
addi $s0, $zero, 51
restaNega:
	lb $t1, hexa1($s0) #min
	lb $t2, hexa2($s0) #sus

	bne $t1, 0x00000000, valMin
	returnMin:
	bne $t2, 0x00000000, valSus
	returnSus:
	
	beq $s2, 1, inversion
	beq $s1, 1, exitRestaNega
	
	subi $s0, $s0, 1
	j restaNega
exitRestaNega:

#Resta
	addi $s0, $zero, 0
loopRestar:
	beq $s0, 52, exitSumar
	beq $s6, 0, normal
	beq $s6, 1, otro
	
	normal:
	lb $s2, hexa1($s0) #s2 minuendo
	lb $s5, hexa2($s0) #s5 sustraendo
	j salidaOtro
	
	otro:
	lb $s2, hexa2($s0) #s2 minuendo
	lb $s5, hexa1($s0) #t2 sustraendo
	salidaOtro:
	
	#Accarreo negativo
	beq $s4, 1, resetAcarreoResta
	retornoResetMenos:
	addi $s4, $zero, 0
	
	blt $s2, $s5, prestarResta #s4 para indicar accarreo
	retornoPrestar:
	
	sub $s1, $s2, $s5 #s1 almacena resultado
	sb $s1, result($s0)
	
	
	bgt $s1, 0, limpiarCeros2 #Limpiar ceros a la izquierda
	retornoLimpiar2:

	addi $s0, $s0, 1
	j loopRestar
exitRestar:
	#Vaciar registros s
	move $s0, $zero
	move $s1, $zero
	move $s2, $zero
	move $s4, $zero
	move $s5, $zero
											
exitOps1:

#OUTPUT --------

	#Mensaje de resultado
	li $v0, 4
	la $a0, mensajeFinal
	syscall
	
	beq $s6, 1, printMinus
	returnMinus:

	addi $t0, $zero, 52 #Colocar el numero de casillas que hay en el array -1 posicion 
	
loopInverso:
	beq $t0, -1, exitLoopInverso
	#blt $s3, $t0, skipSuma
	
	beq $t0, 1, printColon
	retornoInverso:
	lb $t6, result($t0)
	
	li $v0, 1
	move $a0, $t6
	syscall

	skipSuma:
	subi $t0, $t0, 1
	j loopInverso
		
exitLoopInverso:

	move $s3, $zero
	j finMain




#INPUT OPS 2 ----------

	#multiplicar
input2:

	#PRIMER NUMERO
	li $v0,4
	la $a0, mensaje4
	syscall
	
	#Input de String
	li $v0, 8
	la $a0, empty3
	li $a1, 26  #Notar que debe ser +1 para que lea 25
	syscall
				
	#Abrir el espacio extra en caso de coma en pos. final o penultima
	addi $t0, $zero, 23
	lb $t6, empty3($t0)
	beq $t6, 0x0000002c, abrir3
	
	addi $t0, $zero, 24
	lb $t6, empty3($t0)
	beq $t6, 0x0000002c, abrir3
	retornoAbrir3:
	
	#SEGUNDO NUMERO
	li $v0,4
	la $a0, mensaje5
	syscall
	
	#Input de String
	li $v0, 8
	la $a0, empty4
	li $a1, 26
	syscall
	
	#Abrir el espacio extra para el segundo numero
	addi $t0, $zero, 23
	lb $t6, empty4($t0)
	beq $t6, 0x0000002c, abrir4
	
	addi $t0, $zero, 24
	lb $t6, empty4($t0)
	beq $t6, 0x0000002c, abrir4
	retornoAbrir4:

#VALIDACIONES---------

#EMPTY 3
	#Detectar si hay una coma y salto
	addi $t0, $zero, 0 #inicializar index
	
loopDecimal3:
	beq $t0, 25, exitLoopDecimal3
	lb $t6, empty3($t0)
	
	beq $t6, 0x0000000a, verifyEnter3 #Pasar $s1 a 1 si hay salto
	retornoEnter3:
	addi $s2, $t0, 0 #Pos actual guardada en s2
	
	beq $t6, 0x0000000a, exitLoopDecimal3
	
	beq $t6, 0x0000002c, verifyColon3 #Pasar $s0 a 1 si hay coma
	retornoColon3:
	
	addi $t0, $t0, 1
	
	j loopDecimal3
				
exitLoopDecimal3:
	
	#Agregar 0.00
	bne $s0, 1, agregar03
	#Agregar 0 si hay 1 solo decimal
	beq $s0, 1, agregarSolo3
	
	retorno03:
	
	#vaciar registros S
	move $s0, $zero
	move $s1, $zero
	move $s2, $zero
	move $s3, $zero
	
	
#EMPTY4										
	#Detectar si hay una coma o salto
	addi $t0, $zero, 0 #inicializar index
	
loopDecimal4:
	beq $t0, 25, exitLoopDecimal4
	lb $t6, empty4($t0)
	
	beq $t6, 0x0000000a, verifyEnter4 #Pasar $s1 a 1 si hay salto
	retornoEnter4:
	addi $s2, $t0, 0 #Pos actual guardada en s2
	
	beq $t6, 0x0000000a, exitLoopDecimal4
	
	beq $t6, 0x0000002c, verifyColon4 #Pasar $s0 a 1 si hay coma
	retornoColon4:
	
	addi $t0, $t0, 1
	
	j loopDecimal4
exitLoopDecimal4:	
	
	#Agregar 0.00
	bne $s0, 1, agregar04
	#Agregar 0 si hay 1 solo decimal
	beq $s0, 1, agregarSolo4
	
	retorno04:
	
	#vaciar registros S
	move $s0, $zero
	move $s1, $zero
	move $s2, $zero
	move $s3, $zero

	addi $t0, $zero, 0

#ELIMINAR SALTOS ------------

	addi $s0, $zero, 0
elimSaltos2:
	beq $s0, 28, exitElim2
	
	lb $t1, empty3($s0)
	lb $t2, empty4($s0)
	beq $t1, 0x0000000a, macroAntiSalto3
	returnAnti3:
	beq $t2, 0x0000000a, macroAntiSalto4
	returnAnti4:
	
	addi $s0, $s0, 1
	j elimSaltos2		
exitElim2:							
	
	move $s0, $zero

#VOLTEAR --------

	#Voltear empty3
	addi $t0, $zero, 0 #volteado
	addi $t2, $zero, 27 #empty
voltear3:
	beq $t2, -1, exitVoltear3
	lb $t1, empty3($t2)
	beq $t1, $zero, skip3
	
	sb $t1, volteado3($t0)

	addi $t0, $t0, 1
	skip3:
	subi $t2, $t2, 1
	j voltear3
exitVoltear3:

	#Voltear empty4
	addi $t0, $zero, 0 #volteado
	addi $t2, $zero, 27 #empty
voltear4:
	beq $t2, -1, exitVoltear4
	lb $t1, empty4($t2)
	beq $t1, $zero, skip4
	
	sb $t1, volteado4($t0)

	addi $t0, $t0, 1
	skip4:
	subi $t2, $t2, 1
	j voltear4
exitVoltear4:

#TRANSFORMAR--------		
	#Empty 3
	addi $t0, $zero, 0
	addi $t2, $zero, 0
	
loopTransformar3:
	beq $t0, 28, exitTransformar3 #Mismo tamaño del .space original volteado 28
	beq $t0, 2, plusplus3
	
	lb $t1, volteado3($t0)
	beq $t1, 0x00000000, exitTransformar3

	#Transformar
	subi $t1, $t1, 48 #-48
	
	sb $t1, hexa3($t2)
	
	addi $t2, $t2, 1
	plusplus3:
	addi $t0, $t0, 1
	j loopTransformar3
exitTransformar3:

	
	#Empty 4
	addi $t0, $zero, 0
	addi $t2, $zero, 0
	
loopTransformar4:
	beq $t0, 28, exitTransformar4 #Mismo tamaño del .space original volteado 28
	beq $t0, 2, plusplus4
	
	lb $t1, volteado4($t0)
	beq $t1, 0x00000000, exitTransformar4

	#Transformar
	subi $t1, $t1, 48 #-48
	
	sb $t1, hexa4($t2)
	
	addi $t2, $t2, 1
	plusplus4:
	addi $t0, $t0, 1
	j loopTransformar4
exitTransformar4:

#MULTIPLICAR------
	
	addi $t0, $zero, 0
	addi $t1, $zero, 0
	addi $s2, $zero, 0
	addi $t4, $zero, 0
loopM1:
	#abajo
	beq $t0, 27, finM1
	lb $t2, hexa4($t0)
			
	loopM2:
		#arriba
		beq $t1, 27, finM2
		lb $t3, hexa3($t1)
		
		mul $s0, $t2, $t3 #Multiplicar arriba por abajo
		add $s0, $s0, $s1 #Sumar acarreo
		move $s1, $zero   #Reset acarreador
		
		bgt $s0, 9, divAcarreo #acarreo si mayor de nueve
		returnDivAcarreo: 
		
		sb $s0, aux($s2) #colocar en aux
		
		addi $s2, $s2, 1
		addi $t1, $t1, 1
		j loopM2
	finM2:
	#Reiniciar t1
	addi $t1, $zero, 0
	
	#Ajuste coordenada 0s
	addi $t4, $t4, 1
	move $s2, $t4
	
	#sumar a result2
	addi $s3, $zero, 0
loopSumarX:
	beq $s3, 62, exitSumarX #Control del tamaño
	
	lb $t6, aux($s3)
	lb $t7, result2($s3)
	
	add $s4, $t6, $t7 #Suma
	beq $s5, 1, sumarAcarreoX #+1
	retornoAcSumX2:
	
	addi $s5, $zero, 0 #Reset acarreo false
	
	bgt $s4, 0x00000009, acarreoSumaX	#Acarreo true
	retornoAcSumX:
	
	sb $s4, result2($s3)
	
	bgt $s4, 0, limpiarCerosX #Limpiar ceros a la izquierda
	retornoLimpiarX:
	
	addi $s3, $s3, 1
	j loopSumarX
exitSumarX:
	
	#vaciar aux
	addi $t5, $zero, 0 
	vaciar:
		beq $t5, 62, exitVaciar
		sb $zero, aux($t5)
		addi $t5, $t5, 1
		j vaciar
	exitVaciar:
	
	addi $t0, $t0, 1
	j loopM1
finM1:	

	move $s0, $zero
	move $s1, $zero
	move $s2, $zero
	move $s3, $zero
	move $s4, $zero
	move $s5, $zero		

#OUTPUT-------

	#Mensaje de resultado
	li $v0, 4
	la $a0, mensajeFinal
	syscall

	addi $t0, $zero, 61 #Colocar el numero de casillas que hay en el array -1 posicion 
	
loopInverso2:
	beq $t0, 1, exitLoopInverso2
	#blt $s6, $t0, skipSuma2
	
	beq $t0, 3, printColon2
	retornoInverso2:
	lb $t6, result2($t0)
	
	li $v0, 1
	move $a0, $t6
	syscall

	skipSuma2:
	subi $t0, $t0, 1
	j loopInverso2
		
exitLoopInverso2:

	move $s6, $zero							

finMain:

#Fin de programa		
li $v0, 10
syscall 


#MACROS ---------

verifyColon:
	#Confirmar que hay una coma
	addi $s0, $zero, 1
	addi $s3, $s2, 0 #retener la posicion de la coma en s3
	j retornoColon	
	
verifyColon2:
	addi $s0, $zero, 1
	addi $s3, $s2, 0
	j retornoColon2
	
verifyColon3:
	#Confirmar que hay una coma
	addi $s0, $zero, 1
	addi $s3, $s2, 0 #retener la posicion de la coma en s3
	j retornoColon3	
	
verifyColon4:
	addi $s0, $zero, 1
	addi $s3, $s2, 0
	j retornoColon4				

verifyEnter:	
	#Confirmar que hay salto
	addi $s1, $zero, 1
	j retornoEnter	

verifyEnter2:
	addi $s1, $zero, 1
	j retornoEnter2	
	
verifyEnter3:	
	#Confirmar que hay salto
	addi $s1, $zero, 1
	j retornoEnter3	

verifyEnter4:
	addi $s1, $zero, 1
	j retornoEnter4															

agregar0:
	beq $s1, 1, agregar0antes

	#Añadir 00 al final del numero
	addi $t1, $zero, 0x0000002c
	addi $t2, $zero, 50
	sb $t1, empty1($t2)
	
	addi $t1, $zero, 0x00000030
	addi $t2, $zero, 51
	sb $t1, empty1($t2)
	
	addi $t2, $zero, 52
	sb $t1, empty1($t2)
	
	j retorno0
	
agregar0antes:
	#Añadir 00 al final si numero no es de 50 digitos
	addi $t1, $zero, 0x0000002c
	sb $t1, empty1($s2)
	
	addi $t1, $zero, 0x00000030
	addi $s2, $s2, 1
	sb $t1, empty1($s2)
	
	addi $s2, $s2, 1
	sb $t1, empty1($s2)
	
	j retorno0
	
agregar02:
	beq $s1, 1, agregar0antes2

	#Añadir 00 al final del numero
	addi $t1, $zero, 0x0000002c
	addi $t2, $zero, 50
	sb $t1, empty2($t2)
	
	addi $t1, $zero, 0x00000030
	addi $t2, $zero, 51
	sb $t1, empty2($t2)
	
	addi $t2, $zero, 52
	sb $t1, empty2($t2)
	
	j retorno02
	
agregar0antes2:	
	#Añadir 00 al final si numero no es de 50 digitos
	addi $t1, $zero, 0x0000002c
	sb $t1, empty2($s2)
	
	addi $t1, $zero, 0x00000030
	addi $s2, $s2, 1
	sb $t1, empty2($s2)
	
	addi $s2, $s2, 1
	sb $t1, empty2($s2)
	
	j retorno02
	
agregar03:
	beq $s1, 1, agregar0antes3

	#Añadir 00 al final del numero
	addi $t1, $zero, 0x0000002c
	addi $t2, $zero, 25
	sb $t1, empty3($t2)
	
	addi $t1, $zero, 0x00000030
	addi $t2, $zero, 26
	sb $t1, empty3($t2)
	
	addi $t2, $zero, 27
	sb $t1, empty3($t2)
	
	j retorno03
	
agregar0antes3:
	#Añadir 00 al final si numero no es de 50 digitos
	addi $t1, $zero, 0x0000002c
	sb $t1, empty3($s2)
	
	addi $t1, $zero, 0x00000030
	addi $s2, $s2, 1
	sb $t1, empty3($s2)
	
	addi $s2, $s2, 1
	sb $t1, empty3($s2)
	
	j retorno03
	
agregar04:
	beq $s1, 1, agregar0antes4

	#Añadir 00 al final del numero
	addi $t1, $zero, 0x0000002c
	addi $t2, $zero, 25
	sb $t1, empty4($t2)
	
	addi $t1, $zero, 0x00000030
	addi $t2, $zero, 26
	sb $t1, empty4($t2)
	
	addi $t2, $zero, 27
	sb $t1, empty4($t2)
	
	j retorno04
	
agregar0antes4:
	#Añadir 00 al final si numero no es de 50 digitos
	addi $t1, $zero, 0x0000002c
	sb $t1, empty4($s2)
	
	addi $t1, $zero, 0x00000030
	addi $s2, $s2, 1
	sb $t1, empty4($s2)
	
	addi $s2, $s2, 1
	sb $t1, empty4($s2)
	
	j retorno04													

agregarSolo:
	#Agregar un 0 si hay un solo decimal
	addi $s3, $s3, 2
	lb $t5, empty1($s3)
	beq $t5, 0x0000000a, soloComplemento
	beq $t5, $zero, soloComplemento 
	retornoComplemento:
	
	#Eliminar decimales en exceso
	addi $s3, $s3, 1
	lb $t5, empty1($s3)
	bne $t5, $zero, eliminarExceso
	excesoRetorno:
	
	j retorno0
	
soloComplemento:
	addi $t5, $zero, 0x00000030
	sb $t5, empty1($s3)
	
	j retornoComplemento
	
eliminarExceso:
	#Eliminar decimales en exceso
	loopExceso:
		sb $zero, empty1($s3)
		addi $s3, $s3, 1
		lb $t4, empty1($s3)
		beq $t4, $zero, exitExceso
		j loopExceso
	
	exitExceso:
	j excesoRetorno	

agregarSolo2:
	#Agregar un 0 si hay un solo decimal
	addi $s3, $s3, 2
	lb $t5, empty2($s3)
	beq $t5, 0x0000000a, soloComplemento2
	beq $t5, $zero, soloComplemento2 
	retornoComplemento2:
	
	#Eliminar decimales en exceso
	addi $s3, $s3, 1
	lb $t5, empty2($s3)
	bne $t5, $zero, eliminarExceso2
	excesoRetorno2:
	
	j retorno02
	
soloComplemento2:
	addi $t5, $zero, 0x00000030
	sb $t5, empty2($s3)
	
	j retornoComplemento2
	
eliminarExceso2:
	#Eliminar decimales en exceso
	loopExceso2:
		sb $zero, empty2($s3)
		addi $s3, $s3, 1
		lb $t4, empty2($s3)
		beq $t4, $zero, exitExceso2
		j loopExceso2
	
	exitExceso2:
	j excesoRetorno2
	
agregarSolo3:
	#Agregar un 0 si hay un solo decimal
	addi $s3, $s3, 2
	lb $t5, empty3($s3)
	beq $t5, 0x0000000a, soloComplemento3
	beq $t5, $zero, soloComplemento3 
	retornoComplemento3:
	
	#Eliminar decimales en exceso
	addi $s3, $s3, 1
	lb $t5, empty3($s3)
	bne $t5, $zero, eliminarExceso3
	excesoRetorno3:
	
	j retorno03
	
soloComplemento3:
	addi $t5, $zero, 0x00000030
	sb $t5, empty3($s3)
	
	j retornoComplemento3
	
eliminarExceso3:
	#Eliminar decimales en exceso
	loopExceso3:
		sb $zero, empty3($s3)
		addi $s3, $s3, 1
		lb $t4, empty3($s3)
		beq $t4, $zero, exitExceso3
		j loopExceso3
	
	exitExceso3:
	j excesoRetorno3	

agregarSolo4:
	#Agregar un 0 si hay un solo decimal
	addi $s3, $s3, 2
	lb $t5, empty4($s3)
	beq $t5, 0x0000000a, soloComplemento4
	beq $t5, $zero, soloComplemento4 
	retornoComplemento4:
	
	#Eliminar decimales en exceso
	addi $s3, $s3, 1
	lb $t5, empty4($s3)
	bne $t5, $zero, eliminarExceso4
	excesoRetorno4:
	
	j retorno04
	
soloComplemento4:
	addi $t5, $zero, 0x00000030
	sb $t5, empty4($s3)
	
	j retornoComplemento4
	
eliminarExceso4:
	#Eliminar decimales en exceso
	loopExceso4:
		sb $zero, empty4($s3)
		addi $s3, $s3, 1
		lb $t4, empty4($s3)
		beq $t4, $zero, exitExceso4
		j loopExceso4
	
	exitExceso4:
	j excesoRetorno4						
	
abrir:
	#pedir otro numero mas para empty1
	li $v0, 8
	addi $t0, $zero, 50
	la $a0, empty1($t0)
	li $a1, 2
	syscall
	
	j retornoAbrir
	
abrir2:	
	#Pedir otro numero mas para empty2
	li $v0, 8
	addi $t0, $zero, 50
	la $a0, empty2($t0)
	li $a1, 2
	syscall
	
	j retornoAbrir2
	
abrir3:
	#pedir otro numero mas para empty3
	li $v0, 8
	addi $t0, $zero, 25
	la $a0, empty3($t0)
	li $a1, 2
	syscall
	
	j retornoAbrir3
	
abrir4:	
	#Pedir otro numero mas para empty4
	li $v0, 8
	addi $t0, $zero, 25
	la $a0, empty4($t0)
	li $a1, 2
	syscall
	
	j retornoAbrir4																		
	
macroAntiSalto1:
	#Quitar salto en 50-1
	sb $zero, empty1($s0)
	j returnAnti1
	
macroAntiSalto2:
	#Quitar salto en 50-2
	sb $zero, empty2($s0)	
	j returnAnti2
	
macroAntiSalto3:
	#Quitar salto en 25-1
	sb $zero, empty3($s0)
	j returnAnti3
	
macroAntiSalto4:
	#Quitar salto en 25-2
	sb $zero, empty4($s0)	
	j returnAnti4	
	
printColon:
	#Imprimir coma en resultado
	li $v0, 11
	addi $a0, $zero, 0x0000002c		
	syscall
	j retornoInverso

printColon2:
	#Imprimir coma en resultado
	li $v0, 11
	addi $a0, $zero, 0x0000002c		
	syscall
	j retornoInverso2		
	
acarreoSuma:
	#Acarrear en la suma
	subi $s0, $s0, 10
	addi $s1, $zero, 1
	j retornoAcSum
	
sumarAcarreo:
	#Ejecutar el +1 al siguiente numero
	addi $s0, $s0, 1
	j retornoAcSum2	
	
limpiarCeros1:
	#Limpiar ceros en el resultado de la suma
	move $s3, $s2
	j retornoLimpiar1					

prestarResta:
	addi $s2, $s2, 10
	addi $s4, $zero, 1 #Indicar que hay acarreo negativo
	j retornoPrestar
	
resetAcarreoResta:
	subi $s2, $s2, 1
	j retornoResetMenos
	
limpiarCeros2:
	#Limpiar ceros en el resultado de la resta
	move $s3, $s0
	j retornoLimpiar2
	
divAcarreo:
	addi $t7, $zero, 10
	div $s0, $t7
	mfhi $s0 #residuo
	mflo $s1 #cociente
	j returnDivAcarreo

acarreoSumaX:
	#Acarrear en la suma
	subi $s4, $s4, 10
	addi $s5, $zero, 1
	j retornoAcSumX
	
sumarAcarreoX:
	#Ejecutar el +1 al siguiente numero
	addi $s4, $s4, 1
	j retornoAcSumX2	
	
limpiarCerosX:
	#Limpiar ceros en el resultado de la suma
	move $s6, $s3
	j retornoLimpiarX								

valMin:
	addi $s1, $zero, 1
	j returnMin

valSus:
	addi $s2, $zero, 1
	j returnSus
	
#sin bool	
inversion:
	bne $s1, 1, invertir
	
	loopIn:
		lb $t1, hexa1($s0)
		lb $t2, hexa2($s0)
		beq $t1, $t2, skipIn
		bgt $t1, $t2, exitIn
		bgt $t2, $t1, invertir
		
		skipIn:
		subi $s0, $s0, 1
		j loopIn
	exitIn:
	
	j exitRestaNega	
	
#con bool	
invertir:
	addi $s6, $zero, 1 #bool de invertir
	j exitRestaNega	
	
printMinus:
	li $v0, 4
	la $a0, negativo
	syscall
	j returnMinus	
