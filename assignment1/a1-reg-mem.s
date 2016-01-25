	.text
main:	lb	$t0, Num1	#Load 6 into register 0
	lb	$t1, Num2 	#load 12 into register 1
	lb	$t2, Num3 	#load 20 into register 2
	add	$t3, $t0, $t1 	#add 6 + 12, and store in register 3
	add	$t3, $t2, $t3 	#add 12+18 and store in register 3
	sb	$t3, Num4     	#store 99 in register 3

	li	$v0, 10       	#Load immediate 10 into $v0
	syscall

	.data
Num1: 	.byte	6		
Num2:	.byte	12
Num3:	.byte	20
Num4:	.byte	99
Str:	.ascii	"ABCD"