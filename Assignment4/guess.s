#######################
# guess.s
# -------
# This program asks the user to enter a guess. It
# reprompts if the user's entry is either an invalid
# hexadecimal number or a valid hexadecimal number
# that is outside the range specified in the program
# by min and max.
#
	.data
min:        .word   1
max:        .word   10
msgguess:   .asciiz "Make a guess.\n"
msgnewline: .asciiz "\n"
	.text
	.globl main
main:
	# Make space for arguments and saved return address
	subi  $sp,$sp,20
	sw    $ra,16($sp)
    # Get the guess
    la    $a0,msgguess
    lw    $a1,min
    lw    $a2,max
    jal   GetGuess
    
    # Print the guess
    move  $a0,$v0
    jal   PrintInteger
    
    # Print a newline character
    la    $a0,msgnewline
    jal   PrintString
    
    # Return
    lw    $ra,16($sp)
    addiu $sp,$sp,20
    
    li $v0, 10
    syscall
    
################################
# GetGuess
################################

    .data
invalid:    .asciiz "Not a valid hexadecimal number"
badrange:   .asciiz "Guess not in range"
    .text
    .globl  GetGuess
# 
# C code:
#
# int GetGuess(char * question, int min, int max)
# {
#     // Local variables
#     int theguess;      // Store this on the stack
#     int status;        // You can just keep this one in a register
#     char buffer[16];   // This is 16 contiguous bytes on the stack
#
#     // Loop
#     while (true)
#     {
#         // Print prompt, get string (NOTE: You must pass the
#         // address of the beginning of the character array
#         // buffer as the second argument!)
#         status = InputDialogString(question, buffer, 16);
#         if (status == -1) return status;
#
#         // Ok, we successfully got a string. Now, give it
#         // to axtoi, which, if successful, will put the
#         // int equivalent in theguess. 
#         //
#         // Here, you must pass the address of theguess as
#         // the first argument, and the address of the
#         // beginning of buffer as the second argument.
#         status = axtoi(&theguess, buffer);
#         if (status != 1)
#         {
#             MessageDialog(invalid, 0);  // invalid is a global
#             continue;
#         }
#
#         // Now we know we got a valid hexadecimal number, and the
#         // int equivalent is in theguess. Check it against min and
#         // max to make sure it's in the right range.
#         if (theguess < min || theguess > max)
#         {
#             MessageDialog(badrange, 0); // badrange is a global
#             continue;
#         }
#
#         return theguess;
#     }
# }
#     
#
GetGuess:
    # stack frame must contain $ra (4 bytes)
    # plus room for theguess (int) (4 bytes)
    # plus room for a 16-byte string
    # plus room for arguments (16)
    # total: 40 bytes
    #  16 byte buffer is at 16($sp)
    #  theguess is at 32($sp)
    #

	#######################
	# YOUR CODE HERE      #
	#######################
	
	# preparation for procedure call:
	addiu   $sp,$sp,-40
	sw      $ra,36($sp)
	
	# moves min to 40($sp), max to 44($sp):
        sw   $a1,40($sp)
        sw   $a2,44($sp)
        
MainLoop:
        
        #prepares and calls InputDialogString(question, buffer, 16):
        la   $a0,msgguess
        add  $a1,$sp,16
        li   $a2, 16
        jal InputDialogString
        
        # moves status to $t2
        # if (status == -1) branch to invalidPrompt:
        move $t3, $v0
        li   $t2, -1
        beq  $t3,$t2, InvalidPrompt
        
        # prepares and calls axtoi(&theguess, buffer):
        add $a0,$sp,32
        la $a1,16($sp)
        jal axtoi 
        
        # if (status == -1) branch to invalidPrompt:
        li   $t2,1
        beq  $v0,$t2,valid
        j InvalidPrompt
        
        #loads theguess into $t4, if (theguess < min || theguess > max) branch to invalidHex:
        
valid:        
        lw   $t4,32($sp)
        lw   $t0,40($sp)
        lw   $t1,44($sp)
        blt  $t4,$t0,InvalidHex
        bgt  $t4,$t1,InvalidHex
        move $v0, $t4
        j LoopEnd
        
        
	
	#  Invalid prompt runs MessageDialog(invalid, 0);
	
InvalidPrompt:
        
        la $a0,invalid
        li $a1,0
        jal MessageDialog
        j MainLoop
        
        #  Invalid Hex runs MessageDialog(badrange, 0);
        
InvalidHex:
        
        la $a0,badrange
        li $a1,0
        jal MessageDialog
        j MainLoop
        
LoopEnd:


        #Unwind Stack:
   
	lw      $ra,36($sp)
	addiu   $sp,$sp,40


    jr      $ra
    
    .include  "util.s"
