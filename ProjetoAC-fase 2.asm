.data
	.align 4
	Board: .word 0
	.align 4
	playerKey: .word 0
	.align 4
	gameKey: .word 0
	.align 4
	flagWhites: .word 0
	.align 4
	UniversalKey: .word 0
	StartGame: .asciiz "Vais agora começar um jogo de MasterMind"
	PrintWhites: .asciiz "O numero de pinos brancos é => "
	PrintReds: .asciiz "O numero de pinos vermelhos é => "
	PrintPlayerKey: .asciiz "A sua chave de jogo é => "
	PrintErrorKey: .asciiz "Inseriu um elemento que não pertence ao universo do jogo "
	PrintInsertKey: .asciiz "Insira um elemento para a sua chave de jogo que pertença ao universo que inseriu => "
	PrintTamanho: .asciiz "O tamanho da chave do jogo é => "
	PrintNewline: .asciiz "\n"
	PedirAlfabeto: .asciiz "Insira um numero para a alfabeto do jogo => "
	PedirColunas: .asciiz "Insira o numero de colunas => "
	PedirLinhas: .asciiz "Insira o numero de linhas => "
	PrintFoundDuplicate: .asciiz "O numero inserido já existe no alfabeto do jogo "
	EndGameWinMessage: .asciiz "Ganhaste o jogo ao adivinhar a chave correta. Parabéns ! "
	EndGamePartialWin: .asciiz "Descobriste apenas parte da chave correta"
	EndGameLossMessage: .asciiz "Nao conseguiste descobrir nenhum elemento da chave"
	PointsNegativeMSG: .asciiz "Irás perder 3 pontos nao descobrir nenhum elemento. Se a tua pontuação total for 0 manter-se-á a 0"
	PontosJogada: .asciiz "Nesta jogada adquiriste estes pontos => "
	PontosTotais: .asciiz "Tens de momento um total destes pontos => "
	NewGame: .asciiz "Queres jogar outra partida? Clica enter para continuar ou e para sair"
	GameWin: .asciiz "Ganhaste o jogo ao adivinhar a chave correta. Parabéns ! "
	GameOver: .asciiz "Acabaste uma ronda. Clica 'e' para saires ou outra tecla para começar outra\n"
.text

main:
			jal dynMemory
			move $s0,$v0 # Guardar em $s0 o numero de colunas
			move $s1,$v1 # Guardar em $s1 o numero de linhas
			li $s3,0 # Ronda Atual
			li $s4,0 # Pontuação da ronda
			li $s5,0 # Pontuação Total	
			move $a0,$s0 # Passar em $a0 o numero de colunas como argumento para a key
			jal UniverseKey
		

startGame:			
			move $a0,$s0 # Passar em $a0 o numero de colunas como argumento para a key
			jal randomizeKey
			
GameLoop:
			beq $s3,$s1,endGameLoss
				
			move $a0,$s0 # Passar em $a0 o numero de colunas como argumento para a key
			jal printGameKey
			
			move $a0,$s0 # Passar em $a0 o numero de colunas como argumento para a key
			jal insertKey
			
			move $a0,$s0 # Passar em $a0 o numero de colunas como argumento para a key
			move $a1,$s3  # Passar em $a1 a linha atual
			jal insertKeyinBoard
			
			move $a0,$s0
			move $a1,$s1
			jal printBoard
			
			move $a0,$s0 # Passar em $a0 o numero de colunas como argumento para a key
			jal checkRedWhite #Retorna em $v0 o numero de Whites e em $v1 o numero de Reds
			
			beq $v1,$s0,endGameWin
			
			addi $s3,$s3,1
			j GameLoop
			
endGameWin:			
			li $v0,4
			la $a0,EndGameWinMessage
			syscall
			mul $t0,$s0,3
			j Points
			

endGameLoss:			
			beq $v1,0,PointsNegative
			
			li $v0,4
			la $a0,EndGamePartialWin
			syscall
			
			mul $t0,$v1,3
			
			j Points
			

Points:			
			move $s4,$t0
			
			add $s5,$s5,$s4
			
			li $v0,4
			la $a0,PontosJogada
			syscall
			
			li $v0,1
			move $a0,$s4
			syscall
			
			li $v0,4
			la $a0,PrintNewline
			syscall
			
			li $v0,4
			la $a0,PontosTotais
			syscall
			
			li $v0,1
			move $a0,$s5
			syscall
			
			li $v0,4
			la $a0,PrintNewline
			syscall
			
			li $v0,4
			la $a0,GameOver
			syscall
			
			li $v0,12  	
			syscall    # le um carater 
			beq $v0,'e',end   #if v0 = 'e' goto stop game 
  			j startGame 
			
		
			
