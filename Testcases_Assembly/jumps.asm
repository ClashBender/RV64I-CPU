addi x1, x0, 5          # x1 = 5
addi x2, x0, 5          # x2 = 5
addi x3, x0, 3          # x3 = 3
addi x4, x0, 0          # x4 = test counter

beq x1, x2, 12           # Branch forward 8 bytes (skip next 2 instructions)
addi x4, x4, 1          # x4 += 1 (should be skipped)
addi x5, x4, 1          # x4 += 1 (should be skipped)
addi x6, x0, 1          # x5 = 1 (test passed)
addi x7, x0, 1
addi x8, x0, 1