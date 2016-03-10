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
	strOld: .asciiz "Enter strOld: "
	strMain: .asciiz "Enter strMain: "
	strNew: .asciiz "strNew: "

.text

main:
	
	la $a0, strMain
	li $v0, 8
	syscall
	
	la $a0, strMain
	li $v0, 8
	syscall
	
	la $a0, strMain
	li $v0, 8
	syscall
	
	

