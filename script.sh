# !/bin/bash
set -e  # Exit on any error

ASM_SRC="Assembler/assembler.c" # where the assembler is
ASM_EXE="Assembler/asm" # where asm.exe is
ASM_INPUT="${1:-$(ls Testcases/*.asm 2>/dev/null | head -1)}" # Take both .asm and .txt inputs from Testcases/
INST_OUT="Testcases/$(basename "${ASM_INPUT%.*}").txt" # Output file in testcases_hex with same name as input but .txt extension

# Step 1: Compile the assembler
echo "[1/2] Assembling to machine code..."
gcc "$ASM_SRC" -o "$ASM_EXE"
./"$ASM_EXE" "$ASM_INPUT" -o "$INST_OUT"

# # Step 2: Compile and run Verilog simulation
echo "[2/2] Running CPU simulation..."
iverilog -o seq.vvp seq_tb.v
vvp seq.vvp

echo ""
echo "Script executed successfully."
