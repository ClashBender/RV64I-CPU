`timescale 1ns/1ps

`include "execute.v"

module execute_tb();

    reg clk, reset;

    // control signals
    reg RegWrite_D, MemWrite_D, Jump_D, Branch_D, MemRead_D;
    reg [1:0] MemToReg_D;
    reg [3:0] ALUCtrl_D;
    reg ALUSrc_D;

    // register data
    reg [63:0] rs1_data_D, rs2_data_D;
    reg [4:0] rs1_D, rs2_D, rd_D;

    // immediate
    reg [63:0] imm_D;

    // pc
    reg [63:0] pc_D, pc_plus_4_D;

    // forwarding
    reg [1:0] forwardA_E, forwardB_E;

    // outputs
    wire RegWrite_E, MemWrite_E, MemRead_E;
    wire [1:0] MemToReg_E;

    wire [63:0] alu_res_E;
    wire [63:0] write_data_E;
    wire [63:0] pc_tar_E;
    wire [63:0] pc_plus_4_E;

    wire [4:0] rs1_E, rs2_E, rd_E;

    execute uut(
        .clk(clk),
        .reset(reset),

        .RegWrite_D(RegWrite_D),
        .MemWrite_D(MemWrite_D),
        .Jump_D(Jump_D),
        .Branch_D(Branch_D),
        .MemRead_D(MemRead_D),

        .MemToReg_D(MemToReg_D),
        .ALUCtrl_D(ALUCtrl_D),
        .ALUSrc_D(ALUSrc_D),

        .rs1_data_D(rs1_data_D),
        .rs2_data_D(rs2_data_D),

        .rs1_D(rs1_D),
        .rs2_D(rs2_D),
        .rd_D(rd_D),

        .imm_D(imm_D),

        .pc_D(pc_D),
        .pc_plus_4_D(pc_plus_4_D),

        .forwardA_E(forwardA_E),
        .forwardB_E(forwardB_E),

        .RegWrite_E(RegWrite_E),
        .MemWrite_E(MemWrite_E),
        .MemRead_E(MemRead_E),

        .MemToReg_E(MemToReg_E),

        .alu_res_E(alu_res_E),
        .write_data_E(write_data_E),
        .pc_tar_E(pc_tar_E),

        .pc_plus_4_E(pc_plus_4_E),

        .rs1_E(rs1_E),
        .rs2_E(rs2_E),
        .rd_E(rd_E)
    );

    // clock generation
    always #5 clk = ~clk;

    initial begin

        $display("=== Execute Stage Testbench ===");

        clk = 0;
        reset = 1;

        RegWrite_D = 0;
        MemWrite_D = 0;
        Jump_D = 0;
        Branch_D = 0;
        MemRead_D = 0;

        MemToReg_D = 2'b00;
        ALUCtrl_D = 4'b0010;   // ADD
        ALUSrc_D = 0;

        rs1_data_D = 64'd10;
        rs2_data_D = 64'd20;

        rs1_D = 5'd1;
        rs2_D = 5'd2;
        rd_D  = 5'd3;

        imm_D = 64'd5;

        pc_D = 64'h1000;
        pc_plus_4_D = 64'h1004;

        forwardA_E = 2'b00;
        forwardB_E = 2'b00;

        #10;
        reset = 0;

        // Test normal ALU operation
        @(posedge clk);
        #1;
        $display("ADD: A=%d B=%d Result=%d", rs1_data_D, rs2_data_D, alu_res_E);

        // Test immediate ALU
        ALUSrc_D = 1'b1;
        @(posedge clk);
        #1;
        $display("ADDI: A=%d Imm=%d Result=%d", rs1_data_D, imm_D, alu_res_E);

        // Test forwarding
        forwardA_E = 2'b01;
        forwardB_E = 2'b10;

        @(posedge clk);
        #1;
        $display("Forwarding Test: Result=%d", alu_res_E);

        // Test branch
        Branch_D = 1'b1;
        @(posedge clk);
        #1;
        $display("Branch Target = %h", pc_tar_E);

        $finish;

    end

endmodule