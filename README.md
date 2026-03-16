# Coffee Processing Unit - RV64I CPU

![Pipelined Processor](docs/report/figures/pipelined_processor.png)

Figure: Five-stage pipelined RV64I processor datapath used in this project.

This repository contains a single-core RV64I CPU implemented in Verilog, with:

- A single-cycle (sequential) implementation
- A five-stage pipelined implementation
- Hazard detection and forwarding support
- A custom assembler written in C
- A run script that assembles and simulates in one flow

## Supported Instructions

| Type   | Instructions                                                                         |
| ------ | ------------------------------------------------------------------------------------ |
| R-type | `add`, `sub`, `and`, `or`, `xor`, `sll`, `srl`, `sra`, `slt`, `sltu`                 |
| I-type | `addi`, `andi`, `ori`, `xori`, `slli`, `srli`, `srai`, `slti`, `sltiu`, `ld`, `jalr` |
| S-type | `sd`                                                                                 |
| B-type | `beq`                                                                                |
| J-type | `jal`                                                                                |
## Prerequisites

- [Icarus Verilog](http://iverilog.icarus.com/) (`iverilog`, `vvp`)
- GCC (for compiling the assembler)
- Bash
- [GTKWave](http://gtkwave.sourceforge.net/) (optional)

## Usage

### Using `script.sh`
To streamline the process of running assembly code, a **script** has been provided. Before running the script, make sure to store your assembly code in the testcases/ folder.
If you are running it for the first time, make it an executable and start it:

```bash
chmod +x script.sh
./script.sh
```

At the prompt, you can enter either:

- A bare filename like `simple.asm` (auto-resolved to `testcases/simple.asm`)
- A full/relative path like `testcases/haz_test_4.asm`

After that, the script will ask you to choose between the sequential or the pipelined processor - do so according to which processor needs to be run.

(A quick note before that, make a folder called 'logs' so that the testbench can write register values and data memory values to their respective files.)

To run the script again after this, one can just use:

```bash
bash script.sh
```

Examples:

```bash
bash script.sh simple.asm
bash script.sh testcases/simple.asm
```

### Manually running without `script.sh`

```bash
# Assemble
gcc tools/assembler/assembler.c -o tools/assembler/asm
./tools/assembler/asm testcases/simple.asm -o testcases/simple.txt

# Sequential
iverilog src/arch/seq_tb.v
vvp ./a.out

# Pipelined
iverilog src/arch/pipe_tb.v
vvp ./a.out
```

## Output Files

- `logs/register.txt`: Register dump with cycle information
- `logs/data_memory.txt`: Data memory dump
- `pipe_tb.vcd` / `seq_tb.vcd`: Waveforms for GTKWave


## Repository Structure

```text
|
├── script.sh
├── src/
│   ├── arch/                  # CPU top modules and testbenches
│   │   ├── CPU_seq.v
│   │   ├── CPU_pipe.v
│   │   ├── seq_tb.v
│   │   └── pipe_tb.v
│   ├── core/                  # ALU, control, memory, regfile, PC, immediate
│   ├── stages/                # 5 pipeline stages
│   ├── hazards/               # hazard detection / forwarding
│   └── extensions/            # optional extensions
├── tools/
│   └── assembler/             # assembler.c and built asm binary
├── testcases/                 # .asm programs and generated .txt machine code
├── logs/                      # simulation output dumps
└── docs/report/               # LaTeX reports and figures
```

## References

- John L. Hennessy and David A. Patterson, *Computer Architecture: A Quantitative Approach*, Elsevier, 2011.
- Sarah Harris and David Harris, *Digital Design and Computer Architecture, RISC-V Edition*, Morgan Kaufmann, 2021.
- David A. Patterson and John L. Hennessy, *Computer Organization and Design*, Morgan Kaufmann, 2022.
- DownToTheWires, *RISC-V Intro and R-Type ALU Instructions*, 2025. URL: https://www.youtube.com/@DowntotheWires (Accessed: 2025).
