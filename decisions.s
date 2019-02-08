#
# this is the starting file for each of the programming
# problems in Lab-Decisions. It must be run with the exception
# handler added (in Mars, use Settings->Exception Handler. 
#    Navigate to the file exceptions.s in /usr/local/lib )
#
    .data
max:  .word 100
min:  .word -100
Nelems: .word 16
num: .word -100
arr:    .word 10,-321,42,-4,168,-2,46,9,102,-56,-100,16,-43,0,99,-101
arrend:	# DO NOT MOVE THIS LABEL
nlmsg:  .asciiz     "\n"
arrstartmsg: .asciiz "Here is the array at program start:\n"
arrendmsg: .asciiz "Here is the array at program end:\n"
resultmsg: .asciiz  "Here is result:"
    .text
    .globl main
main:
    ### STARTARR
    # this section of code outputs a message, then the contents
    # of the array
    li  $v0,4
    la  $a0,arrstartmsg
    syscall
    la  $t0,arr
    la  $t1,arrend
Larrstartloop:
    bge $t0,$t1,Larrstartend
    lw  $a0,0($t0)
    li  $v0,1
    syscall
    la  $a0,nlmsg
    li  $v0,4
    syscall
    add $t0,$t0,4
    b   Larrstartloop
Larrstartend:
    ### END STARTARR
    # end of the starting 'output the array' section
    #
#
# your code goes here.
# result must be in $t7 when you finish!




    ### ENDARR
    # this section of code outputs a message, then the contents
    # of the array, then the value of result ($t7)
    li  $v0,4
    la  $a0,arrendmsg
    syscall
    la  $t0,arr
    la  $t1,arrend
Larrendloop:
    bge $t0,$t1,Larrendend
    lw  $a0,0($t0)
    li  $v0,1
    syscall
    la  $a0,nlmsg
    li  $v0,4
    syscall
    add $t0,$t0,4
    b   Larrendloop
Larrendend:
    li  $v0,4
    la  $a0,resultmsg
    syscall
    li  $v0,1
    move $a0,$t7
    syscall
    ### END STARTARR
    # end of the ending 'output the array' section
    #
    # last, return
    jr  $ra