PointsNegative:		
			li $v0,4
			la $a0,EndGameLossMessage
			syscall
			
			li $v0,4
			la $a0,PointsNegativeMSG
			syscall
			
			li $v0,4
			la $a0,PrintNewline
			syscall
			
			blt $s5,3,end
			addi $s5,$s5,-3
			
			li $v0,4
			la $a0,GameOver
			syscall
			
			li $v0,4
			la $a0,PrintNewline
			syscall
			
			li $v0,12  	
			syscall    # le um carater 
			beq $v0,'e',end    #if v0 = 'e' goto stop game 
   			j startGame
end:
			li $v0,10
			syscall
					

#---------------------------------------------------------------------------------------------------------------------------------#			
	
insertKeyinBoard:
			addi $sp,$sp,-8 # Descer a stack em 4 para guardar uma variável
			sw $s1,4($sp)
			sw $s0,0($sp) # Guardar $s0 na stack
			move $s0,$a0 # $s0 guarda o numero de colunas passado em $a0
			move $s1,$a1 # Linha atual 
			
			mul $t5,$s0,$s1
			mul $t5,$t5,4
			lw $t2,Board
			add $t2,$t2,$t5
			
			lw $t3,playerKey
			li $t1,0
			
loopCopyIntoBoard:
			beq $t1,$s0,endLoopCopyIntoBoard
			lw $t4,($t3)
			sw $t4,($t2)
			addi $t3,$t3,4
			addi $t2,$t2,4
			addi $t1,$t1,1
			j loopCopyIntoBoard
			
endLoopCopyIntoBoard:
			lw $s1,4($sp)
			lw $s0,0($sp)
			addi $sp,$sp,8
			jr $ra
						
																		
#---------------------------------------------------------------------------------------------------------------------------------#												
														
checkRedWhite:
			addi $sp,$sp,-4 # Descer a stack em 4 para guardar uma variável
			sw $s0,0($sp) # Guardar $s0 na stack
			move $s0,$a0 # $s0 guarda o numero de colunas passado em $a0
	
			li $t0,0 # Whites = 0
			li $t1,0 # Reds = 0
			lw $t2,gameKey # $t2 = &gameKey s
			lw $t3,playerKey # $t3 = &playerKey slot
			lw $t4,playerKey # $t4 = &playerKey s 
			lw $t5,flagWhites # $t5 = &flagWhites
			li $t6,0 # $t6 = 0
			li $t7,0 # $t7 = 0
							
loopRed:			
			ble $s0,$t6,endcheckRedWhite # t6 = slot
			lw $t8,($t2) # t8 = gamekey[slot]
			lw $t9,($t3) # t9 = answer[slot]
			beq $t8,$t9,increaseRed # if ( $t8 == $t9) goto increaseRed
			lw $t4,playerKey # $t4 = &playerKey[s] 
			lw $t5,flagWhites # $t5 = &flagwhites[s]
			li $t7,0 # $t7 = 0
			
loopWhite:			
			beq $s0,$t7,beforeloopRed # s  == colunas
			
			beq $t6,$t7,errorloopWhite # if ( $t6 == $t7) goto loopWhite 
			lw $t8,($t5) 
			bne $t8,$0,errorloopWhite # if ( $s0 != $t2) goto loopWhite
			lw $t8,($t2) # $t8 = gameKey[slot] 
			lw $t9,($t4) # $t9 = playerkey[s]
			bne $t9,$t8,errorloopWhite
			
			sw $1,($t5)
			addi $t0,$t0,1 #white ++
			j beforeloopRed		
			
beforeloopRed:
			addi $t6,$t6,1 # slot ++
			addi $t2,$t2,4 # gamekey[slot]++
			addi $t3,$t3,4 # answer[slot]++
			j loopRed			
				
errorloopWhite: 		
			addi $t7,$t7,1
			addi $t5,$t5,4
			addi $t4,$t4,4
			j loopWhite
				

increaseRed:
			addi $t1,$t1,1 #red ++
			lw $t4,playerKey # $t4 = &playerKey[s] 
			lw $t5,flagWhites # $t5 = &flagwhites[s]
			li $t7,0 # $t7 = 0
			j loopWhite																							
																		
