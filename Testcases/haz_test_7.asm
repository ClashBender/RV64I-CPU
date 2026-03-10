# Tests jal instruction and control hazard
addi x5 x0 5
addi x4 x0 2
beq x5 x4 12 # while loop condition
addi x4 x0 1 # increments x4 by 1
jal x20 -8 # x20 = 12, PC = PC + 20
add x6 x5 x4

# dummy
addi x0 x0 0
addi x0 x0 0
addi x0 x0 0