`timescale 1ns/1ps
`define IMEM_SIZE 4096        // About 4 KiB of memory, so 512 instructions max.

module instmem(
    input  wire        clk,
    input  wire        reset,
    input  wire [63:0] pc_curr,
    output reg  [31:0] inst
);

    reg [7:0]  byte_mem [0:`IMEM_SIZE-1];
    reg [31:0] inst_mem [0:(`IMEM_SIZE/4)-1];

    // Initializing instruction memory
    integer i;
    initial begin
        $readmemh("instructions.txt", byte_mem);

        for (i = 0; i < `IMEM_SIZE/4; i = i + 1) begin
            inst_mem[i] = {
                byte_mem[4*i+3],
                byte_mem[4*i+2],
                byte_mem[4*i+1],
                byte_mem[4*i]
            };
        end
    end

    // output access logic
    always @(posedge clk) begin
        if (reset)
            inst <= 32'b0;
        else
            inst <= inst_mem[pc_curr[63:2]];   // word aligned access
    end

endmodule

