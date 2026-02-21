addi x1 x0 2
addi x2 x0 3
addi x3 x0 5
addi x4 x0 7
addi x5 x0 11

# Arithmetic
add x10, x1, x2         # x10 = 5
or x11, x10, x3         # x11 = 5

# store
sd x12 0(x0)           
sd x12 4(x0)            
sd x12 1016(x0)            

# 