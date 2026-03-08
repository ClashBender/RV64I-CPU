`ifndef memory
`define memory

`include "../Modules/Data_memory/data_mem.v"
`include "../Modules/ALU/adder64/adder64.v"

module memory(
    input clk, reset,
    // controls
    input RegWrite_E, MemWrite_E, MemRead_E,
    input [1:0] MemToReg_E,
    
    //ALU
    input [63:0] alu_res_E,write_data_E,
    input [4:0] rd_E,
    input [63:0] pc_plus_4_E,

    // outputs 
    output RegWrite_M,
    output [1:0] MemToReg_M,
    

    output [4:0] rd_M,
    output [63:0] pc_plus_4_M,
    // data memory
    output [63:0] read_data_M,
    output [63:0] alu_res_M
);

data_mem data_mem(
    .clk(clk),
    .reset(reset),
    .MemWrite(MemWrite_E),
    .MemRead(MemRead_E),
    .address(alu_res_E[9:0]),       
    .write_data(write_data_E),
    .read_data(read_data_M)
    ); 

 assign rd_M = rd_E;
 assign alu_res_M = alu_res_E;
 assign pc_plus_4_M = pc_plus_4_E;

endmodule

`endif