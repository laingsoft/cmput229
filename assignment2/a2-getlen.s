#---------------------------------------------------------------
# Assignment:           2 
# Due Date:             February 12, 2016
# Name:                 Charles Laing
# Unix ID:              cclaing
# Lecture Section:      B1
# Lab Section:          H02 (Tuesday 17:00 - 19:50)
# Teaching Assistant(s):   Vincent Zhang
#---------------------------------------------------------------

#---------------------------------------------------------------
# The getlen subroutine returns the amount of characters in a given 
# string. The procedure takes input as a string stored in buff
# The procedure returns the number of characters in a given string in 
# register $v0. 
#
# Register Usage:
#
#       a0: Contains the address of a character in Buff
#       v0: Contains the return length of the string
#		t1: Stores the value in memory at a0
#		ra: Reference address
#---------------------------------------------------------------

#--------------- Data Segment ----------
.data
	msg_prompt: .asciiz "\n? "
	msg_length: .asciiz "length= "
	length: .word 0
	buff: .space 81

# --------------- Text Segment ----------
	.text
main:
	jal getstr # get input string
	jal getlen # get string length
	sw $v0, length # store length

	la $a0, msg_length # print length 
	li $v0, 4 
	syscall
	
	lw $a0, length
	li $v0, 1
	syscall

	jal print_NL #print newline
	# ... more user code ...

	lw $t1, length # $t1= length

loop:	
	addi $t1, -1 # $t1= $t1 - 1
	bltz $t1, next # if (t1 < 0) goto next
#
# ... loop body ...
#
	b loop

next:
#	... more user code ...
	li $v0, 10 #exit
	syscall
# --------------
#procedure 'getstr'

getstr:
prompt: la $a0, msg_prompt # display prompt
	li $v0,4
	syscall

	la 	$a0, buff # read string
	li $a1, 80
	li $v0, 8
	syscall

	jr $ra # return from procedure
# --------------
# procedure 'getlen'
getlen: 
	#li $v0,8 
	la $a0, buff #Load string from buff into register A0
	
len_loop: lb $t1 0($a0) #Create a loop that iterates the string
	beq $t1, $zero, len_end #If char == 0, end
	beq $t1, 0xA, len_end #If char == \n, end
	beq $t1, 0xD, len_end #if char ==Ret, End
	addi $a0, $a0, 1 #Increment the addresses
	
	j len_loop #Loop and Iterate
	
len_end: la $t1, buff #Load the first character address into $t1
	#Because we are working with addresses, subtracting the starting address
	#from the ending address will give us the length of the string
	sub $v0,$a0,$t1 #Get the difference between the first and last addresses
	jr $ra #Return to the original caller
# --------------
# procedure 'print_NL'
print_NL:
	li $a0, 0xA # newline character
	li $v0, 11
	syscall
	jr $ra
# --------------