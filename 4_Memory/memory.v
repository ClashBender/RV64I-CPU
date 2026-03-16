`ifndef memory
`define memory

`include "Modules/Data_memory/data_mem.v"
`include "Modules/ALU/adder64/adder64.v"

module memory(
    input clk, reset,
    // controls
    input RegWrite_M, MemWrite_M, MemRead_M,
    input [1:0] MemToReg_M,
    
    //ALU
    input [63:0] alu_res_M, write_data_M,
    input [4:0] rd_M,
    input [63:0] pc_plus_4_M,

    // forwarding
    input forward_M,
    input [63:0] read_data_W,
    
    // data memory
    output [63:0] read_data_M
);

wire [63:0] write_data;

assign write_data = (forward_M) ? read_data_W : write_data_M;

data_mem data_mem(
    .clk(clk),
    .reset(reset),
    .MemWrite(MemWrite_M),
    .MemRead(MemRead_M),
    .address(alu_res_M[9:0]),       
    .write_data(write_data),
    .read_data(read_data_M)
    ); 


endmodule

`endif