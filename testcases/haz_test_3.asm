# Prioritzing mem->ex over wb->ex test
addi x5 x0 5
addi x5 x5 1 # x5 = 6
and x6 x5 x5 # x6 = 6 if works, otherwise x6 = 5 or x6=0
# dummy
addi x0 x0 0
addi x0 x0 0
addi x0 x0 0
addi x0 x0 0