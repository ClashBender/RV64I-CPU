addi x1 x0 3
addi x1 x1 1
and x3 x1 x1 # x3 = 4 if works, otherwise x3 = 3
addi x4 x0 7

addi x0 x0 0
addi x0 x0 0
addi x0 x0 0
addi x0 x0 0


# sd x3 0(x1)
# beq x2 x1 24

# addi x5 x0 2
# addi x6 x0 3
# addi x7 x0 5
# addi x8 x0 7
# addi x9 x0 0

# # Load Use Data Hazard
# ld x10 0(x1) # x9 = 5
# add x11 x10 x2 # x11 = 8, without stall x11 = 3

# Testcases/instructions.asm
