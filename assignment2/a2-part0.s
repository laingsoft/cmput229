# --------------- Data Segment ----------
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

	la $a0, msg_length # print length li $v0, 4 syscall
	lw $a0, length
	li $v0, 1
	syscall

	jal print_NL #print newline
	# ... more user code ...

	lw $t1, length # $t1= length

loop:	addi $t1, -1 # $t1= $t1 - 1
	bltz $t1, next # if (t1 < 0)
	goto next
	#
	# ... loop body ...
	#
	b loop
	
next:
	# ... more user code ...
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
getlen: li $v0, 8
	jr $ra
# --------------
# procedure 'print_NL'
print_NL:
	li $a0, 0xA # newline character
	li $v0, 11
	syscall

