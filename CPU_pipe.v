`ifndef CPU_PIPE_V
`define CPU_PIPE_V

`include "1_Fetch/fetch.v"
`include "2_Decode/decode.v"
`include "3_Execute/execute.v"
`include "4_Memory/memory.v"
`include "5-Writeback/writeback.v"
`include "Hazards/hazards.v"

module CPU_pipe(
    input clk, 
    input reset
);

wire stall, flush;

// IF
wire [31:0] instr_F;
wire [63:0] pc_plus_4_F, pc_out_F;

// ID
reg [31:0] instr_D;
reg [63:0] pc_plus_4_D, pc_out_D;

wire RegWrite_D, MemWrite_D, Jump_D, Branch_D, MemRead_D, ALUSrc_D;
wire [1:0] MemToReg_D;
wire [3:0] ALUCtrl_D;
wire [4:0] rs1_D, rs2_D, rd_D;  
wire [63:0] rs1_data_D, rs2_data_D, imm_D;

// EX
wire PCSrc_E;
wire [63:0] pc_tar_E, alu_res_E, write_data_E;

reg RegWrite_E, MemWrite_E, Jump_E, Branch_E, MemRead_E, ALUSrc_E;
reg [1:0] MemToReg_E; 
reg [3:0] ALUCtrl_E;
reg [4:0] rs1_E, rs2_E, rd_E;
reg [63:0] pc_plus_4_E, pc_out_E, rs1_data_E, rs2_data_E, imm_E;

// MEM
wire [63:0] read_data_M;

reg RegWrite_M, MemWrite_M, MemRead_M;
reg [1:0] MemToReg_M;
reg [4:0] rs1_M, rs2_M, rd_M;
reg [63:0] alu_res_M, write_data_M, pc_plus_4_M;

// WB
wire [63:0] result_W;

reg RegWrite_W;
reg [1:0] MemToReg_W;
reg [4:0] rd_W;
reg [63:0] read_data_W, alu_res_W, pc_plus_4_W;

wire [1:0] forwardA_E, forwardB_E;
wire forward_M;


//Hazard Detection Block
hazards hazard_block(
    .rs1_d(rs1_D), .rs2_d(rs2_D),
    .rs1_e(rs1_E), .rs2_e(rs2_E),
    .rs2_m(rs2_M),
    .rd_e(rd_E), .rd_m(rd_M), .rd_w(rd_W),
    .reg_write_m(RegWrite_M),
    .mem_write_m(MemWrite_M),
    .reg_write_w(RegWrite_W),
    .PCSrc_E(PCSrc_E),
    .mem_write_d(MemWrite_D),
    .mem_to_reg_e(MemToReg_E),
    .forward_ae(forwardA_E),
    .forward_be(forwardB_E),
    .forward_m(forward_M),
    .stall(stall),
    .flush(flush)
);


// IF stage
fetch IF_stage(
    //inputs
    .clk(clk),
    .reset(reset),
    .enable(!stall),
    .pc_tar_E(pc_tar_E),
    .PCSrc_E(PCSrc_E),
    .pc_out_F(pc_out_F),
    .pc_plus_4_F(pc_plus_4_F),
    .instr_F(instr_F)
);

// IF/ID register
always @ (posedge clk) begin
    if (reset || flush) begin // reset all IF/ID pipeline register values to 0
        {instr_D, pc_out_D, pc_plus_4_D} <= 0;
    end 
    else if (stall) begin // don't update register
        instr_D <= instr_D;  
        pc_out_D <= pc_out_D; 
        pc_plus_4_D <= pc_plus_4_D; 
    end 
    else begin // update values from IF
        instr_D <= instr_F; 
        pc_out_D <= pc_out_F; 
        pc_plus_4_D <= pc_plus_4_F;
    end
end


// ID stage
decode ID_stage(
    //inputs
    .clk(clk), .reset(reset), 
    .instr_D(instr_D),
    .pc_out_D(pc_out_D),
    .pc_plus_4_D(pc_plus_4_D),
    .RegWrite_W(RegWrite_W),
    .rd_W(rd_W),
    .result_W(result_W),

    //outputs
    .RegWrite_D(RegWrite_D), 
    .MemWrite_D(MemWrite_D), 
    .Jump_D(Jump_D), 
    .Branch_D(Branch_D), 
    .MemRead_D(MemRead_D),
    .MemToReg_D(MemToReg_D),
    .ALUCtrl_D(ALUCtrl_D),
    .ALUSrc_D(ALUSrc_D),
    .rs1_data_D(rs1_data_D), .rs2_data_D(rs2_data_D),
    .imm_D(imm_D),
    .rs1_D(rs1_D), .rs2_D(rs2_D), .rd_D(rd_D)
);

