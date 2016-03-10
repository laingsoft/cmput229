
# Purpose - convert an ASCII hexadecimal character to its numerical value
# Entry conditions: a single ASCII character loaded by the first instruction
# in register $t0
# Exit conditions: if the character denotes a valid hexadecimal digit
# (i.e., ’0’ to ’9’ or ’A’ to ’F’) then register
# $t1 should contain its equivalent numerical value
# (i.e., 0 to F), or an error code of 0xFF if the ASCII
# character does not correspond to a hexadecimal digit
# Example: If the first instruction is: li $t0, ’A’
# then $t1 should contain decimal 10 upon termination

       .text
main:  li	$t0, '0'		# load an ASCII character in $t0
       blt 	$t0, 0x30, error 	# if (character < ’0’) goto error
       bgt 	$t0, 0x39, atof 	# if (character > ’9’) goto atof
       b 	done 	   		# no, goto done

atof:  blt 	$t0, 0x41, error	# if (character < ’A’) goto error
       bgt 	$t0, 0x46, error	# if (character > ’F’) goto error
       sub 	$t1, $t0, 0x37		# map it from 1-16 
	   b exit

done:  
       andi $t1, $t0, 0xf	# keep only the lowest byte in $t1
       b exit

error: li	$t1, 0xff		# load the error code

exit:  li 	$v0, 10 # exit
       syscall
