# branch flush test (predict not taken, actual taken)
# Expected: x7 = 0, x8=1

addi x5 x0 4      # x5 = 4
addi x6 x0 4      # x6 = 4
addi x0 x0 0
addi x0 x0 0  

beq x5 x6 8      
addi x7 x7 1      # wrong path: must be flushed, so x7 should stay 0
addi x8 x8 1      # branch target: should execute, so x8 becomes 1

# dummy 
addi x0 x0 0
addi x0 x0 0
addi x0 x0 0

