	.data
buffer:		.space	60
prompt:		.asciiz	"input string = '"
comma:		.asciiz "', x = "
newline:	.asciiz "\n"




	.text
	
main:	
	li		$a3, 0xffff0000		#Set up the base address for I/O
	li		$s1, 2
	la		$a2, buffer			#Load the address of our buffer, so we can keep tabs on where we are
	
	#Enable the Keyboard interrupts
	sw		$s1, 0($a3)			#Enable the Keyboard Interrupts
	#add  	$sp, $sp, -8		# allocate frame: $a0, $a1
	  
	# Enable global interrupts
   	li		$s1, 0x0000ff01	       # set IE= 1 (enable interrupts) , EXL= 0
   	mtc0	$s1, $12	           # SR (=R12) = enable bits
	  
	# Start timer
   	   mtc0  $0, $9                  # COUNT = 0
   	   addi  $t0, $0, 1000             # $t0 = 1000 ticks
   	   mtc0  $t0, $11                # CP0:R11 (Compare Reg.)= $t0
	   

	addi	$a1, $sp, 0  
loop: beq $t0, $t0, loop			#Infinite Loop

	.globl	lab4_handler
	
lab4_handler:
	.set noat
	move $k1, $at				#Take in the value from the exception and give it to k1
	.set at

	mfc0 $k0, $13				#Give us the exception bit to work with
	
	srl		$a0, $k0, 11		#Now we shirt right by 11 to figure out WHY the exception happened
	andi	$a0, 0x1			#Was it a Keyboard exception?
	bgtz	$a0, keyboard		#If yes, branch over to the keyboard handler
	
	srl		$a0, $k0, 15		#Wasn't a keyboard exception? Was it a timer?
	andi	$a0, 0x1			#Lets check...
	bgtz	$a0, timer			#If it was, go do the timer stuff

keyboard:
	lb		$t1, 4($a3)			#Take the value of the key
	addi	$sp, $sp, -1		#Push it onto the stack
	sb		$t1, 0($sp)			#Write it in
	b		lab4_handler_ret
		
	

timer:
	#Reset the timer
   	mtc0  $0, $9                  # COUNT = 0
   	addi  $t0, $0, 1000             # $t0 = 1000 ticks
   	mtc0  $t0, $11                # CP0:R11 (Compare Reg.)= $t0
	
	#Every tick of the timer interrupt print the first part of the string
	li	  $s2, 0				#Set up s2 for the next use. 
	la		$a0, prompt			#Print the first part of the prompt
	li		$v0, 4				#set spim to print strings
	syscall						#call
	li		$v0, 11				#Set spim to print characters
	
	
	
numloop:
	beq		$sp, $a1, numgen	#If the stack is empty, exit
	lb		$a0, 0($sp)			#Load the byte from the stack
	addi	$sp, 1				#Pop it from the stack
	add	$s2, $s2, $a0			#create a running sum
	syscall						#call
	b numloop					#Iterate



lab4_handler_ret:
	
	.set noat
	move $at $k1		# Restore $at
	.set at

	mtc0 $0 $13		# Clear Cause register

	mfc0  $k0 $12		# Set Status register
	ori   $k0 0x1		# Interrupts enabled
	mtc0  $k0 $12
	
	eret			# exception return
	
numgen:
	la	$a0, comma
	li	$v0, 4
	syscall
	
	move 	$s4, $s2
	# sll		$s3, $s2, 11
	# xor		$s2, $s2, $s3
	# srl		$s3, $s2, 8
	# xor		$s2, $s2, $s3
	# sll		$s4, $s4, 19
	# xor		$s3, $s2, $s4
	# srl		$s3, $s3, 14
	# and		$s3, 0x63
	li		$s2, 100
	div		$s4, $s2
	mfhi	$s3
	move	$a0, $s3
	jal printp2
	b		lab4_handler_ret
	
printp2:
	addi	$sp, $sp, -8
	sw		$v0, 8($sp)
	
	li		$v0, 1
	syscall
	la 		$a0, newline
	li		$v0, 4
	syscall
	
	lw		$v0, 8($sp)
	addi	$sp, $sp, 8
	
	jr	$ra
	
	
  
  
  
  
exit:
	li		$v0, 10
	syscall
