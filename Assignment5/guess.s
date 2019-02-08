    .data
min:       .word 1
max:       .word 10
msgguess:   .asciiz "Make a guess.\n"
msgnewline: .asciiz "\n"
msgintro:  .asciiz "guess must be a hexadecimal number between "
msgand:    .asciiz " and "
msgend:    .asciiz "\nEnter your guess (q to quit)\n"
msgnl:     .asciiz "\n"
msgwin:    .asciiz "Got it!"
msghigh:   .asciiz "Guess is too high"
msglow:    .asciiz "Guess is too low"
    .text
    .globl main
main:

	##################
	# YOUR CODE HERE #
	##################
    
    #   building stack frame for main:
    addiu   $sp,$sp,-40
    sw      $ra,36($sp)
    
    #   initializes and runs the random number generator:
    jal     InitRandom
    lw      $a0, min
    lw      $a1, max
    jal     RandomIntRange
    
    #stores the random number correct in $s0
    move    $s0, $v0
    
    
    #	itoax(min, buffer);
    lw      $a0, min
    la      $a1, 16($sp)
    jal     itoax
    
    #	char *prompt = strdup2(msgintro, buffer), stores *promt in $s1;
    la      $a0, msgintro
    la      $a1, 16($sp)
    jal     strdup2
    move    $s1, $v0
    
    #	prompt = strdup2(prompt, msgand);
    move    $a0, $s1
    la      $a1, msgand
    jal     strdup2
    move    $s1, $v0
    
    #	itoax(max, buffer);
    lw      $a0, max
    la      $a1, 16($sp)
    jal     itoax
    
    #	prompt = strdup2(prompt, buffer);
    move    $a0, $s1
    la      $a1, 16($sp)
    jal     strdup2
    move    $s1, $v0
    
    #	prompt = strdup2(prompt,msgend);
    move    $a0, $s1
    la      $a1, msgend
    jal     strdup2
    move    $s1, $v0
    
    
GuessLoop:
    
    #   int guess = GetGuess(prompt, min, max), stores guess in $s3;
    move    $a0, $s1
    lw      $a1, min
    lw      $a2, max
    jal     GetGuess
    move    $s3, $v0
    
    #   if (guess == -1) return;
    li      $t0, -1
    beq     $s3,$t0, LoopEnd
    
    #   if (guess == correct)
    beq     $s3, $s0, YouWin
    
    #   if (guess > correct)
    blt     $s0, $s3, TooHigh
    
    #   if (guess < correct)
    blt     $s3, $s0, TooLow

TooLow:

    #    MessageDialog(msghigh, 1), continue;
    la   $a0, msglow
    li   $a1, 1
    jal  MessageDialog  
    j    GuessLoop


TooHigh:

    #    MessageDialog(msghigh, 1), continue;
    la   $a0, msghigh
    li   $a1, 1
    jal  MessageDialog  
    j    GuessLoop
    
YouWin:
      
    #    MessageDialog(msgwin, 1), return;
    la   $a0, msgwin
    li   $a1, 1
    jal  MessageDialog   
    
LoopDone:
    
    #     Unwind stack:
    lw      $ra,36($sp)
    addiu   $sp,$sp,40
    
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

GetGuess:  

	# preparation for procedure call:
	addiu   $sp,$sp,-40
	sw      $ra,36($sp)
	
	# moves min to 40($sp), max to 44($sp):
        sw   $a1,40($sp)
        sw   $a2,44($sp)
        
MainLoop:
        
        # prepares and calls InputDialogString(question, buffer, 16):
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
        
        
valid:  

	# loads theguess into $t4, if (theguess < min || theguess > max) branch to invalidHex:      
        lw   $t4,32($sp)
        lw   $t0,40($sp)
        lw   $t1,44($sp)
        blt  $t4,$t0,InvalidHex
        bgt  $t4,$t1,InvalidHex
        move $v0, $t4
        j LoopEnd     
	
InvalidPrompt:

        # Invalid prompt runs MessageDialog(invalid, 0);
        la $a0,invalid
        li $a1,0
        jal MessageDialog
        j MainLoop
        
        
InvalidHex:

        # Invalid Hex runs MessageDialog(badrange, 0);      
        la $a0,badrange
        li $a1,0
        jal MessageDialog
        j MainLoop
        
LoopEnd:

        # Unwind Stack:
	lw      $ra,36($sp)
	addiu   $sp,$sp,40
        jr      $ra

###################################
#     OTHER HELPER FUNCTIONS      #
###################################

#
# char * strdup2 (char * str1, char * str2)
# -----
# strdup2 takes two strings, allocates new space big enough to hold 
# of them concatenated (str1 followed by str2), then copies each 
# string to the new space and returns a pointer to the result.
#
# strdup2 assumes neither str1 no str2 is NULL AND that malloc
# returns a valid pointer.
    .text
    .globl  strdup2
strdup2:
    # $ra   at 28($sp)
    # len1  at 24($sp)
    # len2  at 20($sp)
    # new   at 16($sp)
    sub     $sp,$sp,32
    sw      $ra,28($sp)
    
    # save $a0,$a1
    # str1  at 32($sp)
    # str2  at 36($sp)
    sw      $a0,32($sp)
    sw      $a1,36($sp)
    
    # get the lengths of each string 
    jal     strlen
    sw      $v0,24($sp)

    lw      $a0,36($sp)
    jal     strlen
    sw      $v0,20($sp)

    # allocate space for the new concatenated string 
    add     $a0,$v0,1
    lw      $t0,24($sp)
    add     $a0,$a0,$t0
    jal     malloc
    
    sw      $v0,16($sp)

    # copy each to the new area 
    move    $a0,$v0
    lw      $a1,32($sp)
    jal     strcpy

    lw      $a0,16($sp)
    lw      $t0,24($sp)
    add     $a0,$a0,$t0
    lw      $a1,36($sp)
    jal     strcpy

    # return the new string
    lw      $v0,16($sp)
    lw      $ra,28($sp)
    add     $sp,$sp,32
    jr      $ra

################################
# RandomIntRange
################################
    .text
    .globl RandomIntRange
#
# int RandomIntRange(int min, int max)
# -----
# This function returns a random int between
# min and max..
RandomIntRange:
    sub     $sp,$sp,20
    sw      $ra,16($sp)
    sw      $a0,20($sp)
    sw      $a1,24($sp)
    
    # Call random to get a random number
    jal     random
    
    # Adjust that number to be within the desired
    # range
    lw      $t0,20($sp)
    lw      $t1,24($sp)
    addi    $t1,$t1,1
    sub     $t2,$t1,$t0
    divu    $v0,$t2
    mfhi    $t3
    add     $v0,$t0,$t3
    
    lw      $ra,16($sp)
    add     $sp,$sp,20
    jr      $ra

################################
# InitRandom
################################
    .text
    .globl InitRandom
#
# void InitRandom()
# -----
# This function initializes the random
# number generator.
InitRandom:
    sub     $sp,$sp,20
    sw      $ra,16($sp)
    
    # Get the current time
    move    $a0,$zero
    jal     time
    
    # Seed the random number generator
    # with the current time
    move    $a0,$v0
    jal     srandom
    
    lw      $ra,16($sp)
    add     $sp,$sp,20
    jr      $ra

    .include  "./util.s"
