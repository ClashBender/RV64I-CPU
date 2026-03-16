addi x1 x0 16           # x1 = 16 (target address)
jalr x2 x1 0            # x2 = PC+4 = 8, jump to x1+0 = 16 (skip next two instructions)
addi x3 x0 99           # SKIPPED
addi x4 x0 99           # SKIPPED
addi x5 x0 42           # x5 = 42 (landed here, address 16)

add x0, x0, 0
add x0, x0, 0
add x0, x0, 0
add x0, x0, 0

# Testcases/jalr.asm