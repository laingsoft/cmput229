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
	jal getInput
	
	la $s1, strMain
	la $s2, strOld
	la $s3, strNew

	lb $s4, 0($s1)
	lb $s5, 0($s2)
	lb $s6, 0($s3)

	jal loop
	
	la $a0, strMain
	li $v0, 4
	syscall
	
	li $v0, 10
	syscall
loop:
	beq $s4, $zero, exit 	#If char == 0, end
	beq $s4, 0xA, exit 		#If char == \n, end
	beq $s4, 0xD, exit 		#if char ==Ret, End
	beq $s5, $zero, exit
	beq $s5, 0xA, exit
	beq $s5, 0xD, exit
	
	lb $s4, 0($s1)
	lb $s5, 0($s2)
	lb $s6, 0($s3)

	beq $s4, $s5, match
	addi $s1, 1
	j loop
	
	
match:
	sb $s6, 0($s1)
	addi $s2, 1
	addi $s3, 1
	j loop
	
exit:
	jr $ra
	
	
	


getInput:
	
	la $a0, strMainlabel
	li $v0, 4
	syscall
	
	la $a0, strMain
	li $a1, 81
	li $v0, 8
	syscall
	
	la $a0, strOldlabel
	li $v0, 4
	syscall
	
	la $a0, strOld
	li $a1, 81
	li $v0, 8
	syscall
	
	la $a0, strNewlabel
	li $v0, 4
	syscall
	
	la $a0, strNew
	li $a1, 81
	li $v0, 8
	syscall
	
	jr $ra