#---------------------------------------------------------------
# Assignment:           2
# Due Date:             February 12, 2016
# Name:                 Charles Laing
# Unix ID:              cclaing
# Lecture Section:      B1
# Lab Section:          H02 (Tuesday, 5pm - 7:50pm)
# Teaching Assistant(s):   Vincent Zhang
#---------------------------------------------------------------
.data
	strOldlabel: .asciiz "Enter strOld: "
	strMainlabel: .asciiz "Enter strMain: "
	strNewlabel: .asciiz "strNew: "
	.align 2
	strOld: .space 81
	.align 2
	strMain: .space 81
	.align 2
	strNew: .space 81
	.align 2
	strBuild: .space 81

.text
main:
	jal getInput		#Jump to getInput
	
	la $s1, strMain		#Load strMain address to $s1
	la $s2, strOld		#Load strOld address to $s2
	la $s3, strNew		#Load strNew address to $s3

	lb $s4, 0($s1)		#Load first byte from strmain to $s4
	lb $s5, 0($s2)		#Load first byte from strold to $s5
	lb $s6, 0($s3)		#Load first byte from strnew to $s6

	jal loop			#Jump to Loop
	
	la $a0, strMain		#Load address strmain to $a0
	li $v0, 4			#Load immediate 4 into $v0
	syscall				#Print the edited strMain
	
	li $v0, 10			#Load system op 10
	syscall				#exit the program
loop:
	beq $s4, $zero, exit 	#If char == 0, end
	beq $s4, 0xA, exit 		#If char == \n, end
	beq $s4, 0xD, exit 		#if char ==Ret, End
	beq $s5, $zero, exit	#If strOld is done, break
	beq $s5, 0xA, exit		#If strOld is done, break
	beq $s5, 0xD, exit		#If strOld is done, break
	
	lb $s4, 0($s1)			#Load the byte from s1 into s4
	lb $s5, 0($s2)			#Load the byte from s2 into s5
	lb $s6, 0($s3)			#Load the byte from s3 into s6

	beq $s4, $s5, match		#If the bytes in s4 and s5 are the same, branch to match
	addi $s1, 1				#increment the strMain address
	j loop					#Loop
	
	
match:
	sb $s6, 0($s1)			#Save the byte from strNew to strMain
	addi $s2, 1				#Increment the strOld address
	addi $s3, 1				#Increment the strNew address
	j loop					#Loop
	
exit:
	jr $ra					#Exit condition
	
	
#-------------
#Procedure getInput: Take in Input from the console and save it to strings
#-------------
getInput:
	#Print the mainlabel
	la $a0, strMainlabel
	li $v0, 4
	syscall
	#Prompt for the mainstring
	la $a0, strMain
	li $a1, 81
	li $v0, 8
	syscall
	#Print the oldLabel string
	la $a0, strOldlabel
	li $v0, 4
	syscall
	#prompt for the old string
	la $a0, strOld
	li $a1, 81
	li $v0, 8
	syscall
	#print the new label
	la $a0, strNewlabel
	li $v0, 4
	syscall
	#prompt the old string
	la $a0, strNew
	li $a1, 81
	li $v0, 8
	syscall
	
	jr $ra #Return to caller