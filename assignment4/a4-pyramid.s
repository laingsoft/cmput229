# ------------------------------
# pyramid.s:  print a pyramid of asterisks recursively 
# This code is borrowed from the Lab 4 Exercise. 
# ------------------------------
	    .globl pyramid
	    .globl write_frame

	    .data
N:	    .word  1	# width of the pyramid
K:	    .word  0	# left margin of the pyramid's base

char_fill:  .byte  '*'
char_space: .byte  ' '

str_dash:   .asciiz "           ________________________\n"

str_a0:	    .asciiz "| a0= "
str_a1:     .asciiz "  a1= "
str_ra:	    .asciiz "  ra= "

s_a0:		.word	0
s_v0:		.word	0

# ------------------------------
	  .text
main:
	  li	$a3, 0xffff0000		#Set up the base address for I/O
	  li	$s1, 2
	  
	#Enable the Keyboard interrupts
	  sw	$s1, 0($a3)			#Enable the Keyboard Interrupts
	  addi  $sp, $sp, -8		# allocate frame: $a0, $a1
	  
	# Enable global interrupts
   	  li	$s1, 0x0000ff01	       # set IE= 1 (enable interrupts) , EXL= 0
   	  mtc0	$s1, $12	           # SR (=R12) = enable bits
	  
	# Start timer
   	   mtc0  $0, $9                  # COUNT = 0
   	   addi  $t0, $0, 50             # $t0 = 50 ticks
   	   mtc0  $t0, $11                # CP0:R11 (Compare Reg.)= $t0
	  
loop: 
	  lw    $a0, N	  		# $a0= N
	  lw    $a1, K			# $a1= K	
	  beq $t0, $t0, loop
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

	.globl lab4_handler
lab4_handler:
	.set noat
	move $k1, $at
	.set at
	sw $v0, s_v0
	sw $a0, s_a0
	
	mfc0 $k0, $13
	
	srl		$a0, $k0, 11
	andi	$a0, 0x1
	bgtz	$a0, keyboard
	
	srl		$a0, $k0, 15
	andi	$a0, 0x1
	bgtz	$a0, timer
	
keyboard:
	lw $t2, 0xffff0004
	
	beq $t2,0x69, incri #Handle I
	beq $t2, 0x64, decri #Handle D
	beq $t2, 0x72,	incrk		#Handle R
	beq $t2, 0x6c	decrk		#Handle L
	beq $t2, 0x71	quit		#Handle Q
	b	exit
incri:	lw  $t0, N
		la	$t1, N
		beq $t0, 20, lab4_handler_ret
		addi $t0, 1
		sw	$t0, 0($t1)
		b lab4_handler_ret
decri:	lw  $t0, N
		la	$t1, N
		beq $t0, 1, lab4_handler_ret
		addi $t0, -1
		sw	$t0, 0($t1)
		b lab4_handler_ret
incrk:	lw  $t0, K
		la	$t1, K
		beq	$t0, 40, lab4_handler_ret
		addi $t0, 1
		sw	$t0, 0($t1)
		b lab4_handler_ret
decrk:	lw  $t0, K
		la	$t1, K
		beq $t0, 0, lab4_handler_ret
		addi $t0, -1
		sw	$t0, 0($t1)
		b lab4_handler_ret
finish:
	b lab4_handler_ret


timer:
   	   mtc0  $0, $9                  # COUNT = 0
   	   addi  $t0, $0, 50             # $t0 = 50 ticks
   	   mtc0  $t0, $11                # CP0:R11 (Compare Reg.)= $t0
		lw  $v0  s_v0		# restore $v0, $a0, and $at
   		lw  $a0, s_a0
   		jal pyramid	
	b lab4_handler_ret
	
	

lab4_handler_ret:

   		.set noat
   		move $at $k1		# Restore $at
   		.set at
   	
   		mtc0 $0 $13		# Clear Cause register
   	
   		mfc0  $k0 $12		# Set Status register
   		ori   $k0 0x1		# Interrupts enabled
   		mtc0  $k0 $12
   		
   		eret			# exception return

quit:
	li	$v0, 10
	syscall
	