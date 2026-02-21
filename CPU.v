`timescale 1ns/1ps
`include "alu.v"
`include "pc.v"
`include "reg.v"
`include "inst.v"
`include "imm.v"
`include "alu_ctrl.v"
`include "mcu.v"
`include "data_mem.v"
`include "mux64.v"
`include "adder64.v"
`include "gate64.v"
`include "shift64.v"
module CPU(
    input clk,
    output
);
wire pc_out,pc_in,ALUSrc,ALUOp,MemWrite,MemToReg,reg_write_en;
wire branch,zero;
wire [31:0]y;
wire [63:0]rs1,rs2,imm_out,in2,res,out,write_data,inc; 
// res is o/p of alu,out is o/p of data mem , in2 is o/p od 1st mux , inc is i/p to adder
wire [3:0]ALU_ctrl;
PC A1(
    .clk(clk),
    .reset(),
    .pc_in(pc_in),
    .pc_out(pc_out)
);

instmem A2(.clk(clk),.reset(),.addr(pc_out),.instr(y));
reg_file A3(.clk(clk),.reset(),.read_reg1([19:15]y),.read_reg2([24:20]y),.write_reg([17:11]y),
             .write_data(write_data),.reg_write_en(reg_write_en),.read_data1(rs1),.read_data2(rs2));
mcu A4(.opcode([0:6]y),.ALUSrc(ALUSrc),.ALUOp(ALUOp),.MemWrite(MemWrite),.MemToReg(MemToReg),.RegWrite(reg_write_en) 
       .branch(branch).jump(),MemRead(-----));
imm A5(.instruction(y),.imm_out(imm_out));
mux64 A6(.a(imm_out),.b(rs2),.sel(ALUSrc),.res(in2));
ALU_Control A8(.ALUOp(ALUOp),.funct7([]),.funct3(),.inst5(),.ALU_ctrl(ALU_ctrl));
alu_64_bit A7(.rs1(rs1),.rs2(in2),.alu_ctrl(ALU_ctrl),.res(res),.zero_flag(zero)  );
data_mem A8(.clk(clk),.reset(),.MemWrite(MemWrite),.MemRead(------),.address([9:0]res),.write_data(rs2),.read_data(out)); 

// memory read from mcu is 3 bits??
mux64 A9(.a(out),.b(res),.sel(MemToReg),.res(write_data));
barrel_shifter A10(.a(imm_out),.b(64'b1),.lr_flag(0),.logic_flag(0),.result(inc));
adder64 A11(.a(pc_out),.b(inc),.adder_op(0),.result(temp1),.cout(),.carry_flag(),.overflow_flag(),.neg_flag());
adder64 A12(.a(pc_out),.b(64'b100),.adder_op(0),.result(temp2),.cout(),.carry_flag(),.overflow_flag(),.neg_flag());
assign res_and = branch & zero;
mux64 A14(.a(temp1),.b(temp2),.sel(res_and),.res(pc_in));

endmodule