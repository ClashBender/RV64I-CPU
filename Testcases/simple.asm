addi x1 x0 2
addi x2 x0 3
addi x3 x0 5
addi x4 x0 7
addi x5 x0 11

# Arithmetic
add x10, x5, x5         # x10 = 22
addi x11, x10, 1019         # x11 = 1041 

# store          
sd x11 0(x0)            
sd x10 1016(x0)            
# load
ld x12 1016(x0)             # x12 = 5