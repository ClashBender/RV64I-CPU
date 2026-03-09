`ifndef fetch
`define fetch

`include "../Modules/Ins_memory/inst.v"
`include "../Modules/ALU/adder64/adder64.v"

module fetch(
    input clk, enable, reset,
    input [63:0] pc_tar_E,
    input PCSrc_E,
    output reg [63:0] pc_out_F, 
    output [63:0] pc_plus_4_F,
    output [31:0] instr_F
);    

    reg [63:0] next_pc;

    always @(*) begin
        if (PCSrc_E == 1'b1)
            next_pc = pc_tar_E;
        else
            next_pc = pc_plus_4_F;
    end

    always @ (posedge clk) begin
        if (reset == 1'b1)
            pc_out_F <= 64'b0;
        else if (enable == 1'b1)
            pc_out_F <= next_pc;
    end
    
    adder64 add_pc_4(
        .a(pc_out_F), .b(64'h4),
        .adder_op(1'b0),
        .result(pc_plus_4_F),
        .cout(),
        .carry_flag(),
        .overflow_flag(),
        .neg_flag()
    );

    instmem instr_Fuction_memory(
        .addr(pc_out_F),
        .instr_F(instr_F)
    );
    
endmodule

`endif