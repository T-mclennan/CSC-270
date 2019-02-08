    .text
    .globl main
main:
    li  $t0,10
    li  $t2,4
    li  $t3,5
    li  $t1,1
# given $t1 = 1, $t0=10 (at start) and unknown values in $t2 and $t3
    bge $t2,$t3,.Lskip
    add $t0,$t0,$t1
    add $t0,$t0,$t1
    add $t0,$t0,$t1
.Lskip:
    add $t0,$t0,$t1
# if $t2 < $t3, what is the value in $t0 at the end?
# if $t2 > $t3, what is the value in $t0 at the end?
    
