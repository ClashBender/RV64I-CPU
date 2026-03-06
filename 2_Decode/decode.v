`include "../Modules/Control/Main_ctrl/mcu.v"
`include "../Modules/Control/ALU_ctrl/alu_ctrl.v"
`include "../Modules/Reg_file/reg.v"
`include "../Modules/Imm_gen/imm.v"

module decode(
    input [31:0] instr,
    input [63:0] pc_out, pc_plus_4, 
    input [63:0] result_w,
    input [4:0] rd_w,
    output RegWrite_D, MemWrite_D, Jump_D, Branch_D, 
    output [1:0] MemToReg_D,
    output [3:0] ALU_ctrl_D,
    output ALUSrc_D,
    output [63:0] 
);


endmodule