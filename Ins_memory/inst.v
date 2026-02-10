`timescale 1ns/1ps

`define IMEM_SIZE 4096        // max no. of bytes mentioned

module instmem(
    input  wire        clk,
    input  wire        reset,
    input  wire [63:0] addr,      // pc_out of PC
    output reg  [31:0] inst
);

    reg [7:0]  byte_mem [0:`IMEM_SIZE-1];
    reg [31:0] inst_mem [0:(`IMEM_SIZE/4)-1];

    integer i;
    initial begin
        $readmemh("instructions.txt", byte_mem);

        //  4 bytes → 32-bit instruction
        for (i = 0; i < `IMEM_SIZE/4; i = i + 1) begin
            inst_mem[i] = {
                byte_mem[4*i+3],
                byte_mem[4*i+2],
                byte_mem[4*i+1],
                byte_mem[4*i+0]
            };
        end
    end

    // output access logic
    always @(posedge clk) begin
        if (reset)
            inst <= 32'b0;
        else
            inst <= inst_mem[addr[63:2]];   // word aligned access
    end

endmodule

