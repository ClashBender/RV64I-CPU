`timescale 1ns/1ps

module imm_tb;
    reg [31:0] instruction;
    wire [63:0] imm_out;

    // Instantiating
    imm uut(
        .instruction(instruction),
        .imm_out(imm_out)
    );

    initial begin
        instruction = 32'b111111111111_00000_000_00000_0010011; 
        #10;
        $display("I-type Test: imm_out = %0b", imm_out);

        instruction = 32'b1111111_00000_00000_010_00000_0100011;
        #10;
        $display("S-type Test: imm_out = %0b", imm_out);

        instruction = 32'b1_000000_00000_00000_000_0000_0_1100011;
        #10;
        $display("B-type Test: imm_out = %0b", imm_out);

        instruction = 32'b1_00000000_0_0000000000_00000_1101111;
        #10;
        $display("J-type Test: imm_out = %0b", imm_out);
        $finish;
    end
endmodule