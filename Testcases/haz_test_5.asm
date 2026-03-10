# load use STALL test 
addi x5 x0 8
sd x5 0(x0) # mem[0] = 8
ld x6 0(x0) 
or x7 x6 x0 # x7 = 8 if works, otherwise x7 = 0
# dummy
addi x0 x0 0
addi x0 x0 0
addi x0 x0 0