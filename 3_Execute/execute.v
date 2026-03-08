`ifndef execute
`define execute 

`include "../Modules/ALU/alu.v"
`include "../Modules/ALU/adder64/adder64.v"

module execute(
    // general signals
    input clk, reset,
    // from decode stage control unit
    input RegWrite_D, MemWrite_D, Jump_D, Branch_D, MemRead_D,
    input [1:0] MemToReg_D,
    input [3:0] ALUCtrl_D,
    input ALUSrc_D,

    // register file
    input [63:0] rs1_data_D, rs2_data_D,
    input [4:0] rs1_D, rs2_D, rd_D, 
     // immediate value
    input [63:0] imm_D,

    // pc values lmfao
    input [63:0] pc_D, pc_plus_4_D,

    // forwarding inputs 
    input [1:0] forwardA_E,forwardB_E,
    // from WB stage 
    input [63:0] result_W,alu_res_M,
    // control outputs
    output RegWrite_E, MemWrite_E, MemRead_E,
    output [1:0] MemToReg_E,
    // alu output
    output [63:0] alu_res_E, write_data_E,pc_tar_E,
    output [63:0] pc_plus_4_E,

    output [4:0] rs1_E, rs2_E, rd_E

);

    reg [63:0] SrcA_E;
    reg [63:0] SrcB_E;
    // controls 
    assign  RegWrite_E = RegWrite_D;
    assign MemWrite_E = MemWrite_D ;
    assign MemRead_E = MemRead_D;
    assign MemToReg_E = MemToReg_D;
    
    // 3x1 mux to slect srcA_E
always @(*) begin
    case(forwardA_E)
        2'b00: SrcA_E =  rs1_data_D;
        2'b01: SrcA_E =  result_W;
        2'b10: SrcA_E =  alu_res_M;
        default: SrcA_E =  rs1_data_D;
    endcase
end
    // 3x1 mux to slect srcB_E
reg [63:0] temp_b;
always @(*) begin
    case(forwardB_E)
        2'b00: temp_b = rs2_data_D;
        2'b01: temp_b = result_W;
        2'b10: temp_b = alu_res_M;
        default: temp_b = rs2_data_D;
    endcase
end

    // mux
    always @(*) begin
        if (ALUSrc_D == 1'b1)
             SrcB_E = imm_D;
        else
             SrcB_E =  temp_b;
    end

    // adder

    adder64 imm_adder(
        .a(pc_D), .b(imm_D),
        .adder_op(1'b0),
        .result(pc_tar_E),
        .cout(),
        .carry_flag(),
        .overflow_flag(),
        .neg_flag()
    );

    // ALU
    alu_64_bit A7(
    .rs1(SrcA_E),
    .rs2(SrcB_E),
    .alu_ctrl(ALUCtrl_D),
    .result(alu_res_E),
    .zero_flag(zero_E)  
    );

    assign write_data_E = rs2_data_D;
    // detecting jump and branch
    wire temp;
    and A1(temp,zero_E,Branch_D);
    or A2(PCSrc_E,temp,Jump_D);
endmodule
`endif