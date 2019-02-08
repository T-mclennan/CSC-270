   .data
inputQuestion:    .asciiz "Input next string (q to quit, empty for result):"
clearBuffer:      .asciiz "Clear buffer? (y/n/q)"
result:           .asciiz "Result string: "
yes:              .byte   'y'
no:               .byte   'n'
    .text
    .globl main
    
    main: 

#  Buffer is from 36($sp)-136($sp):
    addiu   $sp,$sp,-140
    sw      $ra,136($sp)
    sw      $s0,32($sp)
    
#  address of buffer:    
    la      $s1,36($sp)
    
#  address of sb:
    la      $s0,16($sp)
    
#  move address into $a0 to prepare for constructor call:    
    move    $a0,$s0
    jal     Sb$$v

inputLoop:

#  int nb = InputDialogString("Input next string(q to quit, empty for result):", buffer, BUF_MAX);
    la      $a0,inputQuestion
    move    $a1,$s1
    li      $a2,100
    jal     InputDialogString
    
#  if (nb < 0) break;
    bltz    $v0,endInputLoop
    
#  if (nb == 1) 
    li      $t0,1
    beq     $v0,$t0,appendString
    
#  if (nb == 0) {    
    beqz    $v0,printResult
    
#  appending of string onto current string:   
appendString:

#  checks length of current string:
    move    $a0,$s1
    jal     strlen  
    
#  if length is 2 (including nullbyte), use char-append, otherwise use string version:    
    li      $t0,2
    beq     $v0,$t0,appendChar
    
    move    $a0, $s0
    move    $a1, $s1
    jal     Sb$append$C
    j       inputLoop
    
appendChar:

#  appends character onto current string:
    move    $a0, $s0
    move    $a1, $s1
    jal     Sb$append$c
    j       inputLoop
     
printResult:
     
    move    $a0, $s0
    jal     Sb$toString$v
     
    la      $a0,result
    move    $a1,$v0
    jal     MessageDialogString
    
    la      $a0,clearBuffer
    move    $a1,$s1
    li      $a2,100
    jal     InputDialogString
    
    lb      $t0,0($s1)
    lb      $t1,yes
    beq     $t0,$t1,clear
    
    j       inputLoop
    
clear:

    move    $a0, $s0
    jal     Sb$clear$v  
    j       inputLoop     
        

endInputLoop:

    lw      $ra,126($sp)
    lw      $s0,120($sp)
    addiu   $sp,$sp,130
    
    li      $v0, 10
    syscall
    
#Sb::Sb(void) {
    .globl Sb$$v
Sb$$v:
    addiu   $sp,$sp,-20
    sw      $ra,16($sp)
    sw      $a0,20($sp)
#    chunk_nbits=5;
    li      $t0,5
    sw      $t0,0($a0)
#    buffer_size=1<<chunk_nbits;
    li      $t0,1
    lw      $t1,0($a0)
    sllv    $t2,$t0,$t1
    sw      $t2,4($a0)
#    buffer = new char[buffer_size];
    move    $a0,$t2
    jal     malloc
    lw      $a0,20($sp)
    sw      $v0,12($a0)
#    len=0;
    sw      $zero,8($a0)
    lw      $ra,16($sp)
    addiu   $sp,$sp,20
    jr      $ra
#}
#
#void Sb::resize(int additional_bytes_wanted) {
    .globl      Sb$resize$i
Sb$resize$i:
    addiu   $sp,$sp,-28
    sw      $ra,24($sp)
    sw      $s1,20($sp) # used for newbuf
    sw      $s0,16($sp) # used for this
    move    $s0,$a0
#    // need at least additional_bytes_wanted more bytes in buffer to
#    // hold resulting string.
#   size_needed = additional_bytes_wanted + len;
    # $t9 is size_needed
    lw      $t9,8($s0)
    add     $t9,$t9,$a1
#    if (size_needed < buffer_size) return;
    lw      $t2,4($s0)  # buffer_size
    blt     $t9,$t2,.Sb$resize$irtn
#    int size_needed_round = ((size_needed >> chunk_nbits) + 1) << chunk_nbits;
    lw      $t0,0($s0)  # chunk_nbits
    srlv    $t1,$t9,$t0
    addi    $t1,$t1,1
    sllv    $t1,$t1,$t0 # size_needed_round
#    buffer_size=size_needed_round;
    sw      $t1,4($s0)
