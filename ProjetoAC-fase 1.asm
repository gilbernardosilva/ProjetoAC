
#Jogo Mastermind em Assembly realizado por Gil Silva 41805 e Joao Silva 39839






.data
	InsertKeyMessage: .asciiz "Insere um numero entre 1 a 6 para a tua chave\n"
	ErrorInsertKey: .asciiz "Erro, insere um numero entre 1 a 6 \n"
	RandomizeMessage: .asciiz "A chave do jogo era "
	InsertMessage: .asciiz "A tua chave de jogador é:"
	startGame: .asciiz "Vais agora começar um jogo de MasterMind"
	Intro: .asciiz "\nNo mastermind o teu objetivo é adivinhar a chave criada aleatoriamente pelo computador através das dicas dadas a cada ronda.\nAs dicas sao dadas atraves dos pinos de cor vermelha e branca, sendo os vermelhos indicadores de se acertamos a posicao da chave correta, e os brancos se temos um ou mais elementos da chave em comum."
	Red: .asciiz "Pinos Vermelhos="
	White: .asciiz "Pinos Brancos = "
	Space: .asciiz " "
	NewLine: .asciiz "\n"
	EndGameWinMessage: .asciiz "Acabaste o jogo descobrindo a chave correta\n"
	EndGameLossMessage: .asciiz "Nao conseguiste descobrir a chave correta\n"
	PontosJogada: .asciiz "Conseguiste adquirir estes pontos nesta jogada=> "
	PontosTotais: .asciiz "Tens de momento um total destes pontos => "
	NewGame: .asciiz "\nQueres jogar outra partida? Clica enter para continuar ou e para sair"
	.align 2
	playerkey:.space 16
	.align 2
	key:.space 16
	board: .word 0:40
	.align 2
.text
	main:	
			
			li $s1,0 #total points
			li $s2,0 #pontos jogada
			
	game:
			la $a0,startGame    #carregar o endereço para a0 da string 
			li $v0,4 		
			syscall 	#print na string 
			la $a0,Intro
			li $v0,4
			syscall
			jal clearArray  
			jal randomize_key
			li $s0,0   # s0 a 0
			
	gameLoop:
			move $a0,$s0  #passa para a0 o que esta em s0 
			beq $s0,10,endGameLoss 	#if i==10 vai para endgameloss ( sendo i o contador de linhas )
			jal insert_key
			jal checkRW
			beq $v1,4,endGameWin   #if v1 == 4 endgamewin 
			jal printBoard
			addi $s0,$s0,1   #s0=s0+1
			j gameLoop
	
	endGameWin:	   
			la $a0,EndGameWinMessage   #carregar o endereço para a0 da string 
			li $v0,4
			syscall		#print na string
			jal printRandomizeKey
			li $s2,12
			add $s1,$s1,$s2
			
			la $a0,PontosJogada
			li $v0,4
			syscall
			
			move $a0,$s2
			li $v0,1
			syscall
			
			la $a0,NewLine		
			li $v0,4
			syscall
			
			la $a0,PontosTotais
			li $v0,4
			syscall
			
			move $a0,$s1
			li $v0,1
			syscall
			
			la $a0,NewLine		#carregar o endereço para a0 da string 
			li $v0,4
			syscall
			
			la $a0, NewGame  #carregar o endereço para a0 da string 
			li $v0, 4
			syscall		#print na string
			
			la $a0,NewLine		#carregar o endereço para a0 da string 
			li $v0,4
			syscall		#print na string
			
			li $v0,12  	
			syscall    # le um carater 
			beq $v0,'e',StopGame    #if v0 = 'e' goto stop game 
  			j game 
	
	endGameLoss: 
			la $a0,EndGameLossMessage		#carregar o endereço para a0 da string 
			li $v0,4
			syscall		#print na string
			
			jal printRandomizeKey
			jal checkRW
			
			mul $s2,$v1,3
			add $s1,$s1,$s2
			
			la $a0,PontosJogada
			li $v0,4
			syscall
			
			move $a0,$s2
			li $v0,1
			syscall
			
			la $a0,PontosTotais
			li $v0,4
			syscall
			
			move $a0,$s1
			li $v0,1
			syscall
			
			
			la $a0, NewGame		#carregar o endereço para a0 da string 
			li $v0, 4
			syscall			#print na string
			
			la $a0,NewLine		#carregar o endereço para a0 da string 
			li $v0,4
			syscall			#print na string
			
			li $v0,12		
			syscall			#le um carater
			beq $v0,'e',StopGame   # se v0=='e' goto stop game 
			j game
			
	StopGame: 
			li $v0,10    #termina o programa 
			syscall

				
