`include "../Modules/Ins_memory/inst.v"
`include "../Modules/ALU/adder64/adder64.v"

module fetch(
    input clk, enable, reset,
    input [63:0] pc_plus_imm,
    input PCSrc,
    output reg [63:0] pc_out, 
    output [63:0] pc_plus_4,
    output [31:0] instr
);    

    reg [63:0] next_pc;

    always @(*) begin
        if (PCSrc == 1'b1)
            next_pc = pc_plus_imm;
        else
            next_pc = pc_plus_4;
    end

    always @ (posedge clk) begin
        if (reset == 1'b1)
            pc_out <= 64'b0;
        else if (enable == 1'b1)
            pc_out <= next_pc;
    end
    
    adder64 add_pc_4(
        .a(pc_out), .b(64'h4),
        .adder_op(1'b0),
        .result(pc_plus_4),
        .cout(),
        .carry_flag(),
        .overflow_flag(),
        .neg_flag()
    );

    instmem instruction_memory(
        .addr(pc_out),
        .instr(instr)
    );
    
endmodule