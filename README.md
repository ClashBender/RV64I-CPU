# RV64I-CPU

A 64-bit RISC-V CPU implemented in Verilog, supporting both sequential (single-cycle) and pipelined architectures.

## Supported Instructions

| Type | Instructions |
|------|-------------|
| R-type | `add`, `sub`, `and`, `or`, `xor`, `sll`, `srl`, `sra`, `slt`, `sltu` |
| I-type | `addi`, `andi`, `ori`, `xori`, `slli`, `srli`, `srai`, `slti`, `sltiu`, `ld`, `jalr` |
| S-type | `sd` |
| B-type | `beq` |
| J-type | `jal` |

## Repository Structure

```
├── CPU_seq.v / seq_tb.v        # Sequential CPU and testbench
├── CPU_pipe.v / pipe_tb.v      # Pipelined CPU and testbench
├── script.sh                   # Build & run script
├── 1_Fetch/ ... 5-Writeback/   # Pipeline stage modules
├── Modules/                    # Shared components (ALU, Control, RegFile, etc.)
├── Hazards/                    # Hazard detection & forwarding unit
├── Assembler/                  # Custom RV64I assembler (C)
├── Testcases/                  # Assembly test programs
├── logs/                       # Simulation output (register & data memory dumps)
└── Report/                     # LaTeX project reports
```

## Prerequisites

- [Icarus Verilog](http://iverilog.icarus.com/) (`iverilog`, `vvp`)
- GCC (for compiling the assembler)
- [GTKWave](http://gtkwave.sourceforge.net/) (optional, for waveform viewing)
- Bash shell (Git Bash on Windows)

## Usage

### Quick Start

```bash
bash script.sh
```

The script will:
1. Prompt for an assembly file (`.asm` or `.txt`)
2. Assemble it to machine code
3. Ask to run the sequential or pipelined CPU
4. Optionally open GTKWave for waveform analysis

You can also pass the assembly file directly:

```bash
bash script.sh Testcases/simple.asm
```

### Manual Steps

```bash
# 1. Compile and run the assembler
gcc Assembler/assembler.c -o Assembler/asm
./Assembler/asm Testcases/simple.asm -o Testcases/simple.txt

# 2. Compile and simulate
iverilog pipe_tb.v        # or: iverilog seq_tb.v
vvp ./a.out

# 3. View waveforms (optional)
gtkwave pipe_tb.vcd
```

### Output

- `register_file.txt` — Final register state
- `logs/register.txt` — Labeled register dump with cycle count
- `logs/data_memory.txt` — Data memory contents