#Insert Key --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	insert_key:      #funçao usada para inserir a key , nao recebe nada nem retorna nada, escreve a key no array playerkey
			addi $sp,$sp,-12     #move a pilha para  o que queremos guardar 
			sw $s2,8($sp)
			sw $s1,4($sp)
			sw $s0,0($sp)
			li $s0,0           #s0 =0
			li $s2,0
			move $s1,$a0    
			mul $s1,$s1,16   #s1=s1x16
	loopkey:
			beq $s0,16,MessageKey   #if s0==16 goto messagekey 
			la $a0,InsertKeyMessage  #carregar o endereço para a0 da string 
			li $v0,4
			syscall 	#print na string
			li $v0,5		
			syscall			#le um inteiro 
			blt $v0,1,warning # >1 
			bgt $v0,6,warning # && <6
			sw $v0, playerkey($s0)  #guarda o que esta em v0 em playerkeyx s0 
			sw $v0, board($s1)     #guarda o que esta em v0 em board x s1
			add $s0,$s0,4          #s0 =s0+4
			add $s1,$s1,4		 #s1 =s1+4
			j loopkey
	warning:	
			la $a0, ErrorInsertKey       	#carregar o endereço para a0 da string 
			li $v0,4
			syscall			#print na string
			j loopkey
	MessageKey:
			la $a0,InsertMessage			#carregar o endereço para a0 da string 
			li $v0, 4
			syscall			#print na string
	print_playerKeyLoop:	
			beq $s2,16,end_insertkey #while i<=4
			lw $a0,playerkey($s2)	 	#guarda o que estas em a0 em playerkey x s2 
			li $v0,1
			syscall  #print de um inteiro 
			addi $s2,$s2,4
			j print_playerKeyLoop
	end_insertkey: 
			la $a0,NewLine			#carregar o endereço para a0 da string 
			li $v0, 4
			syscall			#print na string
			lw $s0,0($sp)
			lw $s1,4($sp)
			lw $s2,8($sp)
			addi $sp,$sp,12			#restaura o que estava nos registos e restaura a pilha 
		 	jr $ra						#volta para o endereço do ra 
#PRINTBOARD---------------------------------------------------------------------------------------------
	printBoard:	  #funçao usada para dar print a board do jogo 	, nao recebe nenhum parametro nem retorna nada no final 					
			addi $sp,$sp,-8 		#move a pilha para  o que queremos guardar 	
			sw $s1,4($sp)
			sw $s0,0($sp)	
			li $s0,0
			li $s1,0
	loopBoard:
			beq $s1,4,printSpace		#if s1==4 goto printspace 
			beq $s0,160,endprintBoard	#if s0==160 goto endprintboard 
			lw $a0,board($s0)		#guarda em board x s0 o que esta em a0 
			li $v0,1
			syscall				#print de um inteiro 
			addi $s0,$s0,4			#s0 =s0+4
			addi $s1,$s1,1
			j loopBoard	
	printSpace:	
			la $a0,NewLine		#carregar o endereço para a0 da string 
			li $v0,4		
			syscall			#print na string
			li $s1,0
			j loopBoard																																																																	
	endprintBoard:
			lw $s1,4($sp)		
			lw $s0,0($sp)
			addi $sp,$sp,8			#restaura o que estava nos registos e restaura a pilha 
			jr $ra						#volta para o endereço do ra 																																										
#Randomize Key --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	randomize_key:    #cria uma key todas as vezes que o jogo comeca e escreve-a em key sendo usada depois para comparar com a playerkey que o utilizador insere , nao recebe nenhum parametro nem retorna 
			addi $sp,$sp,-4			#move a pilha para  o que queremos guardar 
			sw $s0,0($sp)
			li $s0,0
	loop_key:	
			li $a1, 6 #upper border
			li $v0, 42 #random int
			syscall
			add $a0,$a0,1 #lower border
			beq $s0,16,end_randomizekey #while i <= 4 digitos
			sw $a0, key($s0) 
			addi $s0,$s0,4 #i++
			j loop_key 

	end_randomizekey:
			la $a0,NewLine			#carregar o endereço para a0 da string 
			li $v0, 4
			syscall			#print na string
			lw $s0,0($sp)
			addi $sp,$sp,4
		 	jr $ra

