	.text
main:
			# step 1: read a number from the keyboard
       li $v0, 5
       syscall
       sw $v0, number

			# step 2: input a string, store in ’buffer’
       la $a0, buffer
       li $a1, 30
       li $v0, 8
       syscall

			# step 3: stop execution
       li $v0, 10
       syscall

       .data
buffer: .space 30
number: .word 1
