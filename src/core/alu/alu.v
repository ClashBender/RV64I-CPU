`ifndef ALU_V
`define ALU_V

`ifdef STANDALONE_ALU
    `include "adder64.v"
    `include "gate64.v"
    `include "shift64.v"
    `include "mux64.v"
`else
    `include "src/core/alu/adder64.v"
    `include "src/core/alu/gate64.v"
    `include "src/core/alu/shift64.v"
    `include "src/core/alu/mux64.v"
`endif

module alu_64_bit(
    input [63:0] rs1, rs2,
    input [3:0] alu_ctrl,
    output [63:0] result,
    output cout,
    output carry_flag,
    output overflow_flag,
    output zero_flag
);

    // add and subtract module (ADD = 0000, SUB = 1000)
    wire [63:0] res_add; 
    wire neg_flag, adder_op;
    or(adder_op, alu_ctrl[3], alu_ctrl[1]); // It'll be subtract for both SUB and SLT/SLTU operations now
    
    adder64 adder_block(
        .a(rs1), .b(rs2),
        .adder_op(adder_op),
        .result(res_add),
        .cout(cout),
        .carry_flag(carry_flag),
        .overflow_flag(overflow_flag),
        .neg_flag(neg_flag) // I'm gonna use this for SLT and SLTU
    );  

    // and, xor, or modules (AND = 0111, OR = 0110, XOR = 0100)
    wire [63:0] res_and, res_xor, res_or;
    gate64 gates_block(
        .a(rs1), .b(rs2), 
        .res_and(res_and), 
        .res_xor(res_xor), 
        .res_or(res_or)
    );

    // shift operations (SLL = 0001, SRL = 0101, SRA = 1101)
    wire [63:0] res_shift;
    barrel_shifter shift_block(
        .a(rs1),
        .b(rs2),
        .lr_flag(alu_ctrl[2]),
        .logic_flag(alu_ctrl[3]),
        .result(res_shift)
    );

    // set less than (SLT = 0010, SLTU = 0011)
    wire [63:0] res_slt, res_sltu;
    wire slt, sltu;

    xor(slt, neg_flag, overflow_flag); // if overflow = 1, sign bit is flipped => neg_flag is flipped
    not(sltu, carry_flag);

    assign res_slt = {63'b0, {slt}};
    assign res_sltu = {63'b0, {sltu}};

    // Final assignment
    mux_3x8 operation(
        .a(res_add), 
        .b(res_shift), 
        .c(res_slt), 
        .d(res_sltu), 
        .e(res_xor), 
        .f(res_shift), 
        .g(res_or), 
        .h(res_and), 
        .sel(alu_ctrl[2:0]),
        .res(result)
        );
    
    // Zero flag
    wire [31:0] naive_zero1;
    wire [15:0] naive_zero2;
    wire [7:0] naive_zero3;
    wire [3:0] naive_zero4;
    wire [1:0] naive_zero5;
    wire not_naive_zero;
    
    genvar i;
    generate 

        for(i = 0; i < 32; i = i + 1)
            or(naive_zero1[i], result[2*i], result[2*i+1]);
        
        for(i = 0; i < 16; i = i + 1)
            or(naive_zero2[i], naive_zero1[2*i], naive_zero1[2*i+1]);
        
        for(i = 0; i < 8; i = i + 1)
            or(naive_zero3[i], naive_zero2[2*i], naive_zero2[2*i+1]);
        
        for(i = 0; i < 4; i = i + 1)
            or(naive_zero4[i], naive_zero3[2*i], naive_zero3[2*i+1]);
        
        for(i = 0; i < 2; i = i + 1)
            or(naive_zero5[i], naive_zero4[2*i], naive_zero4[2*i+1]);

        nor(zero_flag, naive_zero5[0], naive_zero5[1]);

    endgenerate

endmodule

`endif
