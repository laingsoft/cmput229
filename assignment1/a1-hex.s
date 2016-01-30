#---------------------------------------------------------------
# Assignment:           1
# Due Date:             January 29, 2016
# Name:                 Charles Laing
# Unix ID:              cclaing
# Lecture Section:      B1
# Lab Section:          H02 (Tuesday, 5pm - 7:50pm)
# Teaching Assistant(s):   Vincent Zhang
#---------------------------------------------------------------

#---------------------------------------------------------------
# Purpose - convert an ASCII hexadecimal character to its numerical value
# Entry conditions: a single ASCII character loaded by the first instruction
# in register $t0
#
# Exit conditions: if the character denotes a valid hexadecimal digit
# 	(i.e., ’0’ to ’9’ or ’A’ to ’F’) then register
#	 $t1 should contain its equivalent numerical value
# 	(i.e., 0 to F), or an error code of 0xFF if the ASCII
# 	character does not correspond to a hexadecimal digit
#
# Example: If the first instruction is: li $t0, ’A’
# 	then $t1 should contain decimal 10 upon termination
#
#
#Register Usage
#	$t0 - Loading ascii character
#	$t1 - storing the hex value of the ascii character
#---------------------------------------------------------------
       .text
main:  li	$t0, 'B'		# load an ASCII character in $t0
       blt 	$t0, 0x30, error 	# if (character < ’0’) goto error
       bgt 	$t0, 0x39, atof 	# if (character > ’9’) goto atof
       b 	done 	   		# If the value is between 0 and 9, go to done

#Converts ascii A to F to an integer value
atof:  blt 	$t0, 0x41, error	# if (character < ’A’) goto error
       bgt 	$t0, 0x46, error	# if (character > ’F’) goto error
       sub 	$t1, $t0, 0x37		# map it from 1-16 
       b exit				#branch to exit once complete

done:  
       andi $t1, $t0, 0xf	# keep only the lowest byte in $t1
       b exit			# Branch to exit once complete

error: li	$t1, 0xff		# load the error code

exit:  li 	$v0, 10 # exit		#Load the system code 10 into $v0
       syscall				#exit the program