#    char * newbuf= new char[size_needed_round];
    move    $a0,$t1
    jal     malloc
    move    $s1,$v0
#    strncpy(newbuf,buffer,len);
    move    $a0,$s1
    lw      $a1,12($s0)
    lw      $a2,8($s0)
    jal     strncpy
#    free (buffer);
    lw      $a0,12($s0)
    jal     free
#    buffer=newbuf;
    sw      $s1,12($s0)
#}
.Sb$resize$irtn:
    lw      $s0,16($sp)
    lw      $s1,20($sp)
    lw      $ra,24($sp)
    addiu   $sp,$sp,28
    jr      $ra
#

#void Sb::append(const char *str) {
    .globl      Sb$append$C
    
Sb$append$C:
    addiu   $sp,$sp,-28
    sw      $ra,24($sp)    
    sw      $s1,20($sp)       # used for *str
    sw      $s0,16($sp)       # used for this
    move    $s0,$a0 
    move    $s1,$a1
    
    move    $a0,$a1           # prepare for strlen call:
    jal     strlen            # returns length of *str
    
    move    $a0,$s0           # prepares for SB.resize call:
    move    $a1,$v0           
    jal     Sb$resize$i       # makes sure there is enough space in SB.buffer
    
    lw      $t2,8($a0)        # SB.len 
    lw      $t3,12($a0)       # SB.*buffer
    add     $t3,$t3,$t2       # Finds the end of SB.buffer: adds len to address to find bit offset  
   
    move    $a0,$t3
    move    $a1,$s1
    jal     strcpy

    lw      $a0,12($s0)
    jal     strlen            # checks length of string in SB.buffer
    sw      $v0,8($s0)        # saves that value in SB.len

    lw      $ra,24($sp)       # Unwind Stackframe
    lw      $s1,20($sp)       # used for *str
    lw      $s0,16($sp)       # used for this
    addiu   $sp,$sp,28
    jr      $ra               # return

#void Sb::append(char c) {
    .globl      Sb$append$c
    
Sb$append$c:
    addiu   $sp,$sp,-28
    sw      $ra,24($sp)    
    sb      $s1,20($sp)       # used for char c
    sw      $s0,16($sp)       # used for this
    move    $s0,$a0 
    move    $s1,$a1
    
    move    $a0,$a1           # prepare for strlen call:
    jal     strlen            # returns length of *str
    
    move    $a0,$s0           # prepares for SB.resize call:
    move    $a1,$v0           
    jal     Sb$resize$i       # makes sure there is enough space in SB.buffer
    
    lw      $t2,8($a0)        # SB.len 
    lw      $t3,12($a0)       # SB.*buffer
    add     $t3,$t3,$t2       # Finds the end of SB.buffer: adds len to address to find bit offset  

    sb      $s1,0($t3)        # store the current char
    
    lw      $a0,12($a0)
    jal     strlen            # checks length of string in SB.buffer
    sw      $v0,8($a0)        # saves that value in SB.len

    lw      $ra,24($sp)       # Unwind Stackframe
    lb      $s1,20($sp)       # 
    lw      $s0,16($sp)       # 
    addiu   $sp,$sp,28
    jr      $ra               # return
    
# *char Sb::toString(void) 
    .globl Sb$toString$v
    
Sb$toString$v:
    addiu   $sp,$sp,-28
    sw      $a0,28($sp)       # $a0 used for this, homed for later use
    sw      $ra,24($sp)       
    sw      $s1,20($sp)       # used for *outString
    sw      $s0,16($sp)       # used for SB.len
   
    lw      $s0,8($a0)        # new buffer will be allocated with malloc, SB.len + 1 in length:
    addiu   $a0,$s0,1         
    jal     malloc
    move    $s1,$v0           # *new buffer stored in $s1
    
    move    $a0,$s1           # preparation for strncpy
    lw      $t0,28($sp)
    lw      $a1,12($t0)
    move    $a2,$s0
    
    jal     strncpy
    add     $t1,$v0,$s0       # $t1 = *outString + SB.len: address of null character
    sb      $zero,0($t1)
    
    move    $v0,$s1           # $v0 = *outString

    lw      $ra,24($sp)       # unwind stack       
    lw      $s1,20($sp)      
    lw      $s0,16($sp)      
    addiu   $sp,$sp,28
    jr      $ra

#Sb::clear(void) {
    .globl Sb$clear$v
Sb$clear$v:
 
    sw $zero, 8($a0)
    jr $ra

        .include  "./util.s"
