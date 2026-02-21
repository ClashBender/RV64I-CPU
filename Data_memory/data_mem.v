`define MEM_SIZE 1024  // Size of data memory in bytes

module data_mem (
    input clk,
    input reset,
    input MemWrite,
    input MemRead,
    input [9:0] address,
    input [63:0] write_data,
    output reg [63:0] read_data
);

    reg [7:0] data [0:`MEM_SIZE-1];
    integer i;


    always @ (posedge clk) begin

        if(MemWrite == 1'b1) 
            {data[address], data[address+1], data[address+2], data[address+3], data[address+4], data[address+5], data[address+6], data[address+7]} <= write_data;
        else if(MemRead == 1'b1)
            read_data <= {data[address], data[address+1], data[address+2], data[address+3], data[address+4], data[address+5], data[address+6], data[address+7]};
        else read_data <= 64'b0;  // Default value when not reading

        if(reset == 1'b1) begin
            for (i = 0; i < `MEM_SIZE; i = i + 1) begin
                data[i] <= 8'b0;  // Clear memory on reset
            end
        end
    end


endmodule