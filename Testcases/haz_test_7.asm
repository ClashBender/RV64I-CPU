# Tests jal instruction and control hazard
addi x5 x0 5
addi x4 x0 2
addi x3 x0 0
beq x5 x4 16    # while loop condition
addi x4 x4 1    # increments x4 by 1
addi x3 x3 1
jal x20 -12      # x20 = 12, PC = PC + 20s
add x6 x5 x4

# dummy
addi x0 x0 0
addi x0 x0 0
addi x0 x0 0
addi x0 x0 0

# Testcases/haz_test_7.asm