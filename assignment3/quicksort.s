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
	.align 1
	S:		.space		2*40									#Create the Stack

#---------------------------------------------------------------
#	REGISTER USAGE:
#	$a0 - Base Address of L
#	$t1 - Temporary Loop Variable holding the value of an index of L
#	$s1 - N, Length of L
#	$a1 - Base Address of the Stack
#---------------------------------------------------------------
	.text
	
#---------------------------------------------------------------
#	Main entry point for the application
#---------------------------------------------------------------
main:
	la 		$a0, 	L 			#Load the Address of L
	li 		$s1, 	0			#Load the Immediate Value 0 to represent N
	la		$a1, 	S			#Load the Base Address of the Stack
	add		$s3, 	$a1,	$0	#Load the Frame Pointer of the Stack
	li		$v0, 0
	li		$a2, 0

#---------------------------------------------------------------
#	Counts the length of the list
# $t1 = character of L
# $v0 = len
# $a0 = address of L
#---------------------------------------------------------------
loop:
	lh		$t1, 	0($a0)		#Load the first character of the string
	beq		$t1, 	$0, push	#If We're at the end of the array, exit the loop
	addi	$v0, 	1			#Increment N to represent the length
	addi	$a0, 	2			#Increment the address by 2 bytes, because it's a halfword
	j loop						#Iterate

#---------------------------------------------------------------
#	Push pushes the data to the stack, and lets the values work
# v0 = N
# a0 = Address of L
# a2 = first
# a1 = frame pointer
# 
#---------------------------------------------------------------	
push:
	addi	$v0,	-1			#Subtract 1 from N to get the index value
	la		$a0, 	L			#Load the beginning of the array again
	sh		$a2, 	0($a1)		#Push the index 0 to the stack
	addi	$a1,	2			#Increment the Frame Pointer of the stack
	sh		$v0, 	0($a1)		#Push the Index n-1 to te stack
	li		$v0, 0
	
#---------------------------------------------------------------
# Qsort sorts the list 
#	s3 = frame pointer
#	$a1 = stack address
#	s6 = Last
#	s7 = First
#	s0 = pivot
#	
#---------------------------------------------------------------
qsort:
	beq		$s3, $a1, print_list	#If the frame pointer and the base address are the same, the stack is empty
	#Pop the Value from the stack
	lh		$s6, 0($a1)			#Load the Last Value
	addi	$a1, -2				#Decrement
	lh		$s7, 0($a1)			#Load the First Value
	
	lh		$s0, 0($a0)			#x = first element of L
	
	#Set up the values so that they work on with split
	move	$s2, $a1
	move	$a1, $s6
	move	$a2, $s7
	add		$a3, $a0, $0
	
	
#---------------------------------------------------------------
# partitions the list by the pivot, and sorts it.
# $a0 = Base of L
# $a1 = first
# $a2 = last
#---------------------------------------------------------------
split:
	addi	$v0, 1				#Increment v0 by 1
	addi	$a0, 2				#Increment a0 by 1
	
	lh 		$s1, 0($a0)			#Load the new half at a0 
	
	bge		$a2, $a1, finish	#If greater than, break
	bgt		$s1, $s0, swap		#if less than, swap the two
	addi	$a2, 1				#Increment the address
	j		split
	
#---------------------------------------------------------------
#Swaps the two registers
#	$s1 = register 1
#	$a3	= address of register 2
#	$a0 = address of register 1
#	$s0 = register 2
#	
#---------------------------------------------------------------
swap:
	sh		$s1, 0($a3) #Do the Swap
	sh		$s0, 0($a0) #Do the Swap
	move	$a3, $a0	#Set up the registers for the next call
	move 	$s4, $v0	#set up the registers for the next call
	
	addi 	$a2, 1		#increment the iterator
	j split				#Jump to split
	
finish:
	move 	$v0, $s4	#Set v0 to the pivot index
	addi	$v0, 1		#Add 1 to v0
	sh		$v0, 0($s2) #Store it on the stack
	addi	$s2, 2		#increment the stack
	sh		$a2, 0($s2)	#store the second part on the stack
	la		$s1, L
	
	
	
	
	
	
	

print_list:
	syscall
	lh		$a0, 0($s1)
	li		$v0, 1
	addi	$s1, 	2			#Increment the address by 2 bytes, because it's a halfword
	beq		$a0, $0, endi
	j print_list						#Iterate

endi:
	li	$v0, 10
	syscall
