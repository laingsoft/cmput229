#---------------------------------------------------------------
# Assignment:           2
# Due Date:             February 12, 2016
# Name:                 Charles Laing
# Unix ID:              cclaing
# Lecture Section:      B1
# Lab Section:          H02 (Tuesday, 5pm - 7:50pm)
# Teaching Assistant(s):   Vincent Zhang
#---------------------------------------------------------------
# Register Usage
#	a1: storing bytes from buff
#	t1: Loop Counter
#	t2: Memory Address for storing result
#	s0: extracted hex value from toHex procedure
#	s3: Storing the lest significant bit in printword procedure
#	s4: storing the word to write to memory in printword procedure
#	ra: return address
#	$zero: zero
#	a0: procedure arguments
#	v0: spim arguments
#	
#---------------------------------------------------------------

.data
	prompt: .ascii "String= "
	buff: .space 81
	.align 2
	result: .space 81
	

.text

main:
	jal getstr 				#Jump to GetString
	jal tohex 				#Jump to tohex

	addi $s0,$s0, 2 		#Add 2, so that we can get the right result
	jal printword 			#Jump to the Printing Subroutine
	
	la $a0, result 			#Print the final String
	li $v0, 4
	syscall
	
	li $v0, 10 				#End the program
	syscall

#---------
#procedure printword
#prints the value of the register given in s0 as an ascii string
#---------
printword:
	li $t1, 8 				#Load the loop counter
	la $t2, result 			#Load the address where we are storing results
	addi $t2, 7 			#little endian, so reverse the write order
ploop:
	beq $t1, $zero, pend 	#If counter <0, end
	andi $s3, $s0, 0xf 		#Get the least significant bit
	ble $s3, 9, sum 		#If less than 9, go to sum
	addi $s3, $s3, 55		#add 55 otherwise to get the ascii value
	b fin					#Goto end 
	
sum:
	addi $s3, $s3, 48		#if 0-9, only add 48 to get the ascii val
	
fin:
	srl $s0, $s0, 4			#Shift right logical to cut the LSB off
	#lb $t4, 0($t2)
	sll $s4, $s4, 8			#Shift s4 left so we have a register to write to
	add $s4, $s4, $s3		#append our new char to s4
	sb $s4, 0($t2)			#save the new register at t2
	addi $t2, -1			#Decrement memory location
	addi $t1, -1			#Decrement the loop counter

	j ploop					#loop
pend:
	jr $ra					#return to caller
	
	
#------------
#Procedure toHex, Converts from String to Hexidecimal in Register s0
#------------
tohex:
	la $a0, buff 			#Load the string from Buffer

#Loops over the buff to convert chars to hex
loop:
	lb $a1 0($a0) 			#Load the byte that we want from buff
	beq $a1, $zero, exit 	#If char == 0, end
	beq $a1, 0xA, exit 		#If char == \n, end
	beq $a1, 0xD, exit 		#if char ==Ret, End
	bgt $a1, 0x39, atof 	#Branch to AtoF if >9
	
#Saves the character in register a0
save:
	andi $a1, $a1, 0xf 		#Save only the least significant bit
	sll $s0, $s0, 4 		#Logical Left Shift, Add a 0 to the right side
	add $s0, $a1, $s0 		#Add the new character to the old hex values
	addi $a0, $a0, 1 		#Increment the address to read chars from
	
	j loop 					#Iterate
exit:
	jr $ra 					#When loop is finished, return to procedure that called tohex

atof: 
	sub $a1, $a1, 0x37 		#Subtract 0x37 to get the hex value
	j save 					#Jump to Save
	


#----------
#Procedure getstr
#Gets the String from the Console and stores it in buff
#----------	
getstr:
	la $a0, prompt			#Print the prompt
	li $v0, 4
	syscall
	
	la $a0, buff			#Load the Buffer
	li $a1, 81				#Set the length
	li $v0, 8				
	syscall
	jr $ra					#return to caller
	