#CHECK RIGHT WRONG --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	checkRW:	  #funcao que compara as duas keys para verificar se a key inserida pelo jogador corresponde a  key que foi gerada automaticamente no inicio do jogo , nao tem parametros mas da return em v0 e v1 a quantidade de pinos vermelhos e brancos
			addi $sp, $sp, -28    #move a pilha e carrega o que quer nela 
			sw $s0,24($sp)
			sw $s1,20($sp)
			sw $s2,16($sp)
			sw $s3,12($sp)
			sw $s4,8($sp)
			sw $s5,4($sp)
			sw $s6,0($sp)
			
			li $s0,0 #Player Key
			li $s1,0 #Key
			li $s2,0 #X
			li $s3,0 #I
			li $s4,0 #J
			li $s5,0 #Red Flags
			li $s6,0 #White Flags
			
	loopR: 		
			beq $s2, 16, loopW #while x<=4
			lw $s0,playerkey($s2) #s0=playerkey[x]
			lw $s1,key($s2) #s1=key[x]
			beq $s0,$s1,rightR #playerkey[x]==key[x]
			addi $s2,$s2,4 #x++
			j loopR	
	rightR:  
			addi $s5,$s5,1 #Red Flag ++
			addi $s2,$s2,4 #x++
			j loopR
	loopW:		
			beq $s3,16,endW #while i<=4
			beq $s4,16,midW #while j<=4
			lw $s0, playerkey($s3) #playerkey[i]
			lw $s1, key($s4)	#key[j]
			beq $s0,$s1,rightW #playerkey[i]==key[j]
			addi $s4,$s4,4 #j++
			j loopW
	midW:		
			addi $s3,$s3,4 #i++
			li $s4,0
			j loopW			
	rightW:	
			addi $s6,$s6,1 #White Flag ++
			li $s4,16 #acabar J para nao ter repeticao
			j loopW			
	endW: 		
			la $a0,White     #carregar o endereço para a0 da string 
			li $v0,4
			syscall       #print na string 
			move $a0,$s6
			li $v0,1
			syscall
			la $a0,Space
			li $v0,4
			syscall
			la $a0,Red
			li $v0,4
			syscall
			move $a0,$s5    #move a0 para s5 
			li $v0,1
			syscall       #print  inteiro 
			la $a0,NewLine
			li $v0,4
			syscall
			move $v0,$s6 #v0=white
			move $v1,$s5 #v1=red
			lw $s0,24($sp)
			lw $s1,20($sp)
			lw $s2,16($sp)
			lw $s3,12($sp)
			lw $s4,8($sp)
			lw $s5,4($sp)
			lw $s6,0($sp)
			addi $sp,$sp,28
			jr $ra   #restaura a pilha e volta para o $ra 

#PRINT RANDOMIZE KEY -----------------------------------------------------

printRandomizeKey:  #funçao usada para dar print na key que foi gerada automaticamente no inicio do jogo , nao recebe nada nem retorna nada 
			addi $sp,$sp,-4
			sw $s0,0($sp)
			li $s0,0
MessageRandomize:
			la $a0,RandomizeMessage
			li $v0, 4
			syscall
			
loop_randomizekey:
			beq $s0,16,end_printRandomize #while i<=4
			lw $a0,key($s0) 
			li $v0,1
			syscall
			addi $s0,$s0,4
			j loop_randomizekey
			
end_printRandomize:
			la $a0,NewLine
			li $v0,4
			syscall
			lw $s0,0($sp)
			addi $sp,$sp,4
			jr $ra


#Clear Array Function
	clearArray:	#funçao usada para limpar o conteudo da board do jogo (o array board) , nao recebe nada nem da return a nada 				
			addi $sp,$sp,-8
			sw $s1,4($sp)
			sw $s0,0($sp)	
			li $s0,0
			li $s1,0
	loopClear:
			beq $s0,160,endClear     #if s0 == 160 goto endclear ( 160 pois temos 4*10*4 linhaxcolunax4bytesint)
			sw $s1,board($s0)        #guarda o conteudo de s2 em board x s0 
			addi $s0,$s0,4
			j loopClear
	endClear:	
			lw $s1,4($sp)
			lw $s0,0($sp)
			addi $sp,$sp,8
			jr $ra
