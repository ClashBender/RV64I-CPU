`timescale 1ns/1ps

`include "writeback.v"

module writeback_tb();

    reg clk, reset;

    reg RegWrite_M;
    reg [1:0] MemToReg_M;

    reg [63:0] alu_res_M;
    reg [63:0] read_data_M;
    reg [4:0] rd_M;
    reg [63:0] pc_plus_4_M;

    wire RegWrite_W;
    wire [1:0] MemToReg_W;
    wire [4:0] rd_W;
    wire [63:0] pc_plus_4_W;
    wire [63:0] result_W;

    writeback uut(
        .clk(clk),
        .reset(reset),

        .RegWrite_M(RegWrite_M),
        .MemToReg_M(MemToReg_M),

        .alu_res_M(alu_res_M),
        .read_data_M(read_data_M),

        .rd_M(rd_M),
        .pc_plus_4_M(pc_plus_4_M),

        .RegWrite_W(RegWrite_W),
        .MemToReg_W(MemToReg_W),

        .rd_W(rd_W),
        .pc_plus_4_W(pc_plus_4_W),
        .result_W(result_W)
    );

    // clock generation
    always #5 clk = ~clk;

    initial begin

        $display("=== Writeback Stage Testbench ===");

        clk = 0;
        reset = 1;

        RegWrite_M = 0;
        MemToReg_M = 2'b00;

        alu_res_M = 64'h10;
        read_data_M = 64'h12345678ABCDEF00;
        rd_M = 5'd5;
        pc_plus_4_M = 64'h1004;

        #10;
        reset = 0;

        // ---------------------------
        // TEST 1 : ALU result
        // ---------------------------
        $display("\n--- ALU Result Test ---");

        MemToReg_M = 2'b00;

        @(posedge clk);
        #1;

        $display("ALU -> Result_W = %h", result_W);

        // ---------------------------
        // TEST 2 : Memory data
        // ---------------------------
        $display("\n--- Memory Data Test ---");

        MemToReg_M = 2'b01;

        @(posedge clk);
        #1;

        $display("MEM -> Result_W = %h", result_W);

        // ---------------------------
        // TEST 3 : PC + 4
        // ---------------------------
        $display("\n--- PC+4 Test ---");

        MemToReg_M = 2'b10;

        @(posedge clk);
        #1;

        $display("PC+4 -> Result_W = %h", result_W);

        // ---------------------------
        // TEST 4 : Register Write
        // ---------------------------
        $display("\n--- Register Write Test ---");

        RegWrite_M = 1;

        @(posedge clk);
        #1;

        $display("RegWrite_W = %b", RegWrite_W);
        $display("rd_W = %d", rd_W);

        $finish;

    end

endmodule