endcheckRedWhite:
			
			li $v0,4
			la $a0,PrintWhites
			syscall
			
			li $v0,1
			move $a0,$t0
			syscall
			
			li $v0,4
			la $a0,PrintNewline
			syscall # Print \n
			
			li $v0,4
			la $a0,PrintReds
			syscall
			
			li $v0,1
			move $a0,$t1
			syscall
			
			li $v0,4
			la $a0,PrintNewline
			syscall # Print \n
			
			move $v0,$t0 # $v0 dá return aos Whites
			move $v1,$t1 # $v1 da return aos Reds
			
			lw $s0,0($sp) #Restaurar o valor de $s0 guardado na stack
			addi $sp,$sp,4 # Restaurar a stack ao valor inicial
			jr $ra # Retornar ao main																				
																								
#---------------------------------------------------------------------------------------------------------------------------------#

insertKey:							
			addi $sp,$sp,-4 # Descer a stack em 4 para guardar uma variável
			sw $s0,0($sp) # Guardar $s0 na stack
			move $s0,$a0 # $s0 guarda o numero de colunas passado em $a0
			lw $t0,playerKey # $t0 = &playerKey
			lw $t1,UniversalKey # $t1 = & UniverseKey
			li $t2,0
loopinsertKey:		
			beq $s0,$t2,endloopinsertKey # if ( $s0 == $t2) goto endloopinsertKey
			li $v0,4 
			la $a0,PrintInsertKey
			syscall
			li $v0,5
			syscall # Pedir input inteiro	
			move $t5,$v0 # $t5 = $v0
			li $t3,0 # $t3 = 0
			lw $t1,UniversalKey # $t1 = &Universal
						
checkgameKey:		
			beq $s0,$t3,errorgameKey # if ( $s0 == $t3) goto errorgameKey
			lw $t4,($t1) # $t4 = gameKey[$t1]
			beq $t5,$t4,insertKeyArray # if ( $t5 == $t4) goto insertKeyArray
			addi $t3,$t3,1 # $t3 = $t3 + 1
			addi $t1,$t1,4 # $t1 = $t1 + 4
			j checkgameKey # goto checkgameKey
																																																																																																																																																																																																																																		
insertKeyArray:
			sw $t5,($t0)
			addi $t2,$t2,1 # $t2 = $t2 + 1
			addi $t0,$t0,4 # $t0 = $t0 + 4
			j loopinsertKey																																																																																																																																																																																																																																																																																																																															
errorgameKey:
			li $v0,4
			la $a0,PrintErrorKey
			syscall
			
			li $v0,4
			la $a0,PrintNewline
			syscall # Print \n
					
			
			j loopinsertKey # goto loopinsertKey
			
																																																			
endloopinsertKey: 	
			li $t2,0 # $t2 = 0
			lw $t0,playerKey # $t0 = &playerKey
			li $v0,4 
			la $a0,PrintPlayerKey
			syscall 
					
			

loopPrintGameKey:
			beq $s0,$t2,endinsertKey # if ( $s0 == $t2) goto endinsertKey
			li $v0,1
			lw $a0,($t0) # $a0 = playerKey[$t0]
			syscall
			addi $t2,$t2,1 # $t2 = $t2 + 1
			addi $t0,$t0,4 # $t0 = $t0 + 4
			j loopPrintGameKey # goto loopinsertKey

endinsertKey:		
			li $v0,4
			la $a0,PrintNewline
			syscall # Print \n
					
			
			lw $s0,0($sp) #Restaurar o valor de $s0 guardado na stack
			addi $sp,$sp,4 # Restaurar a stack ao valor inicial
			jr $ra # Retornar ao main
		
																															
																																																	
#---------------------------------------------------------------------------------------------------------------------------------#					
							
randomizeKey:
			addi $sp,$sp,-4 # Descer a stack em 4 para guardar uma variável
			sw $s0,0($sp) # Guardar $s0 na stack
			move $s0,$a0 # $s0 guarda o numero de colunas passado em $a0
		
			lw $t0,gameKey # $t0 = &gameKey
			lw $t1,UniversalKey # $t1 = &UniversalKey
			li $t2,0 # $t2 = 0
			li $t4,0 # $t4 = 0	
		

RandomizeLoop:
			beq $s0,$t2,endRandomize # if ( $s0 == $t2) goto endRandomize
			lw $t1,UniversalKey # $t1 = &UniversalKey
			li $v0,42
			move $a1,$s0 # $a1 = $s0
			syscall # Random numero entre 0 e $a1, escrito em $a0
			mul $a0,$a0,4 # $a0 = $a0 * 4
			add $t1,$t1,$a0 # $t1 = $t1 + $a0
			lw $t3,($t1) # $t3 = UniversalKey[$t1]
			sw $t3,($t0) # $gameKey[$t0] = $t3
			addi $t2,$t2,1 # $t2 = $t2 + 1
			addi $t0,$t0,4 # $t0 = $t0 + 4
			j RandomizeLoop # goto RandomizeLoop
			
