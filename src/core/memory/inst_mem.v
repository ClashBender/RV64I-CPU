`ifndef INST_V
`define INST_V

`timescale 1ns/1ps
`define IMEM_SIZE 4096        // About 4 KiB of memory, so 512 instructions max.

module instmem(
    input wire [63:0] addr,
    output [31:0] instr
);

    reg [7:0]  byte_mem [0:`IMEM_SIZE-1];
    reg [31:0] inst_mem [0:(`IMEM_SIZE/4)-1];
    
    // output access logic
    assign instr = inst_mem[addr[63:2]];

endmodule

`endif
