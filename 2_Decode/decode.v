`include "../Modules/Control/Main_ctrl/mcu.v"
`include "../Modules/Control/ALU_ctrl/alu_ctrl.v"
`include "../Modules/Reg_file/reg.v"
`include "../Modules/Imm_gen/imm.v"

module decode(

    // general signals
    input clk, reset, 

    // from prev (IF) stage
    input [31:0] instr_F,
    input [63:0] pc_F, pc_plus_4_F,

    // from WB stage 
    input RegWrite_W,
    input [4:0] rd_W,
    input [63:0] result_W,

    // control signals
    output RegWrite_D, MemWrite_D, Jump_D, Branch_D, MemRead_D,
    output [1:0] MemToReg_D, // resultsrc is same as memtoreg
    output [3:0] ALUCtrl_D,
    output ALUSrc_D,

    // reg file outputs
    output [63:0] rs1_data_D, rs2_data_D,
    output [4:0] rs1_D, rs2_D, rd_D,
    
    // immediate value
    output [63:0] imm_D,

    // pc values lmfao
    output [63:0] pc_D, pc_plus_4_D
);

    wire [6:0] opcode;
    wire [2:0] funct3;
    wire [6:0] funct7;

    assign opcode = instr_F[6:0];
    assign funct3 = instr_F[14:12];
    assign funct7 = instr_F[31:25];
    assign rs1_D = instr_F[19:15];
    assign rs2_D = instr_F[24:20];
    assign rd_D = instr_F[11:7];

    wire [1:0] ALUOp;

    mcu mcu_inst(
        .opcode(opcode),
        .branch(Branch_D),
        .jump(Jump_D),
        .MemRead(MemRead_D),
        .MemToReg(MemToReg_D),
        .ALUOp(ALUOp),
        .MemWrite(MemWrite_D),
        .ALUSrc(ALUSrc_D),
        .RegWrite(RegWrite_D)
    );

    ALU_Control alu_ctrl_inst(
        .ALUOp(ALUOp),
        .funct7(funct7),
        .funct3(funct3),
        .inst5(instr[5]),
        .ALU_ctrl(ALUCtrl_D)
    );

    reg_file reg_inst(
        .clk(clk),
        .reset(reset),
        .read_reg1(rs1_D), .read_reg2(rs2_D), .write_reg(rd_W),
        .write_data(result_W),
        .reg_write_en(RegWrite_W),
        .read_data1(rs1_data_D), .read_data2(rs2_data_D)
    );

    imm imm_inst(
        .instruction(instr),
        .imm_out(imm_D)
    );

    assign pc_D = pc_F;
    assign pc_plus_4_D = pc_plus_4_F;

endmodule