#
# this program performs a number of bit operations on the 32-bit word stored
# in the variable number displaying the result of each.
# the manipulations you are supposed to perform are numbered and
# the manipulations given in RTL
# After each manipulation the result is output in hexadecimal.
#
# you should code each manipulation and set number to various bit patterns
# for testing.
#
# at the beginning of each new manipulation, number is loaded into $t0.
# at the end of each manipulation, $t0 is output in hexadecimal with a
# banner indicating what the manipulation did.
#
# the program starts by outputting number in hexadecimal
#
    .data
# MODIFY number HERE
number: .word 0x01234567
man0: .asciiz "\n\nHere is number: "
man1: .asciiz "\n\nThis result should be 1 if number is negative, 0 otherwise: "
man2: .asciiz "\n\nThe complement of number is: "
man3: .asciiz "\n\nnumber after swapping halves is: "
man4: .asciiz "\n\nnumber after swapping bytes is: "
man5: .asciiz "\n\nHere is number after deleting all the leading zeroes: "
man6: .asciiz "\n\nthe bits 16-23 extracted from number are: "
man7: .asciiz "\n\nnumber should have the bits 10110110 in positions 4-11: "
man8: .asciiz "\n\nnumber below has bits 26-29, 16-19 and 2-5 set to 0: "
man9: .asciiz "\n\nnumber below has bits 28-31, 16-19 and 2-4 set to 1: "

    .text
    .globl main
main:
    lw   $t0, number
# first, just output number with a banner
    li   $v0,4
    la   $a0,man0
    syscall
    move  $a0,$t0
    li    $v0,34
    syscall
### ENTER your CUSTOM MANIPULATIONS HERE
### make sure the result is in $t0 at the end
### of your code sequence

# 1. output 1 if number is negative, 0 otherwise
    lw  $t0,number
    srl $t0, $t0, 31
    # your code goes here

    # this code will output the result, which must be in $t0
    li   $v0,4
    la   $a0,man1
    syscall
    move  $a0,$t0
    li    $v0,34
    syscall


# 2. output the bitwise complement of number
    lw  $t0,number
    not $t0, $t0
    add $t0, $t0, 0x1
    # your code goes here
    

    # this code will output the result, which must be in $t0
    li   $v0,4
    la   $a0,man2
    syscall
    move  $a0,$t0
    li    $v0,34
    syscall


# 3. swap halves of number: 
#   $t0(31:16) <- number(15:0); 
#   $t0(15:0) <- number(31:16); 
#
    lw  $t0,number
    # your code goes here

    srl $t1, $t0, 16
    sll $t2, $t0, 16
    or  $t0, $t1, $t2

    # this code will output the results, which must be in $t0
    li   $v0,4
    la   $a0,man3
    syscall
    move  $a0,$t0
    li    $v0,34
    syscall


# 4. swap bytes of number:
#   if the bytes of number are in the order abcd
#   you should set $t0 to the order dcba
#   NOTE: this isn't conceptually difficult, but it takes 
#   about 10 instructions!
#
    lw  $t0,number
    # your code goes here
    sll $t1, $t0, 28
    and $t2, $t0, 0x000000f0
    sll $t2, $t2, 20
    or  $t0, $t1, $t2
    

    # this code will output the results, which must be in $t0
    li   $v0,4
    la   $a0,man4
    syscall
    move  $a0,$t0
    li    $v0,34
    syscall


# 5. $t0 should be set to the value of number after deleting
#   (shifting off) any leading zero bits.
#    THIS IS A DIFFICULT ONE. IF YOU GET STUCK, GO ON
#   Example: if number is 0x0ffff000, $t0 should be set to
#    0xffff0000 (hint: see the 'count leading zeros' 
#    and 'shift left variable' instructions.)
    lw  $t0,number
    # your code goes here
    
    move $t1, $zero
    li $t2, 0xf0000000
    top:
    and   $t3, $t2, $t0
    sra  $t2, $t2, 4
    beqz  $t3, loop
    j end
    loop:
    sll  $t0, $t0, 4
    j top
    end:
    
    # this code will output the results, which must be in $t0
    li   $v0,4
    la   $a0,man5
    syscall
    move  $a0,$t0
    li    $v0,34
    syscall


# 6. extract the bits in positions 16-23 and display the result
#   $t0 = 0
#   $t0(7:0) <- number(23:16)
    lw  $t0,number
    # your code goes here
    li $t1, 0x007f0000
    and $t1, $t1, $t0
    srl $t0, $t1, 16
    # this code will output the results, which must be in $t0
    li   $v0,4
    la   $a0,man6
    syscall
    move  $a0,$t0
    li    $v0,34
    syscall


# 7. $t0 should have bit positions 4-11 set to 10110110, and the rest
#  of the bits undisturbed
#   $t0 = number
#   $t0(11:4) <- 10110110
    lw  $t0,number
    # your code goes here

    # this code will output the results, which must be in $t0
    li   $v0,4
    la   $a0,man7
    syscall
    move  $a0,$t0
    li    $v0,34
    syscall


# 8. $t0 should be number with bits 26-29, 16-19 and 2-5 set to zero
#    and the rest of the bits undisturbed
#   $t0 = number
#   $t0(29:26) <- 0  ## you can do all three of these in a single instruction
#   $t0(19:16) <- 0
#   $t0(5:2) <- 0
    lw  $t0,number
    # your code goes here

    # this code will output the results, which must be in $t0
    li   $v0,4
    la   $a0,man8
    syscall
    move  $a0,$t0
    li    $v0,34
    syscall


# 9. $t0 should be number with bits 28-31, 16-19 and 2-4 set to one
#   $t0 = number
## you can do all three of these in a single instruction
#   $t0(31:28) <- 1111
#   $t0(16-19) <- 1111
#   $t0(4:2) <- 111
    lw  $t0,number
    # your code goes here

    # this code will output the results, which must be in $t0
    li   $v0,4
    la   $a0,man9
    syscall
    move  $a0,$t0
    li    $v0,34
    syscall

# now exit gracefully
    li  $v0,10
    syscall


### END of CUSTOM MANIPULATIONS section

# return from main()
    jr  $ra


