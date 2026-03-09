`ifndef writeback
`define writeback

`include "../Modules/ALU/adder64/adder64.v"


module writeback(
    input clk, reset,
    //input RegWrite_M,
    input [1:0] MemToReg_W,
    input [63:0] alu_res_W,
    input [63:0] read_data_W,
    // input [4:0] rd_M,
    input [63:0] pc_plus_4_W,

    output [63:0] result_W,
    
);

// done in top module
// assign MemToReg_W = MemToReg_M;
// assign rd_W = rd_M;
// assign pc_plus_4_W = pc_plus_4_M;
// assign RegWrite_W = RegWrite_M;


// 3x1 mux
always @(*) begin
    case(MemToReg_W)
        2'b00: result_W = alu_res_W;
        2'b01: result_W = read_data_W;
        2'b10: result_W = pc_plus_4_W;
        default: result_W = alu_res_W;
    endcase
end

endmodule

`endif