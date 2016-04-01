#---------------------------------------------------------------
# Assignment:           4
# Due Date:             April 1, 2016
# Name:                 Charles Laing
# Unix ID:              cclaing
# Lecture Section:      B1
# Lab Section:          H02 (Tuesday 17:00 - 19:50)
# Teaching Assistant(s):   Vincent Zhang
#---------------------------------------------------------------

	.data
buffer:		.space	60
prompt:		.asciiz	"input string = '"
comma:		.asciiz "', x = "
newline:	.asciiz "\n"




	.text
#-------------------------------
# Main sets ups the base addresses, enabled interrupts, and starts the timer. 
# a3 = Address for IO, s1 = 2, a2 = Base address of buffer
#-------------------------------
main:	
	li		$a3, 0xffff0000		#Set up the base address for I/O
	li		$s1, 2
	la		$a2, buffer			#Load the address of our buffer, so we can keep tabs on where we are
	
	#Enable the Keyboard interrupts
	sw		$s1, 0($a3)			#Enable the Keyboard Interrupts
	#add  	$sp, $sp, -8		# allocate frame: $a0, $a1
	  
	# Enable global interrupts
   	li		$s1, 0x0000ff01	       # set IE= 1 (enable interrupts) , EXL= 0
   	mtc0	$s1, $12	           # SR (=R12) = enable bits
	  
	# Start timer
   	   mtc0  $0, $9                  # COUNT = 0
   	   addi  $t0, $0, 1000           # $t0 = 1000 ticks Gives us enough time to enter our codes
   	   mtc0  $t0, $11                # CP0:R11 (Compare Reg.)= $t0
	   

	addi	$a1, $sp, 0  			#Make a copy of stack pointer in a1
#-------------------------------
#Inifinite loop to keep checking for interrupts
#-------------------------------
loop: beq $t0, $t0, loop			#Infinite Loop

	.globl	lab4_handler

#-------------------------------
# Code to handle the interrupts, either from keyboard or Timer
# Uses at for the exception code, a0 for the cause bit
#-------------------------------
lab4_handler:
	.set noat
	move $k1, $at				#Take in the value from the exception and give it to k1
	.set at

	mfc0 $k0, $13				#Give us the exception bit to work with
	
	srl		$a0, $k0, 11		#Now we shirt right by 11 to figure out WHY the exception happened
	andi	$a0, 0x1			#Was it a Keyboard exception?
	bgtz	$a0, keyboard		#If yes, branch over to the keyboard handler
	
	srl		$a0, $k0, 15		#Wasn't a keyboard exception? Was it a timer?
	andi	$a0, 0x1			#Lets check...
	bgtz	$a0, timer			#If it was, go do the timer stuff
#-------------------------------
#Runs after an exception occurs and it was the fault of the keyboard
#Adds the key to the stack for later use
#-------------------------------
keyboard:
	lb		$t1, 4($a3)			#Take the value of the key
	addi	$sp, $sp, -1		#Push it onto the stack
	sb		$t1, 0($sp)			#Write it in
	b		lab4_handler_ret
		
	
#-------------------------------
# Resets the timer, uses cp0 and registers $9 and $11. 
# should reset the timer to generate another interrupt 1000 ticks from now
# Also begins printing the frame, and starts the number generation process.
#-------------------------------
timer:
	#Reset the timer
   	mtc0  $0, $9                  # COUNT = 0
   	addi  $t0, $0, 1000             # $t0 = 1000 ticks
   	mtc0  $t0, $11                # CP0:R11 (Compare Reg.)= $t0
	
	#Every tick of the timer interrupt print the first part of the string
	li	  $s2, 0				#Set up s2 for the next use. 
	la		$a0, prompt			#Print the first part of the prompt
	li		$v0, 4				#set spim to print strings
	syscall						#call
	li		$v0, 11				#Set spim to print characters
	
#-------------------------------
# Pops keycodes off the stack and gets a running sum
# It doesnt matter if the keycodes overflow, so no need to check
# uses a0 to hold the value, and $sp, automatically decrements the stack
#-------------------------------
numloop:
	beq		$sp, $a1, numgen	#If the stack is empty, exit
	lb		$a0, 0($sp)			#Load the byte from the stack
	addi	$sp, 1				#Pop it from the stack
	add		$s2, $s2, $a0		#create a running sum
	syscall						#call
	b numloop					#Iterate


#-------------------------------
# Handles exiting the interrupt. clears the cause, status registers, 
# enables interrupts again
#-------------------------------
lab4_handler_ret:
	
	.set noat
	move $at $k1		# Restore $at
	.set at

	mtc0 $0 $13			# Clear Cause register

	mfc0  $k0 $12		# Set Status register
	ori   $k0 0x1		# Interrupts enabled
	mtc0  $k0 $12
	
	eret				# exception return

#-------------------------------
# Generates the random number based on what is in the user stack
# Numbers should be relatively random
# inputs:
#	s2: sum of all entered keycodes
# outputs:
#	a0: random number between 0 and 99
#-------------------------------
numgen:
	la	$a0, comma		#Load the comma string
	li	$v0, 4			#print it
	syscall				#call
	
	move 	$s4, $s2	#Move S2 into S4 so that we can work on it without affecting anything.

	#Random number alg: N = sum of all keys
	# N%100 = RandomInt
	# Should be relatively close to psuedorandom, at least seems that way. 	
	li		$s2, 100	#Set S2 to 100, which is the max for the random number that we want

	div		$s4, $s2	#Divide S4 by 100, which will give us a remainder to use
	mfhi	$s3			#Get the remainder from the hi register
	
	move	$a0, $s3	#Move it into a0 for printing and passing.
	jal printp2			#Print the second half of the string
	b		lab4_handler_ret	#Exit the interrupt

#-------------------------------
# Prints the second half of the string
# takes in:
# 	a0: Random number that was generated above
# gives out:
#	print values
#-------------------------------
printp2:
	addi	$sp, $sp, -8	#Make room on the stack for v0
	sw		$v0, 8($sp)		#Push v0 onto the stack
	
	li		$v0, 1			#Set up spim to print integers
	syscall					#Print our random number
	la 		$a0, newline	#Grab the newline character
	li		$v0, 4			#Print it
	syscall					
	
	lw		$v0, 8($sp)		#Get v0 back from the stack
	addi	$sp, $sp, 8		#decrement the stack
		
	jr		$ra				#Return back to caller
	
	
  
  
  
#------------------------------- 
# Exit the program
# (This probably will never be run)
#-------------------------------
exit:
	li		$v0, 10
	syscall
