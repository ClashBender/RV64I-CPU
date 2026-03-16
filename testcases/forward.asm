# Adding values to reg file
addi x1, x0, 1
addi x2, x0, 2
addi x3, x0, 3
addi x4, x0, 4

add x5, x4, x3  # forwarding from mem to ex (x4) , AND wb to ex (x3) - answer should be x5 = 1
ori x6, x4, 0   # forwarding from wb to ex (x4) - answer should be x6 = x4 = 4
sub x7, x6, x1  # forwarding from mem to ex (x6) - answer should be x7 = x6 - x1 = 3

sd x5, 0(x4)    # NOT a hazard.
ld x8, 0(x4)    
sd x8, 8(x4)    # ld -> sd forwarding

ld x9, 0(x4)
and x10, x9, x4 # load-use data hazard - MUST stall

