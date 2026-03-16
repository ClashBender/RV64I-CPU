`ifndef fetch
`define fetch

`include "src/core/memory/inst_mem.v"

module fetch(
    input clk, enable, reset,
    input [63:0] pc_tar_E,
    input PCSrc_E,
    output reg [63:0] pc_out_F, 
    output [63:0] pc_plus_4_F,
    output [31:0] instr_F
);    

    wire [63:0] next_pc;
    assign next_pc = (PCSrc_E) ? pc_tar_E : pc_plus_4_F;

    // buffer
    always @ (posedge clk) begin
        if (reset == 1'b1)
            pc_out_F <= 64'b0;
        else if (enable == 1'b1)
            pc_out_F <= next_pc;
    end
    
    assign pc_plus_4_F = pc_out_F + 64'd4;

    instmem instr_memory(
        .addr(pc_out_F),
        .instr(instr_F)
    );
    
endmodule

`endif
