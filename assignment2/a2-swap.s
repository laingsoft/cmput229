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
# The swapchar subroutine runs a loop three times that exchanges the 
# locations of the characters at (0,1), (2,3), (4,5), etc.
#
# Register Usage:
#
#       a0: Contains the address of a character in Buff
#       t4: Stores the number of times we need to iterate
#		t1: Stores the first character to swap 
#		t2: Stores the second character to swap
#		t9: stores the constant 2, used to divide t4		
#		ra: Reference address
#---------------------------------------------------------------

#--------------- Data Segment ----------
.data
	msg_prompt: .asciiz "\n? "
	msg_length: .asciiz "length= "
	msg_exit: .asciiz "end of program"
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
	
	jal swap_char #Call our subroutine that edits the string
	la $a0, buff #Load the string we edited
	li $v0,4 #Set the syscall to output strings
	syscall
	jal print_NL #Print a newline
	
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
	la $a0, msg_exit #Print the exit message
	li $v0, 4 #Display Exit Message
	syscall
	li $v0, 11 #Exit the program
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
# procedure 'swap_char'
swap_char:
	la $a0, buff #Load the String we Want to edit
	lw $t4, length #Load the Length of the string that we get from getlen
	li $t9, 2 #Load immediate 2, so we know how many times to iterate
	div $t4, $t9 #divide the length by 2
	mflo $t4 #Move the quotient from LO to the counter register
	
swap_loop:
	beq $t4, $zero, swap_end #End the loop if it's run 3 times
	
	lb $t1, 0($a0) #Load the first character

	lb $t2, 1($a0) #Load the second character
	
	sb $t2, 0($a0) #Save the second char at the memory address of 1
	sb $t1, 1($a0) #Save the First char at the memory address of 2
	
	addi $a0,$a0, 2 #Step Forward Two Characters
	addi $t4,$t4,-1 #Decrement the Loop Counter.
	j swap_loop #Run the Loop Again

swap_end:
	jr $ra #If the loop is complete, return to the caller