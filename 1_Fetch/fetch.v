`include "PC/pc.v"
`include "Ins_memory/inst.v"
`include "ALU/adder64/adder64.v"

module fetch(
    input clk, reset,
    input [63:0] pc_plus_imm,
    input PCSrc,
    output [63:0] pc_out,
    output [31:0] instr
);

    wire [63:0] pc_in, pc_plus_4;

    adder64 add_pc_4(
        .a(pc_out), .b(64'h4),
        .adder_op(1'b0),
        .result(pc_plus_4),
        .cout(),
        .carry_flag(),
        .overflow_flag(),
        .neg_flag()
    );

    assign pc_in = (PCSrc) ? pc_plus_imm : pc_plus_4;

    pc program_counter(
        .clk(clk), 
        .reset(reset),
        .pc_in(pc_in),
        .pc_out(pc_out)
    );

    instmem instruction_memory(
        .reset(reset),
        .addr(pc_out),
        .instr(instr)
    );
    
endmodule