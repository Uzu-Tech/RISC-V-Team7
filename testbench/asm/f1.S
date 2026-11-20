.text
.globl main

.equ STEP_UNITS, 8          
.equ UNIT_LOOPS, 64       # need to tune this value

main:
    li t2, 255            # all lights on
    li t5, UNIT_LOOPS
    li s1, 7              # non zero seed  

s0:
    li a0, 0      # a0 is current state

next_light:                        
    li t0, STEP_UNITS       
    jal  ra, delay                  # jumps to delay block
    add  t4, a0, a0         
    addi a0, t4, 1
    bne  a0, t2, next_light         # keep looping until reach S8

s8:
    srli t3, s1, 6
    srli t4, s1, 2
    xor  t3, t3, t4
    andi t3, t3, 1
    slli s1, s1, 1
    andi s1, s1, 127
    add  s1, s1, t3
    mv   t0, s1
    jal  ra, delay
    j    s0

delay:
    mv   t1, t5             # copies UNIT_LOOPS over
delay_unit:
    addi t1, t1, -1         
    bnez t1, delay_unit
    addi t0, t0, -1
    bnez t0, delay          
    ret
