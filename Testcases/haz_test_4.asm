# wb->mem forwarding test (bonus case)
addi x5 x0 8
sd x5 0(x0) # mem[0] = 8
ld x6 0(x0) # x6 = 8 if works, otherwise x6 = 0
# dummy
addi x0 x0 0
addi x0 x0 0
addi x0 x0 0