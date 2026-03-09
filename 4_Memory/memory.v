`ifndef memory
`define memory

`include "../Modules/Data_memory/data_mem.v"
`include "../Modules/ALU/adder64/adder64.v"

module memory(
    input clk, reset,
    // controls
    input RegWrite_M, MemWrite_M, MemRead_M,
    input [1:0] MemToReg_M,
    
    //ALU
    input [63:0] alu_res_M,write_data_M,
    input [4:0] rd_M,
    input [63:0] pc_plus_4_M,

    // outputs 
    // output RegWrite_M,
    // output [1:0] MemToReg_M,
    

    //output [4:0] rd_M,
    //output [63:0] pc_plus_4_M,
    // data memory
    output [63:0] read_data_M,
    //output [63:0] alu_res_M
);

data_mem data_mem(
    .clk(clk),
    .reset(reset),
    .MemWrite(MemWrite_M),
    .MemRead(MemRead_M),
    .address(alu_res_M[9:0]),       
    .write_data(write_data_M),
    .read_data(read_data_M)
    ); 
    //done in top module
//  assign rd_M = rd_E;
//  assign alu_res_M = alu_res_E;
//  assign pc_plus_4_M = pc_plus_4_E;

endmodule

`endif