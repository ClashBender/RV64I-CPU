`ifndef CPU_PIPE_V
`define CPU_PIPE_V

`include "1_fetch/IF.v"
`include "2_decode/ID.v"
`include "3_execute/EX.v"
`include "4_memory/MEM.v"
`include "5_writeback/WB.v"
`include "Hazards/hazards.v"



module CPU_pipe(
    input clk, 
    input reset
);

wire stall, flush;

//f
wire [31:0] instr_F;
wire [63:0] pc_plus_4_F, pc_out_F;

//d
reg [31:0] instr_D;
reg [63:0] pc_plus_4_D, pc_out_D;

wire RegWrite_D, MemWrite_D, Jump_D, Branch_D, MemRead_D, ALUSrc_D
wire [1:0] MemToReg_D, // resultsrc is same as memtoreg
wire [3:0] ALUCtrl_D,
wire [4:0] rs1_D, rs2_D, rd_D,
wire [63:0] rs1_data_D, rs2_data_D, imm_D


//e
wire pcsrc_E;
wire [63:0] pc_tar_E; alu_res_E, write_data_E,

reg RegWrite_E, MemWrite_E, Jump_E, Branch_E, MemRead_E, ALUSrc_E;
reg [1:0] MemToReg_E, // resultsrc is same as memtoreg
reg [3:0] ALUCtrl_E,
reg [4:0] rs1_E, rs2_E, rd_E,
reg [63:0] pc_plus_4_E, pc_out_E, rs1_data_E, rs2_data_E, imm_E;

//m
wire [63:0] read_data_M;

reg RegWrite_M, MemWrite_M, MemRead_M;
reg [1:0] MemToReg_M;
reg [4:0] rd_M;
reg [63:0] alu_res_M, write_data_M, pc_plus_4_M;


//w
wire [63:0] result_W,

reg RegWrite_W, 
reg [1:0] MemToReg_W,
reg [4:0] rd_W,
reg [63:0] read_data_W, alu_res_W, pc_plus_4_W;



//Hazard Detection Block



//Instantiating the IF stage
fetch IF_stage(
    //inputs
    .clk(clk),
    .reset(reset),
    .enable(!stall),
    .pc_tar_E(pc_tar_E), // from EX stage
    .PCSrc_E(PCSrc_E), // from EX stage
    //outputs
    .pc_plus_4_F(pc_plus_4_F), // to ID stage
    .instr_F(instr_F) // to ID stage
);


// IF/ID reg: needs to hold previous values if stall is asserted, needs to be flushed with 0s if flush is asserted, else update on clock edge
always @ (posedge clk) begin
    if (reset || flush) begin
        {instr_D, pc_out_D, pc_plus_4_D} <= 0; // reset all IF/ID pipeline register values to 0
    end 
    else if (stall) begin
        instr_D <= instr_D; // keep instruction the same
        pc_out_D <= pc_out_D; // keep pc the same
        pc_plus_4_D <= pc_plus_4_D; // keep pc+4 the same
    end 
    else begin
        instr_D <= instr_F; // update instruction
        pc_out_D <= pc_out_F; // update pc
        pc_plus_4_D <= pc_plus_4_F; // update pc+4
        // update IF/ID pipeline registers with new values from IF stage
    end
end


//Instantiating the ID stage
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
    .RegWrite_D(RegWrite_D), .MemWrite_D(MemWrite_D), .Jump_D(Jump_D), .Branch_D(Branch_D), .MemRead_D(MemRead_D),
    .MemToReg_D(MemToReg_D),
    .ALUCtrl_D(ALUCtrl_D),
    .ALUSrc_D(ALUSrc_D),
    .rs1_data_D(rs1_data_D), .rs2_data_D(rs2_data_D),
    .imm_D(imm_D),
    .rs1_D(rs1_D), .rs2_D(rs2_D), .rd_D(rd_D)
);

