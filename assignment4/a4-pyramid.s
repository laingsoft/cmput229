# ------------------------------
# pyramid.s:  print a pyramid of asterisks recursively
# ------------------------------
	    .globl pyramid
	    .globl write_frame

	    .data
N:	    .word  15	# width of the pyramid
K:	    .word  5	# left margin of the pyramid's base

char_fill:  .byte  '*'
char_space: .byte  ' '

str_dash:   .asciiz "           ________________________\n"

str_a0:	    .asciiz "| a0= "
str_a1:     .asciiz "  a1= "
str_ra:	    .asciiz "  ra= "

# ------------------------------
	  .text
main:
	  addi  $sp, $sp, -8		# allocate frame: $a0, $a1
	  lw    $a0, N	  		# $a0= N
	  lw    $a1, K			# $a1= K
	  jal   pyramid			# call pyramid(N,K)

exit:	  addi  $sp, $sp, 8		# release stack frame
	  li    $v0, 10; syscall	# exit

# ------------------------------
# function pyramid ($a0= N, $a1= K)
#

          nop; nop
pyramid:  
	  addi $sp, $sp, -12		# allocate frame: $a0, $a1, $ra
	  sw   $a0, 12($sp)		# store $a0= N in caller's frame
	  sw   $a1, 16($sp)		# store $a1= K in caller's frame
	  sw   $ra,  8($sp)		# store $ra in pyramid's frame	

	  li   $t0, 2			# $t0= 2
	  ble  $a0, $t0, pyramid_line	# n <= 2: goto write line
	  addi $a0, $a0, -2		# n= n-2
	  addi $a1, $a1, 1              # k= k+1
	  jal  pyramid

pyramid_line:
	  lb   $a0, char_space		# $a0 = ' '
	  lw   $a1, 16($sp)		# $a1= K
	  jal  write_char

	  lb   $a0, char_fill		# $a0 = '*'
	  lw   $a1, 12($sp)		# $a1= N
	  jal  write_char

	  jal  print_NL			# print NL

#	  jal  write_frame

pyramid_end:
	  lw   $ra, 8($sp)		# restore $ra
	  addi $sp, $sp, 12		# release stack frame
	  jr   $ra  			# return

# ------------------------------
# function write_char ($a0= char, $a1= count)
#
          nop; nop
write_char:
	  beqz  $a1, write_char_end	# $a1 == 0: return
	  li    $v0, 11			# print character
	  syscall
	  addi  $a1, $a1, -1		# $a1 = $a1 -1
	  b     write_char

write_char_end:
	  jr    $ra		        # return
# ------------------------------
# function write_frame ($sp) 
#
	   nop; nop
write_frame:
	   addi  $sp, $sp, -4			  # allocate frame: $ra
	   sw    $ra, 0($sp)			  # store $ra

	   # print the frame that starts at $sp + 4

           la    $a0, str_dash			  # print a separator line
	   li    $v0, 4; syscall			 

	   addi  $a0, $sp, 4			  # $a0 = input $sp		 
	   li    $v0, 1; syscall	      	  # print $sp

	   la	 $a0, str_a0;  li $v0,4; syscall  # print $a0 = 
	   lw	 $a0, 4($sp);  li $v0 1; syscall  # print value

	   la	 $a0, str_a1;  li $v0,4; syscall  # print $a1 = 
	   lw	 $a0, 8($sp);  li $v0 1; syscall  # print value

	   la	 $a0, str_ra;  li $v0,4; syscall  # print $ra = 
	   lw	 $a0, 12($sp); li $v0,1; syscall  # print value

	   jal   print_NL      	      	 	  # print NL
	   
	   lw    $ra, 0($sp)			  # restore $ra
	   addi  $sp, $sp, 4			  # release frame
	   jr	 $ra

# ------------------------------
# function print_NL()
#
	  nop; nop
print_NL:
          li   $a0, 0xA   # newline character
          li   $v0, 11
          syscall
          jr    $ra
# ------------------------------