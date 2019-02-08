#
# substitute.s - substitute one character for another in a string
#
    .data
string: .space 80
orig:   .space 1
new:    .space 1
sprompt: .asciiz    "Enter string:"
oprompt: .asciiz    "Enter character you want to replace:"
nprompt: .asciiz    "Enter replacement character:"
rprompt: .asciiz    "The string with replacements: "
cprompt: .asciiz    "Number of replacements: "

    .text
    .globl  main
main:
    # get string
    la      $a0,sprompt
    la      $a1,string
    li      $a2,80
    li      $v0,54
    syscall
    # get original character
    # since there is no 'inputdialogchar' syscall, use an inputdialogstring
    # syscall. This will read a string but we will just use the first character
    la      $a0,oprompt
    la      $a1,orig
    li      $a2,4
    li      $v0,54
    syscall
    la      $a0,nprompt
    la      $a1,new
    li      $a2,4
    li      $v0,54
    syscall
#
# now we are ready to do the real work of substituting every instance of
# 'orig' with 'new' in 'string'
# HINT: before you start, initialize the following registers:
# a0 = address of the string
# a1 = char to look for
# a2 = char to replace with
# a3 = count of replacements (initialize to zero)
# Have fun!
#
#
#    int i,count=0;
#    for (i=0;string[i]!=0;i++) 
#        if (string[i] == orig) { 
#            string[i]=new;
#            count++;
#        }
#
# INSERT YOUR CODE HERE.  Make sure the number of replacements
# gets stored in $a3.
#
    # initializes string ($a0), orig ($a1), and new ($a2)
    la  $a0, string
    lb  $a1, orig
    lb  $a2, new
    
    # initializes i ($t0) and count ($a3) to zero
    li  $t0, 0
    li  $a3, 0

    #begin loop:
    loop:
    
    # $t1 = string[i]
    add $t3, $t0, $a0
    lb $t1, ($t3)
    
    # if string[i] = 0, jump to end:
    beqz $t1, end

    # if (string[i] - orig) = 0, jump to change:
    subu $t2, $t1, $a1
    beqz $t2, change
    
    # else jump to iterate, which performs i++ and loops to top:
    j iterate
    
    change:
    
    # string[i] = new, then count++ 
    sb  $a2, ($t3)
    addiu $a3, $a3, 1
    
    iterate:
    
    # i++
    addiu $t0, $t0, 1
    
    j loop
    
    end:
    
    
    
    
    
    
    # this code will output the string.  now, it will be the string entered.
    # once you've added your code, you should see the string with replacements
    li   $v0,4
    la   $a0,rprompt
    syscall
    
    li   $v0, 4       
    la   $a0,string
    syscall
    
    # this code will output the count of replacements, 
    # which must be stored in $a3    
    li   $v0, 4
    la   $a0,cprompt
    syscall  
    
    li   $v0, 1       
    move $a0, $a3
    syscall
    