// ID/EX register
always @ (posedge clk) begin 
    if (reset || flush || stall) begin // reset register
        {RegWrite_E, MemWrite_E, Jump_E, Branch_E, MemRead_E, ALUSrc_E, MemToReg_E, ALUCtrl_E} <= 0;
        {rs1_data_E, rs2_data_E, imm_E} <= 0;
        {rs1_E, rs2_E, rd_E} <= 0;
        {pc_out_E, pc_plus_4_E} <= 0;
    end 
    else begin // update values from ID
        {RegWrite_E, MemWrite_E, Jump_E, Branch_E, MemRead_E, ALUSrc_E, MemToReg_E, ALUCtrl_E} <= {RegWrite_D, MemWrite_D, Jump_D, Branch_D, MemRead_D, ALUSrc_D, MemToReg_D, ALUCtrl_D};
        {rs1_data_E, rs2_data_E, imm_E} <= {rs1_data_D, rs2_data_D, imm_D};
        {rs1_E, rs2_E, rd_E} <= {rs1_D, rs2_D, rd_D};
        {pc_out_E, pc_plus_4_E} <= {pc_out_D, pc_plus_4_D}; 
    end
end


// EX stage
execute EX_stage(
    .clk(clk), .reset(reset),
    .RegWrite_E(RegWrite_E), .MemWrite_E(MemWrite_E), .Jump_E(Jump_E), .Branch_E(Branch_E), .MemRead_E(MemRead_E),
    .MemToReg_E(MemToReg_E),
    .ALUCtrl_E(ALUCtrl_E),
    .ALUSrc_E(ALUSrc_E),
    .rs1_data_E(rs1_data_E), .rs2_data_E(rs2_data_E),
    .rs1_E(rs1_E), .rs2_E(rs2_E), .rd_E(rd_E),
    .imm_E(imm_E), 
    .pc_out_E(pc_out_E),
    .forwardA_E(forwardA_E), .forwardB_E(forwardB_E),
    .result_W(result_W), .alu_res_M(alu_res_M),

    //output
    .pc_tar_E(pc_tar_E), .alu_res_E(alu_res_E), .write_data_E(write_data_E),
    .PCSrc_E(PCSrc_E)
);


// EX/MEM register
always @ (posedge clk) begin
    if (reset) begin // reset registers
        {RegWrite_M, MemWrite_M, MemRead_M} <= 0;
        MemToReg_M <= 0;
        {alu_res_M, write_data_M} <= 0;
        rd_M <= 0;
        pc_plus_4_M <= 0;
        rs1_M <= 0;
        rs2_M <= 0;
    end 
    else begin // update values from EX
        {RegWrite_M, MemWrite_M, MemRead_M} <= {RegWrite_E, MemWrite_E, MemRead_E};
        MemToReg_M <= MemToReg_E;
        {alu_res_M, write_data_M} <= {alu_res_E, write_data_E};
        rd_M <= rd_E;
        pc_plus_4_M <=  pc_plus_4_E;
        rs1_M <= rs1_E;
        rs2_M <= rs2_E; 
    end
end


// MEM stage
memory MEM_stage(
    .clk(clk), .reset(reset),
    .RegWrite_M(RegWrite_M), .MemWrite_M(MemWrite_M), .MemRead_M(MemRead_M),
    .MemToReg_M(MemToReg_M),
    .alu_res_M(alu_res_M), 
    .write_data_M(write_data_M), .rd_M(rd_M), 
    .pc_plus_4_M(pc_plus_4_M),
    .read_data_M(read_data_M)
);

// MEM/WB register
always @ (posedge clk) begin
    if(reset) begin // reset registers
        RegWrite_W <= 0;
        MemToReg_W <= 0;
        read_data_W <= 0;
        rd_W <= 0;
        pc_plus_4_W <= 0;
        alu_res_W <= 0;
    end
    else begin // update values from MEM
        RegWrite_W <= RegWrite_M;
        MemToReg_W <= MemToReg_M;
        read_data_W <= read_data_M;
        rd_W <= rd_M;
        pc_plus_4_W <= pc_plus_4_M;
        alu_res_W <= alu_res_M;
    end
end


// WB stage
writeback WB_stage(
    .clk(clk), .reset(reset),
    .MemToReg_W(MemToReg_W),
    .alu_res_W(alu_res_W), .read_data_W(read_data_W), 
    .pc_plus_4_W(pc_plus_4_W),
    .result_W(result_W)
);

endmodule
`endif 