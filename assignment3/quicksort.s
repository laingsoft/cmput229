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

	L: 		.half 		10, 30, 20 15, 8, 7, 5, 0				#Take input
	S:		.space		20										#Create the Stack

#---------------------------------------------------------------
#	REGISTER USAGE:
#	$a0 - Base Address of L
#	$t1 - Temporary Loop Variable holding the value of an index of L
#	$s1 - N, Length of L
#	$a1 - Base Address of the Stack
#---------------------------------------------------------------
	.text
	
#---------------------------------------------------------------

#---------------------------------------------------------------
main:
	la 		$a0, 	L 			#Load the Address of L
	li 		$s1, 	0			#Load the Immediate Value 0 to represent N
	la		$a1, 	S			#Load the Base Address of the Stack
	add		$s3, 	$a1,	$0	#Load the Frame Pointer of the Stack

#---------------------------------------------------------------
#---------------------------------------------------------------
loop:
	lh		$t1, 	0($a0)		#Load the first character of the string
	beq		$t1, 	$0, push	#If We're at the end of the array, exit the loop
	addi	$s1, 	1			#Increment N to represent the length
	addi	$a0, 	2			#Increment the address by 2 bytes, because it's a halfword
	j loop						#Iterate

#---------------------------------------------------------------
#---------------------------------------------------------------	
push:
	addi	$s1,	-1			#Subtract 1 from N to get the index value
	la		$a0, 	L			#Load the beginning of the array again
	sh		$zero, 	0($s3)		#Push the index 0 to the stack
	addi	$s3,	2			#Increment the Frame Pointer of the stack
	sh		$s1, 	0($s3)		#Push the Index 6 to te stack
	
	
	
qsort:
	beq		$s3, $a1, finish	#If the frame pointer and the base address are the same, the stack is empty
	
	#Pop the Value from the stack
	lh		$s6, 0($s3)			#Load the Last Value
	addi	$s3, -2				#Decrement
	lh		$s7, 0($s3)			#Load the First Value
	sw		$0,	0($s3)			#Delete the value from the stack
	
	bgt		$s7, $s6, finish	#If first>last exit the program
	
	#Load the Value at the Index of $s7
	add		$t2, $s7, $a0		#Select the index of the first 
	lh		$s5, 0($t2)			#Load the value at the index of the first
	
	
	
	
	
	
#---------------------------------------------------------------
#---------------------------------------------------------------
finish:
	li		$v0, 10
	syscall
	

