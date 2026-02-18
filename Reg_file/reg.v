`timescale 1ns/1ps

module reg_file (
    input clk,
    input reset,
    input [4:0] read_reg1, read_reg2, write_reg,
    input [63:0] write_data,
    input reg_write_en,
    output [63:0] read_data1, read_data2
);

// declaring the register file as 32 element array of 64-bit registers and
// following the Big Endian convention
reg [63:0] registers [31:0];

// read operation
assign read_data1 = (read_reg1) ? registers[read_reg1] : 64'b0;
assign read_data2 = (read_reg2) ? registers[read_reg2] : 64'b0;

// write operation
always @(posedge clk or posedge reset) begin
    if (reset) begin
        for (integer i = 0; i < 32; i = i + 1) 
            registers[i] <= 64'b0;
    end 
    else if (reg_write_en) 
        registers[write_reg] <= write_data;
end

endmodule