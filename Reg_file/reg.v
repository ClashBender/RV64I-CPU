`timescale 1ns/1ps
module reg_file (
    input clk,
    input reset,
    input [4:0] read_reg1, read_reg2, write_reg,
    input [63:0] write_data,
    input reg_write_en,
    output [63:0] read_data1, read_data2
);
// declaring the register file as 32 element array of 64-bit registers and following the big endian convention
reg [63:0] registers [31:0];
// harwiring x0 to 0
always @(posedge clk) begin
    registers[0] <= 64'b0; // x0 is always 0
end
// read operation
assign read_data1 = registers[read_reg1];
assign read_data2 = registers[read_reg2];
// write operation
integer i;
always @(posedge clk or posedge reset) begin
    if (reset) begin
        for (i = 0; i < 32; i = i + 1) begin
            registers[i] <= 64'b0;
        end
    end else if (reg_write_en) begin
        registers[write_reg] <= write_data;
    end
end
// harwiring x0 to 0 if it has changed due to write operation
always @(posedge clk) begin
    registers[0] <= 64'b0; // x0 is always 0
end
endmodule