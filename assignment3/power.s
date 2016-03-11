#---------------------------------------------------------------
# Assignment:           3
# Due Date:             March 11, 2016
# Name:                 Charles Laing
# Unix ID:              cclaing
# Lecture Section:      B1
# Lab Section:          H02 (Tuesday 17:00 - 19:50)
# Teaching Assistant(s):   Vincent Zhang
#---------------------------------------------------------------
	
	.data
N:		.half 10	#stores the positive integer n
X:		.half 3		#stores the positive integer x
result:	.word 0		#stores result

#Output Formatting strings
sp:		.asciiz	"            "
lnbrkd:	.asciiz	"=====================================\n"	
lnbrk:	.asciiz "------------------------------------\n"
vlin:	.asciiz " |"
eq:		.asciiz " = "
ca0:	.asciiz "a"
brk:	.asciiz "\n"



	.text
#---------------------------------------------------------------
# The main program initalizes the values of X, N, and Result, and loads their 
# addresses into registers. It then opens N new stackframes, and populates their values
# following this, it frees the stack, and closes the system
#		Register Usage:
#			$a0 - Value of X
#			$a1 - value of N
#			$a2 - address of result
#			$a3 - result(integer)
#			$sp - stack pointer
#			$t0 - recursive break boolean
#			$ra - return address
#
#---------------------------------------------------------------
main:
	lh		$a0, X				#Load the value X into the first argument reg
	lh		$a1, N				#Load the value N into the second argument reg
	lh		$a2, result			#Load the value result into the third argument reg
	addi	$a3, $a3, 1			#give a3 an initial value of 1, because 0*n = 0
pop:addiu	$sp, $sp, -20		#Give 4 words on the stack. We need to add a label here to avoid overwriting our stack on each recurse
	la		$a2, result			#Load the address of the label result into a2
	sw		$ra, 0($sp)			#Store the address of the label result into the stack in each frame
	sw		$a0, 4($sp)			#Store N in the stack
	sw		$a1, 8($sp)			#Store X in the stack
	sw		$a2, 12($sp)		#Store Result Address
	sw		$a3, 16($sp)		#This is where we will put the calculated value
	
	slti	$t0, $a1, 1			#If we've created the N number of stack frames, move forward. 
	beq		$t0, $zero, powXN	#Jump to the recursive power function
	

	addi	$sp, $sp, 20		#Destroy the stack
	jr		$ra					#Jump back to caller
	

	li $v0, 10					#Set the system to exit
	syscall						#Close
#---------------------------------------------------------------
#	Calculate the value of x^n recursively
#---------------------------------------------------------------
powXN:
	addi 	$a1, $a1, -1		#Decrement N
	jal 	pop					#Create the stackframes that we need
	jal		clear_reg			#Clear the Registers, as requested in the assignment
	add		$t0, $ra, $zero		#save the return address for later
	jal		print_frame			#print the frame as requested in the assignment
	lw		$ra, 0($sp)			#Load return address from the stack
	lw 		$a0, 4($sp)			#Load a0(X) from the stack
	lw 		$a1, 8($sp)			#Load a1(N) from the stack
	lw		$a2, 12($sp)		#load a2(addr) from the stack
	lw		$a3, 16($sp)		#load a3(x^n) from the stack
	
	mul		$a3, $a0, $a3		#Do the actual math to calculate X^N

	addi	$sp, $sp, 20		#Jump back up the stack and free it
	sw		$a3, 16($sp)		#Write in the calculated value to the top portion of the stack
	sw		$a2, 12($sp)		#Write in the address to the next point on the stack
	sw		$a3, 0($a2)			#Write the result to the address in the data segment

	jr		$ra					#Jump back to the return address
	
#---------------------------------------------------------------
#	Clears registers a0 - a3 
#---------------------------------------------------------------
clear_reg:
	li $a0, 0					#Clear a0
	li $a1, 0					#Clear a1
	li $a2, 0					#clear a2
	li $a3, 0					#clear a3
	jr $ra						#return to caller
	

#---------------------------------------------------------------
#	Formats and prints the strings as required in the documentation 
#---------------------------------------------------------------
print_frame:
	li		$t0, 0				#Load a temporary loop variable
	li		$t3, 4				#Load a temporary comparison variable
	la		$a0, sp				#Load a string of spaces into an a0 so we can print it
	li		$v0, 4				#Set the system to print integers
	syscall						#print
	la		$a0, lnbrkd			#Load the address of the double line string
	syscall						#print
	add 	$t1, $sp, $zero		#Copy the stack pointer to a temporary so we don't mess with the rest of the system
loop:						#Loop to print the internal register values
	beq 	$t0, $t3, fprint	#If we are at the end of our index, jump to the end and exit the loop

	move 	$a0, $t1			#Move the value of our temporary pointer to a0 for printing
	li		$v0, 1				#print the memory address of our stack pointer
	syscall						#print
	
	la		$a0, vlin			#Print the '|' character
	li		$v0, 4				#set spim to print strings
	syscall						#print
		
	la		$a0, ca0			#move the character 'a' into a0 so we can just add an integer to print multiple registers
	syscall						#print
	
	move	$a0, $t0			#print the register number we are printing
	li		$v0, 1				#set spim to print integers
	syscall						#print
	
	la		$a0, eq				#load the address of the '=' sign
	li		$v0, 4				#set spim to print strings
	syscall						#print
	
	lw		$a0, 4($t1)			#load the word at our local stack pointer address
	li		$v0, 1				#set spim to print integers
	syscall						#print
	
	la		$a0, brk			#load the address for a linebreak character
	li		$v0, 4				#set spim to print strings
	syscall						#print
	
	la		$a0, sp				#load the address of the space string
	syscall						#print
	
	la		$a0, lnbrk			#load the address for our linebreak
	syscall						#print 

	addi	$t0, $t0, 1			#increment the loop variable
	addi	$t1, $t1, 4			#increment our local stack pointer
	b loop						#branch to the loop
fprint:				#finish printing the frame
	la		$a0, sp				#Load the address for our string of spaces
	li		$v0, 4				#set spim to print strings
	syscall						#print
	la		$a0, lnbrkd			#load the address of our double linebreak
	syscall						#print
	jr $ra						#jump back to caller
	