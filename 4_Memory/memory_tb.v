`timescale 1ns/1ps
`include "memory.v"

module memory_tb();

    reg clk, reset;

    // control inputs
    reg RegWrite_E;
    reg MemWrite_E;
    reg [1:0] MemToReg_E;

    // execute stage inputs
    reg [63:0] alu_res_E;
    reg [63:0] write_data_E;
    reg [4:0] rd_E;
    reg [63:0] pc_plus_4_E;

    // outputs
    wire RegWrite_M;
    wire [1:0] MemToReg_M;
    wire [4:0] rd_M;
    wire [63:0] pc_plus_4_M;
    wire [63:0] read_data_M;
    wire [63:0] alu_res_M;

    memory uut(
        .clk(clk),
        .reset(reset),

        .RegWrite_E(RegWrite_E),
        .MemWrite_E(MemWrite_E),
        .MemToReg_E(MemToReg_E),

        .alu_res_E(alu_res_E),
        .write_data_E(write_data_E),
        .rd_E(rd_E),
        .pc_plus_4_E(pc_plus_4_E),

        .RegWrite_M(RegWrite_M),
        .MemToReg_M(MemToReg_M),

        .rd_M(rd_M),
        .pc_plus_4_M(pc_plus_4_M),

        .read_data_M(read_data_M),
        .alu_res_M(alu_res_M)
    );

    // clock generation
    always #5 clk = ~clk;

    initial begin

        $display("=== Memory Stage Testbench ===");

        clk = 0;
        reset = 1;

        RegWrite_E = 0;
        MemWrite_E = 0;
        MemToReg_E = 2'b00;

        alu_res_E = 0;
        write_data_E = 0;
        rd_E = 0;
        pc_plus_4_E = 0;

        #10;
        reset = 0;

        // ---------------------------
        // TEST 1 : Memory Write
        // ---------------------------
        $display("\n--- Memory Write Test ---");

        alu_res_E = 64'h10;
        write_data_E = 64'hDEADBEEFCAFEBABE;
        MemWrite_E = 1;

        @(posedge clk);
        #1;

        $display("WRITE: Address = %h Data = %h",
                 alu_res_E, write_data_E);

        // ---------------------------
        // TEST 2 : Memory Read
        // ---------------------------
        $display("\n--- Memory Read Test ---");

        MemWrite_E = 0;

        @(posedge clk);
        #1;

        $display("READ: Address = %h Data = %h",
                 alu_res_E, read_data_M);

        // ---------------------------
        // TEST 3 : Pipeline Pass-through
        // ---------------------------
        $display("\n--- Pipeline Forward Test ---");

        rd_E = 5'd5;
        pc_plus_4_E = 64'h1004;

        @(posedge clk);
        #1;

        $display("RD_M = %d", rd_M);
        $display("PC+4_M = %h", pc_plus_4_M);
        $display("ALU_RES_M = %h", alu_res_M);

        $finish;

    end

endmodule