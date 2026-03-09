# !/bin/bash
set -e

ASM_SRC="Assembler/assembler.c"     # where the assembler is
ASM_EXE="Assembler/asm"             # where asm.exe is
EXIT_MSG="Exiting script."

# Function to quit if q is pressed in console input.
read_or_quit() {
    
	local __var_name="$1"
	local __prompt="$2"
	local __input

	read -r -p "$__prompt" __input
	case "$__input" in
		q|Q)
			echo "$EXIT_MSG"
			exit 0
			;;
	esac

	printf -v "$__var_name" '%s' "$__input"
}

# Asking console input for filename
ASM_INPUT="$1"
while true; do
	if [ -z "$ASM_INPUT" ]; then
		read_or_quit ASM_INPUT "Enter input file (.asm/.txt): "
	fi

	case "$ASM_INPUT" in
		*.asm|*.txt)
			if [ -f "$ASM_INPUT" ]; then
				break
			else
				echo "File not found: $ASM_INPUT"
			fi
			;;
		*)
			echo "Invalid file type. Please provide a .asm or .txt file, or press q to quit."
			;;
	esac

	ASM_INPUT=""
done

# Output file destination and name
INST_OUT="Testcases/$(basename "${ASM_INPUT%.*}").txt" 

# Step 1: Assembling the code
echo "[1/2] Assembling to machine code..."
gcc "$ASM_SRC" -o "$ASM_EXE"
./"$ASM_EXE" "$ASM_INPUT" -o "$INST_OUT"

# Step 2: Selecting and running our CPU :)
while true; do
	echo "[2/2] Choose CPU simulation mode:"
	echo "  1) Sequential"
	echo "  2) Pipelined"
	read_or_quit cpu_choice "Enter choice (1/2): "

	case "$cpu_choice" in
		1)
			echo "Running sequential CPU simulation..."
			iverilog seq_tb.v
			vvp ./a.out
			break
			;;
		2)
			echo "Running pipelined CPU simulation..."
			iverilog pipe_tb.v
			vvp ./a.out
			break
			;;
		*)
			echo "Invalid choice. Enter 1 or 2, or press q to quit."
			;;
	esac
done

echo ""
echo "Script executed successfully."
