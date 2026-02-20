#!/bin/bash
set -e  # Exit on any error

ASM_SRC="Assembler/assembler.c"
ASM_EXE="Assembler/asm"
ASM_INPUT="${1:-$(ls Testcases/*.asm Testcases/*.txt 2>/dev/null | head -1)}"
INST_OUT="Ins_memory/instructions.txt"  # CHANGE THIS DIRECTORY LATER IF INITIALIZING INSTRUCTION MEMORY ELSEWHERE

# Step 1: Compile the assembler
echo "[1/2] Assembling to machine code..."
gcc "$ASM_SRC" -o "$ASM_EXE"
./"$ASM_EXE" "$ASM_INPUT" -o "$INST_OUT"
echo "      Done -> $INST_OUT"

# # Step 2: Compile and run Verilog simulation
# echo "[2/2] Running CPU simulation..."
# iverilog -o cpu.vvp cpu_tb.v
# vvp cpu.vvp

echo ""
echo "Script executed successfully."