// ID/EX reg: needs to take 0s if either stall or flush is asserted, else update on clock edge
always @ (posedge clk) begin
    if (reset || flush || stall) begin
        // reset all ID/EX pipeline register values to 0
        {RegWrite_E, MemWrite_E, Jump_E, Branch_E, MemRead_E, ALUSrc_E, MemToReg_E, ALUCtrl_E} <= 0;
        {rs1_data_E, rs2_data_E, imm_E} <= 0;
        {rs1_E, rs2_E, rd_E} <= 0;
        {pc_out_E, pc_plus_4_E} <= 0;
    end 
    else begin
        // update all ID/EX pipeline registers with new values from ID stage
        {RegWrite_E, MemWrite_E, Jump_E, Branch_E, MemRead_E, ALUSrc_E, MemToReg_E, ALUCtrl_E} <= {RegWrite_D, MemWrite_D, Jump_D, Branch_D, MemRead_D, ALUSrc_D, MemToReg_D, ALUCtrl_D};
        {rs1_data_E, rs2_data_E, imm_E} <= {rs1_data_D, rs2_data_D, imm_D};
        {rs1_E, rs2_E, rd_E} <= {rs1_D, rs2_D, rd_D};
        {pc_out_E, pc_plus_4_E} <= {pc_out_D, pc_plus_4_D}; 
    end
end


//instantiating the EX stage
execute EX_stage(
    .clk(clk), .reset(reset),
    .RegWrite_E(RegWrite_E), .MemWrite_E(MemWrite_E), .Jump_E(Jump_E), .Branch_E(Branch_E), .MemRead_E(MemRead_E),
    .MemToReg_E(MemToReg_E),
    .ALUCtrl_E(ALUCtrl_E),
    .ALUSrc_E(ALUSrc_E),
    .rs1_data_E(rs1_data_E), .rs2_data_E(rs2_data_E),
    .rs1_E(rs1_E), .rs2_E(rs2_E), .rd_E(rd_E),
    .imm_E(imm_E),
    .forwardA_E(forwardA_E), .forwardB_E(forwardB_E),
    .result_W(result_W), .alu_res_M(alu_res_M),

    //output
    .pc_tar_E(pc_tar_E), .alu_res_E(alu_res_E), .write_data_E(write_data_E)
);


// EX/MEM reg: needs to take 0s if flush is asserted, else update on clock edge
always @ (posedge clk) begin
    if (reset || flush) begin
        // reset all EX/MEM pipeline register values to 0
        {RegWrite_M, MemWrite_M, MemRead_M} <= 0;
        MemToReg_M <= 0;
        {alu_res_M, write_data_M} <= 0;
        rd_M <= 0;
        pc_plus_4_M <= 0;
    end 
    else begin
        // update all EX/MEM pipeline registers with new values from EX stage
        {RegWrite_M, MemWrite_M, MemRead_M} <= {RegWrite_E, MemWrite_E, MemRead_E};
        MemToReg_M <= MemToReg_E;
        {alu_res_M, write_data_M} <= {alu_res_E, write_data_E};
        rd_M <= rd_E;
        pc_plus_4_M <=  pc_plus_4_E; 
    end
end

//instantiating the MEM stage
memory MEM_stage(
    .clk(clk), .reset(reset),
    .RegWrite_M(RegWrite_M), .MemWrite_M(MemWrite_M), .MemRead_M(MemRead_M),
    .MemToReg_M(MemToReg_M),
    .alu_res_M(alu_res_M), .write_data_M(write_data_M), .rd_M(rd_M), .pc_plus_4_M(pc_plus_4_M),
    //output
    .read_data_M(read_data_M)
);

// MEM/WB reg: updates on every clock edge regardless of stall and flush
always @ (posedge clk) begin
    if(reset) begin
        RegWrite_W <= 0;
        MemToReg_W <= 0;
        read_data_W <= 0;
        rd_W <= 0;
        pc_plus_4_W <= 0;
        alu_res_W <= 0;
    end
    else begin
    // update all MEM/WB pipeline registers with new values from MEM stage
        RegWrite_W <= RegWrite_M;
        MemToreg_W <= MemToReg_M;
        read_data_W <= read_data_M;
        rd_W <= rd_M;
        pc_plus_4_W <= pc_plus_4_M;
        alu_res_W <= alu_res_M;
    end
end

// instantiating the WB stage
writeback WB_stage(
    .clk(clk), .reset(reset),
    .MemToReg_W(MemToReg_W),
    .alu_res_W(alu_res_W), .read_data_W(read_data_W), .pc_plus_4_W(pc_plus_4_W),
    //output
    .result_W(result_W)
);


endmodule