endRandomize:
			
			li $v0,4
			la $a0,PrintNewline
			syscall # Print \n
			
			
			lw $s0,0($sp) #Restaurar o valor de $s0 guardado na stack
			addi $sp,$sp,4 # Restaurar a stack ao valor inicial
			jr $ra # Retornar ao main
		
#---------------------------------------------------------------------------------------------------------------------------------#			
				
UniverseKey:
			addi $sp,$sp,-4 # Descer a stack em 4 para guardar uma variável
			sw $s0,0($sp) # Guardar $s0 na stack
			move $s0,$a0 #Guardar o numero de colunas em $s0
			
			li $v0,4 #Print á string do tamanho da key
			la $a0,PrintTamanho
			syscall 
			
			li $v0,1 #Print ao tamanho da key
			move $a0,$s0
			syscall
			
			li $v0,4
			la $a0,PrintNewline
			syscall # Print \n

			lw $t0,UniversalKey # $t0 = &UniversalKey	
	
loopKey:
			beq $s0,$t1,exitUniverseKey  # if ( $s0 == $t1) goto exitUniverseKey
			li $v0,4
			la $a0,PedirAlfabeto
			syscall # Print String
			
			li $v0,5
			syscall  # Ler um inteiro
			
			move $t5,$v0  # $t5 = $v0
			lw $t6,UniversalKey # $t6 = &UniversalKey
			li $t2,0 # $t2 = 0
		
checkDuplicates:	
			beq $s0,$t2,insertNumber # if ( $s0 == $t2) goto insertNumber
			lw $t3,($t6) # $t3 = UniversalKey[$t6]
			beq $t3,$t5,FoundDuplicate # Caso seja igual jump para FoundDuplicate, avisar e pedir novo input
			addi $t2,$t2,1 # $t2 = $t2 + 1
			addi $t6,$t6,4 # $t6 = $t6 + 4
			j checkDuplicates # goto checkDuplicates
	
FoundDuplicate:
			li $v0,4
			la $a0,PrintFoundDuplicate
			syscall # Print ao erro
			
			li $v0,4
			la $a0,PrintNewline
			syscall # Print \n
			
			j loopKey #goto loopKey
	
insertNumber:	
			sw $t5,($t0)  # UniversalKey[$t0] = $t5
			addi $t0,$t0,4 # $t0 = $t0 + 4
			addi $t1,$t1,1 # $t1 = $t1 + 1
			j loopKey
		
exitUniverseKey:
			lw $s0,0($sp) #Restaurar o valor de $s0 guardado na stack
			addi $sp,$sp,4 # Restaurar a stack ao valor inicial
			jr $ra # Retornar ao main
	
#---------------------------------------------------------------------------------------------------------------------------------#	

dynMemory:
			addi $sp,$sp,-8 # Descer a stack em 8 para guardar duas variáveis
			sw $s1,4($sp) # Guardar $s1 na stack
			sw $s0,0($sp) # Guardar $s0 na stack	
			
			li $v0,4 # Print string PedirColunas
			la $a0,PedirColunas 
			syscall	
			li $v0,5  #Pedir o numero de colunas
			syscall	
			move $s0,$v0 # Guardar em $s0 o numero de colunas
			
			li $v0,4 # Print string PedirLinhas
			la $a0,PedirLinhas
			syscall
			li $v0,5 # Pedir o numero de Linhas
			syscall
			move $s1,$v0 # Guardar em $s1 o número de linhas
			
			li $v0,9
			mul $a0,$s0,$s1 # Guardar $a0 o número de colunasxlinhas
			mul $a0,$a0,4 # 4 bytes por int
			syscall
			sw $v0,Board # Board guarda endereço de memoria alocado em $v0
			
			li $v0,9
			move $a0,$s0 # Alocar em $a0 o número de colunas para o tamanho da gameKey
			mul $a0,$a0,4 # 4 bytes por int
			syscall
			sw $v0,gameKey # gameKey guarda endereço de memoria  alocado em $v0
			
			li $v0,9
			move $a0,$s0 # Alocar em $a0 o numero de Colunas para o tamanho da playerKey
			mul $a0,$a0,4 # 4 bytes por int
			syscall
			sw $v0,playerKey # playerKey guarda endereço de memoria alocado em $v0
							
			li $v0,9
			move $a0,$s0 # Alocar em $a0 o numero de Colunas para o tamanho da UniversalKey
			mul $a0,$a0,4 # 4 bytes por int
			syscall
			sw $v0,UniversalKey # UniversalKey guarda endereço de memoria  alocado em $v0
			
			
			li $v0,9
			move $a0,$s0 # Alocar em $a0 o numero de Colunas para o tamanho da flag
			mul $a0,$a0,4 # 4 bytes por int
			syscall
			sw $v0,flagWhites # flagWhites guarda endereço de memoria  alocado em $v0

			move $v0,$s0 # Dar return ao numero de colunas em $v0
			move $v1,$s1 # Dar return ao numero de linhas em $v1
			lw $s1,4($sp) # Restaurar o valor de $s1 guardado na stack
			lw $s0,0($sp) # Restaurar o valor de $s0 guardado na stack
			addi $sp,$sp,8 # Restaurar a stack ao valor inicial
			jr $ra # Retornar ao main

