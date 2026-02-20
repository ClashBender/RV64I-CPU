`timescale 1ns/1ps

module imm(
    input [31:0] instruction,
    output reg [63:0] imm_out
);
    always @(*) begin 
        case (instruction[6:0])
            7'b0010011: imm_out = {{52{instruction[31]}}, instruction[31:20]}; // I-type (arithmetic)
            7'b0000011: imm_out = {{52{instruction[31]}}, instruction[31:20]}; // I-type (Load)
            7'b1100111: imm_out = {{52{instruction[31]}}, instruction[31:20]}; // I-type (Jump)
            7'b0100011: imm_out = {{52{instruction[31]}}, instruction[31:25], instruction[11:7]}; // S-type
            7'b1100011: imm_out = {{52{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0}; // B-type
            7'b1101111: imm_out = {{44{instruction[31]}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0}; // J-type
            default: imm_out = 64'h0;
        endcase 
    end 
endmodule 