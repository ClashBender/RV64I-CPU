`timescale 1ns/1ps
`include "pc.v"

module pc_tb();

    reg clk;
    reg reset;
    reg [63:0] pc_in;
    wire [63:0] pc_out;

    pc uut (
        .clk(clk),
        .reset(reset),
        .pc_in(pc_in),
        .pc_out(pc_out)
    );

    // Clock (10ns)
    always begin
        clk = 1'b0; #5;
        clk = 1'b1; #5;
    end

    initial begin
        $display("Time | Reset | PC_IN              | PC_OUT");
        $display("----------------------------------------");

        // Test 1: Reset condition
        reset = 1'b1;
        pc_in = 64'h0000000000000000;
        #10;
        $display("%4t | %5b | %016h | %016h", $time, reset, pc_in, pc_out);

        // Test 2: Load first instruction address
        reset = 1'b0;
        pc_in = 64'h0000000000000000;
        #10;
        $display("%4t | %5b | %016h | %016h", $time, reset, pc_in, pc_out);

        // Test 3: Load next instruction address (PC + 4)
        pc_in = 64'h0000000000000004;
        #10;
        $display("%4t | %5b | %016h | %016h", $time, reset, pc_in, pc_out);

        // Test 4: Load another instruction address (PC + 8)
        pc_in = 64'h0000000000000008;
        #10;
        $display("%4t | %5b | %016h | %016h", $time, reset, pc_in, pc_out);

        // Test 5: Load larger address
        pc_in = 64'h0000000000001000;
        #10;
        $display("%4t | %5b | %016h | %016h", $time, reset, pc_in, pc_out);

        // Test 6: Load high address value
        pc_in = 64'hFFFFFFFFFFFFFFFC;
        #10;
        $display("%4t | %5b | %016h | %016h", $time, reset, pc_in, pc_out);

        // Test 7: Reset again to verify reset works anytime
        reset = 1'b1;
        pc_in = 64'hFFFFFFFFFFFFFFFF;
        #10;
        $display("%4t | %5b | %016h | %016h", $time, reset, pc_in, pc_out);

        // Test 8: Deassert reset and load address
        reset = 1'b0;
        pc_in = 64'h0000000000002000;
        #10;
        $display("%4t | %5b | %016h | %016h", $time, reset, pc_in, pc_out);

        // Test 9: Load sequential address
        pc_in = 64'h0000000000002004;
        #10;
        $display("%4t | %5b | %016h | %016h", $time, reset, pc_in, pc_out);

        // Test 10: Load another sequential address
        pc_in = 64'h0000000000002008;
        #10;
        $display("%4t | %5b | %016h | %016h", $time, reset, pc_in, pc_out);
        $finish;
    end

endmodule
