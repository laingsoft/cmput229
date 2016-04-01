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

str_a1:     .asciiz "pyramid: N="
str_k:	    .asciiz ", k="

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
	#When we're writing the frame, we are going to need to play with the values of a0 and a1, so we need to save them
	#So we can put them on the stack
	  addi $sp, $sp, -12		# allocate frame: $a0, $a1, $ra
	  sw   $a0, 12($sp)		# store $a0= N in caller's frame
	  sw   $a1, 16($sp)		# store $a1= K in caller's frame
	  sw   $ra,  8($sp)		# store $ra in pyramid's frame	

	   # print the frame that starts at $sp + 4
	   la	 $a0, str_a1;  li $v0,4; syscall  # print the string that says pyramid: n= 
	   lw	 $a0, 12($sp);  li $v0 1; syscall  # print value N
	   
	   la	 $a0, str_k;   li $v0,4; syscall  # print k string
	   lw    $a0, 16($sp); li $v0,1; syscall  #print value of K

	   jal   print_NL      	      	 	  # print NL
	   
	   lw    $ra, 8($sp)			  # restore $ra
	   lw   $a0, 12($sp)		# store $a0= N in caller's frame
	   lw   $a1, 16($sp)		# store $a1= K in caller's frame
	   addi  $sp, $sp, 12			  # release frame
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
#-------------------------------
# Handles The Interrupt sequence. 
# at = Exception code, a0 = used to hold exception cause bit
# t2 = Used to hold key code from keyboard. 
#-------------------------------
lab4_handler:
	.set noat
	move $k1, $at
	.set at
	sw $v0, s_v0				#Store the value of v0 so we don't mess anything up
	sw $a0, s_a0				#Store the value of a0 so that we don't mess anything up
	
	#Next we need to get the interrupt cause bit from the exception register, which is R13 on cp0
	mfc0 $k0, $13	#Grab $13 from cp0 so that we can use it
	
	srl		$a0, $k0, 11	#If the cause was because of the keyboard, we need to branch to keyboard.
	andi	$a0, 0x1		#Do an and, if the value is 1, then we know that the keyboard was the cause of the exception
	bgtz	$a0, keyboard	#Branch
	
	srl		$a0, $k0, 15	#If the cause was because of the Timer, we need to branch to the timer
	andi	$a0, 0x1		#So we check and see if the value was 15, which is the timer interrupt
	bgtz	$a0, timer		#Branch
#-------------------------------
# Deals with the keyboard input
# Uses $t2 to store the keycode
#-------------------------------
keyboard:
	lw $t2, 0xffff0004			#Grab the value of the key that was pressed
	#Next we handle the keycodes by checking them against the hex values of the keys we want. 
	beq $t2,0x69, incri 		#Handle I by incrementing the value of N
	beq $t2, 0x64, decri 		#Handle D by decrementing the value of N
	beq $t2, 0x72,	incrk		#Handle R by Incrementing the value of K
	beq $t2, 0x6c	decrk		#Handle L by decrementing the value of K
	beq $t2, 0x71	quit		#Handle Q by jumping to the quit subroutine
	b	finish					#If they keycode was not one of the above keys, we need to ignore it
#-------------------------------
#Increment the value of N
#-------------------------------
incri:	lw  $t0, N				#Load N From the label in data
		la	$t1, N				#load the address of N from the label
		beq $t0, 20, lab4_handler_ret	#If N> 20, ignore the interrupt
		addi $t0, 1				#Increment N
		sw	$t0, 0($t1)			#Save it back to the data storage
		b lab4_handler_ret		#Branch to exit the interrupt
#-------------------------------
#Decrement the value of N
#-------------------------------
decri:	lw  $t0, N				#Load N from the label in Data
		la	$t1, N				#Load the address so we can save
		beq $t0, 1, lab4_handler_ret	#If the value < 0, ignore the interrupt
		addi $t0, -1			#Decrement N
		sw	$t0, 0($t1)			#Save it back to data
		b lab4_handler_ret		# Exit the interrupt
#-------------------------------
#Increment the value of K to shift right
#-------------------------------
incrk:	lw  $t0, K				#Load K
		la	$t1, K				#Load Address of K
		beq	$t0, 40, lab4_handler_ret	#If K > 40, Ignore
		addi $t0, 1				#Increment K
		sw	$t0, 0($t1)			#Save back to data
		b lab4_handler_ret		#Exi the interrupt
#-------------------------------
#Decrement the value of K to shift left
#-------------------------------
decrk:	lw  $t0, K				#Load K
		la	$t1, K				#Load Address of K
		beq $t0, 0, lab4_handler_ret	#If the value <0, ignore
		addi $t0, -1			#Decrement
		sw	$t0, 0($t1)			#Save to data
		b lab4_handler_ret		#Branch to quit the interrupt
#-------------------------------
# Jump out of the interrupt handler
#-------------------------------
finish:
	b lab4_handler_ret

#-------------------------------
# Reset the timer when a timer interrupt is fired. 
# Draws the pyramid at a specified time interval
#-------------------------------
timer:
   	   mtc0  $0, $9                 # COUNT = 0
   	   addi  $t0, $0, 50            # $t0 = 50 ticks
   	   mtc0  $t0, $11               # CP0:R11 (Compare Reg.)= $t0
		lw  $v0  s_v0				# restore $v0, $a0, and $at
   		lw  $a0, s_a0
		jal write_frame				#Draw the frame that we wanted at the beginning
   		jal pyramid					#Draw the pyramid with the values of N and K that we have
	b lab4_handler_ret				#Finish the interrupt, and continue the loop
	
	
#-------------------------------
# Returns back to the infinite loop. 
# Resets the values of $v0 and $a0 to the ones we stored
# resets the status register, and enables interrupts again.
# Then returns
#-------------------------------
lab4_handler_ret:

   		.set noat
   		move $at $k1		# Restore $at
   		.set at
   	
   		mtc0 $0 $13		# Clear Cause register
   	
   		mfc0  $k0 $12		# Set Status register back to normal
   		ori   $k0 0x1		# make sure we enable  
   		mtc0  $k0 $12
   		
   		eret			# exception return

quit:
	li	$v0, 10			#Exit the program with the syscall
	syscall				#Exit
	