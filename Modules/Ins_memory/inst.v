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

    // // Initializing instruction memory
    // integer i;
    // initial begin

    //     $readmemh("instructions.txt", byte_mem);

    //     for (i = 0; i < `IMEM_SIZE/4; i = i + 1) begin
    //         inst_mem[i] = {
    //             byte_mem[4*i],
    //             byte_mem[4*i+1],
    //             byte_mem[4*i+2],
    //             byte_mem[4*i+3]
    //         };
    //     end
    // end

    // output access logic
    assign instr = inst_mem[addr[63:2]];

endmodule

`endif
