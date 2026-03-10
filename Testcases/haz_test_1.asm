# mem->ex forwarding test
addi x5 x0 5
and x6 x5 x5 # x6 = 5 if works, otherwise x6 = 0
# dummy
addi x0 x0 0
addi x0 x0 0
addi x0 x0 0