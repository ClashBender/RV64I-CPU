addi x1 x0 10           # x1 = 10
jal x2 8                # x2 = PC+4 (return address), jump forward 8 bytes (skip next instruction)
addi x3 x0 99           # SKIPPED - x3 should remain 0
addi x4 x0 20           # x4 = 20 (landed here)
addi x5 x0 10

add x0, x0, x0
add x0, x0, x0
add x0, x0, x0
add x0, x0, x0