#---------------------------------------------------------------------------------------------------------------------------------#
							
clearBoardArray:
			addi $sp,$sp,-8 # Descer a stack em 8 para guardar duas variáveis
			sw $s1,4($sp) # Guardar $s1 na stack
			sw $s0,0($sp) # Guardar $s0 na stack	
			
			move $s0,$a0 # Colunas
			move $s1,$a1 # Linhas
			lw $t0,Board
			
			mul $t1,$s0,$s1
			mul $t1,$t1,4
			li $t2,0
			
	
	loopClear:
			beq $t1,$t2,endClear     
			sw $0,($t0)       
			addi $t0,$t0,4
			addi $t2,$t2,4
			j loopClear
	
	endClear:	
					
			lw $s1,4($sp) # Restaurar o valor de $s1 guardado na stack
			lw $s0,0($sp) # Restaurar o valor de $s0 guardado na stack
			addi $sp,$sp,8 # Restaurar a stack ao valor inicial
			jr $ra # Retornar ao main
			
			
#---------------------------------------------------------------------------------------------------------------------------------#			
 
printBoard:		
			addi $sp,$sp,-8 # Descer a stack em 8 para guardar duas variáveis
			sw $s1,4($sp) # Guardar $s1 na stack
			sw $s0,0($sp) # Guardar $s0 na stack			
			
			move $s0,$a0 # Colunas
			move $s1,$a1 # Linhas
			lw $t1,Board
			
			mul $t2,$s0,$s1
			mul $t2,$t2,4
			li $t3,0
			li $t4,0
			
			
			
loopPrintBoard:
			beq $t4,$s0,printSpace
			
			beq $t2,$t3,endPrintBoard			
			
			li $v0,1
			lw $a0,($t1)
			syscall
			addi $t3,$t3,4
			addi $t1,$t1,4
			addi $t4,$t4,1
			j loopPrintBoard
			
printSpace:	
			la $a0,PrintNewline		#carregar o endereço para a0 da string 
			li $v0,4		
			syscall			#print na string
			li $t4,0
			j loopPrintBoard	
			
					
endPrintBoard:									
			lw $s1,4($sp) # Restaurar o valor de $s1 guardado na stack
			lw $s0,0($sp) # Restaurar o valor de $s0 guardado na stack
			addi $sp,$sp,8 # Restaurar a stack ao valor inicial
			jr $ra # Retornar ao main
			
#---------------------------------------------------------------------------------------------------------------------------------#			
			
printGameKey:		
			addi $sp,$sp,-4 # Descer a stack em 4 para guardar uma variável
			sw $s0,0($sp) # Guardar $s0 na stack
			move $s0,$a0 #Guardar o numero de colunas em $s0
			li $t2,0 # $t2 = 0
			lw $t0,gameKey # $t0 = &gameKey
			
printGameKeyLoop:
			beq $s0,$t2,endPrint # if ( $s0 == $t2) goto endPrint
			li $v0,1
			lw $a0,($t0) # $a0 = gameKey [$t0]
			syscall
		
			addi $t0,$t0,4 # $t0 = $t0 + 4
			addi $t2,$t2,1 # $t2 = $t2 + 1
			j printGameKeyLoop		

endPrint:		
			li $v0,4
			la $a0,PrintNewline
			syscall
			lw $s0,0($sp) #Restaurar o valor de $s0 guardado na stack
			addi $sp,$sp,4 # Restaurar a stack ao valor inicial
			jr $ra # Retornar ao main
