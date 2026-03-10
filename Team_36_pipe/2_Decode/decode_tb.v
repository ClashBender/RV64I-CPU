`timescale 1ns/1ps
`include "decode.v"

module decode_tb;

    // general signals
    reg clk, reset; 

    // from prev (IF) stage
    reg [31:0] instr;
    reg [63:0] pc_F, pc_plus_4_F;

    // from WB stage 
    reg RegWrite_W;
    reg [4:0] rd_W;
    reg [63:0] result_W;

    // control signals
    wire RegWrite_D, MemWrite_D, Jump_D, Branch_D, MemRead_D;
    wire [1:0] MemToReg_D;
    wire [3:0] ALUCtrl_D;
    wire ALUSrc_D;

    // reg file results
    wire [63:0] rs1_data_D, rs2_data_D;
    wire [4:0] rs1_D, rs2_D, rd_D;
    
    // immediate value
    wire [63:0] imm_D;

    // pc values lmfao
    wire [63:0] pc_D, pc_plus_4_D;

    // Test tracking
    integer test_num;
    integer pass_count;
    integer fail_count;

    decode uut(
        .clk(clk),
        .reset(reset),
        .instr(instr),
        .pc_F(pc_F),
        .pc_plus_4_F(pc_plus_4_F),
        .RegWrite_W(RegWrite_W),
        .rd_W(rd_W),
        .result_W(result_W),
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
        .pc_plus_4_D(pc_plus_4_D)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Helper task to check control signals (for R-type, branches, stores)
    task check_control;
        input [31:0] test_instr;
        input expected_RegWrite;
        input expected_MemWrite;
        input expected_MemRead;
        input expected_Branch;
        input expected_Jump;
        input expected_ALUSrc;
        input [1:0] expected_MemToReg;
        input [3:0] expected_ALUCtrl;
        input [4:0] expected_rs1, expected_rs2, expected_rd;
        begin
            if (RegWrite_D !== expected_RegWrite || 
                MemWrite_D !== expected_MemWrite ||
                MemRead_D !== expected_MemRead ||
                Branch_D !== expected_Branch ||
                Jump_D !== expected_Jump ||
                ALUSrc_D !== expected_ALUSrc ||
                MemToReg_D !== expected_MemToReg ||
                ALUCtrl_D !== expected_ALUCtrl ||
                rs1_D !== expected_rs1 ||
                rs2_D !== expected_rs2 ||
                rd_D !== expected_rd) begin
                
                $display("FAIL: Test %0d", test_num);
                $display("  Instruction: 0x%h", test_instr);
                $display("  Expected: RegWrite=%b MemWrite=%b MemRead=%b Branch=%b Jump=%b", 
                         expected_RegWrite, expected_MemWrite, expected_MemRead, expected_Branch, expected_Jump);
                $display("  Got:      RegWrite=%b MemWrite=%b MemRead=%b Branch=%b Jump=%b", 
                         RegWrite_D, MemWrite_D, MemRead_D, Branch_D, Jump_D);
                $display("  Expected: ALUSrc=%b MemToReg=%b ALUCtrl=%b", 
                         expected_ALUSrc, expected_MemToReg, expected_ALUCtrl);
                $display("  Got:      ALUSrc=%b MemToReg=%b ALUCtrl=%b", 
                         ALUSrc_D, MemToReg_D, ALUCtrl_D);
                $display("  Expected: rs1=%d rs2=%d rd=%d", expected_rs1, expected_rs2, expected_rd);
                $display("  Got:      rs1=%d rs2=%d rd=%d", rs1_D, rs2_D, rd_D);
                fail_count = fail_count + 1;
            end else begin
                $display("PASS: Test %0d", test_num);
                pass_count = pass_count + 1;
            end
            test_num = test_num + 1;
        end
    endtask

    // Helper task for I-type instructions (no rs2 check since it uses immediate)
    task check_control_no_rs2;
        input [31:0] test_instr;
        input expected_RegWrite;
        input expected_MemWrite;
        input expected_MemRead;
        input expected_Branch;
        input expected_Jump;
        input expected_ALUSrc;
        input [1:0] expected_MemToReg;
        input [3:0] expected_ALUCtrl;
        input [4:0] expected_rs1, expected_rd;
        begin
            if (RegWrite_D !== expected_RegWrite || 
                MemWrite_D !== expected_MemWrite ||
                MemRead_D !== expected_MemRead ||
                Branch_D !== expected_Branch ||
                Jump_D !== expected_Jump ||
                ALUSrc_D !== expected_ALUSrc ||
                MemToReg_D !== expected_MemToReg ||
                ALUCtrl_D !== expected_ALUCtrl ||
                rs1_D !== expected_rs1 ||
                rd_D !== expected_rd) begin
                
                $display("FAIL: Test %0d", test_num);
                $display("  Instruction: 0x%h", test_instr);
                $display("  Expected: RegWrite=%b MemWrite=%b MemRead=%b Branch=%b Jump=%b", 
                         expected_RegWrite, expected_MemWrite, expected_MemRead, expected_Branch, expected_Jump);
                $display("  Got:      RegWrite=%b MemWrite=%b MemRead=%b Branch=%b Jump=%b", 
                         RegWrite_D, MemWrite_D, MemRead_D, Branch_D, Jump_D);
                $display("  Expected: ALUSrc=%b MemToReg=%b ALUCtrl=%b", 
                         expected_ALUSrc, expected_MemToReg, expected_ALUCtrl);
                $display("  Got:      ALUSrc=%b MemToReg=%b ALUCtrl=%b", 
                         ALUSrc_D, MemToReg_D, ALUCtrl_D);
                $display("  Expected: rs1=%d rd=%d", expected_rs1, expected_rd);
                $display("  Got:      rs1=%d rd=%d (rs2=%d is unused)", rs1_D, rd_D, rs2_D);
                fail_count = fail_count + 1;
            end else begin
                $display("PASS: Test %0d", test_num);
                pass_count = pass_count + 1;
            end
            test_num = test_num + 1;
        end
    endtask

    // Helper task for B-type instructions (no rd check since branches don't write registers)
    task check_control_branch;
        input [31:0] test_instr;
        input expected_RegWrite;
        input expected_MemWrite;
        input expected_MemRead;
        input expected_Branch;
        input expected_Jump;
        input expected_ALUSrc;
        input [1:0] expected_MemToReg;
        input [3:0] expected_ALUCtrl;
        input [4:0] expected_rs1, expected_rs2;
        begin
            if (RegWrite_D !== expected_RegWrite || 
                MemWrite_D !== expected_MemWrite ||
                MemRead_D !== expected_MemRead ||
                Branch_D !== expected_Branch ||
                Jump_D !== expected_Jump ||
                ALUSrc_D !== expected_ALUSrc ||
                MemToReg_D !== expected_MemToReg ||
                ALUCtrl_D !== expected_ALUCtrl ||
                rs1_D !== expected_rs1 ||
                rs2_D !== expected_rs2) begin
                
                $display("FAIL: Test %0d", test_num);
                $display("  Instruction: 0x%h", test_instr);
                $display("  Expected: RegWrite=%b MemWrite=%b MemRead=%b Branch=%b Jump=%b", 
                         expected_RegWrite, expected_MemWrite, expected_MemRead, expected_Branch, expected_Jump);
                $display("  Got:      RegWrite=%b MemWrite=%b MemRead=%b Branch=%b Jump=%b", 
                         RegWrite_D, MemWrite_D, MemRead_D, Branch_D, Jump_D);
                $display("  Expected: ALUSrc=%b MemToReg=%b ALUCtrl=%b", 
                         expected_ALUSrc, expected_MemToReg, expected_ALUCtrl);
                $display("  Got:      ALUSrc=%b MemToReg=%b ALUCtrl=%b", 
                         ALUSrc_D, MemToReg_D, ALUCtrl_D);
                $display("  Expected: rs1=%d rs2=%d", expected_rs1, expected_rs2);
                $display("  Got:      rs1=%d rs2=%d (rd=%d is unused)", rs1_D, rs2_D, rd_D);
                fail_count = fail_count + 1;
            end else begin
                $display("PASS: Test %0d", test_num);
                pass_count = pass_count + 1;
            end
            test_num = test_num + 1;
        end
    endtask

    // Helper task for J-type/JAL instructions (only rd, no source registers)
    task check_control_jal;
        input [31:0] test_instr;
        input expected_RegWrite;
        input expected_MemWrite;
        input expected_MemRead;
        input expected_Branch;
        input expected_Jump;
        input expected_ALUSrc;
        input [1:0] expected_MemToReg;
        input [3:0] expected_ALUCtrl;
        input [4:0] expected_rd;
        begin
            if (RegWrite_D !== expected_RegWrite || 
                MemWrite_D !== expected_MemWrite ||
                MemRead_D !== expected_MemRead ||
                Branch_D !== expected_Branch ||
                Jump_D !== expected_Jump ||
                ALUSrc_D !== expected_ALUSrc ||
                MemToReg_D !== expected_MemToReg ||
                ALUCtrl_D !== expected_ALUCtrl ||
                rd_D !== expected_rd) begin
                
                $display("FAIL: Test %0d", test_num);
                $display("  Instruction: 0x%h", test_instr);
                $display("  Expected: RegWrite=%b MemWrite=%b MemRead=%b Branch=%b Jump=%b", 
                         expected_RegWrite, expected_MemWrite, expected_MemRead, expected_Branch, expected_Jump);
                $display("  Got:      RegWrite=%b MemWrite=%b MemRead=%b Branch=%b Jump=%b", 
                         RegWrite_D, MemWrite_D, MemRead_D, Branch_D, Jump_D);
                $display("  Expected: ALUSrc=%b MemToReg=%b ALUCtrl=%b", 
                         expected_ALUSrc, expected_MemToReg, expected_ALUCtrl);
                $display("  Got:      ALUSrc=%b MemToReg=%b ALUCtrl=%b", 
                         ALUSrc_D, MemToReg_D, ALUCtrl_D);
                $display("  Expected: rd=%d", expected_rd);
                $display("  Got:      rd=%d (rs1=%d, rs2=%d are unused)", rd_D, rs1_D, rs2_D);
                fail_count = fail_count + 1;
            end else begin
                $display("PASS: Test %0d", test_num);
                pass_count = pass_count + 1;
            end
            test_num = test_num + 1;
        end
    endtask

    // Helper task to write to register file
    task write_register;
        input [4:0] reg_addr;
        input [63:0] value;
        begin
            @(posedge clk);
            RegWrite_W = 1'b1;
            rd_W = reg_addr;
            result_W = value;
            @(posedge clk);
            RegWrite_W = 1'b0;
        end
    endtask

    // Main test sequence
    initial begin
        $display("\n========================================");
        $display("   DECODE STAGE TESTBENCH");
        $display("========================================\n");
        
        // Initialize
        test_num = 1;
        pass_count = 0;
        fail_count = 0;
        
        clk = 0;
        reset = 1;
        instr = 32'h00000013;  // NOP
        pc_F = 64'h0;
        pc_plus_4_F = 64'h4;
        RegWrite_W = 0;
        rd_W = 0;
        result_W = 0;
        
        #10;
        reset = 0;
        #10;

        $display("\n--- Testing Cold Start (RegWrite_W = 0) ---");
        // Test 1: Verify that with RegWrite_W = 0, no spurious writes occur
        instr = 32'h00A58533;  // ADD x10, x11, x10
        RegWrite_W = 1'b0;  // Simulating cold start
        #10;
        check_control(instr, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b00, 4'b0000, 
                     5'd11, 5'd10, 5'd10);

        $display("\n--- Testing R-Type Instructions ---");
        
        // Initialize some registers for read testing
        write_register(5'd1, 64'h1234567890ABCDEF);
        write_register(5'd2, 64'hFEDCBA0987654321);
        write_register(5'd3, 64'h00000000FFFFFFFF);
        
        // Test 2: ADD x5, x1, x2
        instr = 32'h002082B3;  // ADD x5, x1, x2
        #10;
        check_control(instr, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b00, 4'b0000, 
                     5'd1, 5'd2, 5'd5);
        if (rs1_data_D !== 64'h1234567890ABCDEF || rs2_data_D !== 64'hFEDCBA0987654321) begin
            $display("  FAIL: Register read values incorrect");
            $display("    rs1_data_D = 0x%h (expected 0x1234567890ABCDEF)", rs1_data_D);
            $display("    rs2_data_D = 0x%h (expected 0xFEDCBA0987654321)", rs2_data_D);
            fail_count = fail_count + 1;
        end

        // Test 3: SUB x6, x2, x1
        instr = 32'h40110333;  // SUB x6, x2, x1
        #10;
        check_control(instr, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b00, 4'b1000, 
                     5'd2, 5'd1, 5'd6);

        // Test 4: AND x7, x1, x3
        instr = 32'h003173B3;  // AND x7, x2, x3
        #10;
        check_control(instr, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b00, 4'b0111, 
                     5'd2, 5'd3, 5'd7);

        // Test 5: OR x8, x1, x2
        instr = 32'h0020E433;  // OR x8, x1, x2
        #10;
        check_control(instr, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b00, 4'b0110, 
                     5'd1, 5'd2, 5'd8);

        // Test 6: XOR x9, x1, x2
        instr = 32'h0020C4B3;  // XOR x9, x1, x2
        #10;
        check_control(instr, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b00, 4'b0100, 
                     5'd1, 5'd2, 5'd9);

        // Test 7: SLL x10, x1, x2
        instr = 32'h00209533;  // SLL x10, x1, x2
        #10;
        check_control(instr, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b00, 4'b0001, 
                     5'd1, 5'd2, 5'd10);

        // Test 8: SRL x11, x1, x2
        instr = 32'h0020D5B3;  // SRL x11, x1, x2
        #10;
        check_control(instr, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b00, 4'b0101, 
                     5'd1, 5'd2, 5'd11);

        // Test 9: SRA x12, x1, x2
        instr = 32'h4020D633;  // SRA x12, x1, x2
        #10;
        check_control(instr, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b00, 4'b1101, 
                     5'd1, 5'd2, 5'd12);

        // Test 10: SLT x13, x1, x2
        instr = 32'h0020A6B3;  // SLT x13, x1, x2
        #10;
        check_control(instr, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b00, 4'b0010, 
                     5'd1, 5'd2, 5'd13);

        // Test 11: SLTU x14, x1, x2
        instr = 32'h0020B733;  // SLTU x14, x1, x2
        #10;
        check_control(instr, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b00, 4'b0011, 
                     5'd1, 5'd2, 5'd14);

        $display("\n--- Testing I-Type ALU Instructions ---");

        // Test 12: ADDI x15, x1, 100
        instr = 32'h06408793;  // ADDI x15, x1, 100
        #10;
        check_control_no_rs2(instr, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 2'b00, 4'b0000, 
                     5'd1, 5'd15);
        if (imm_D !== 64'd100) begin
            $display("  FAIL: Immediate value incorrect. Got 0x%h, expected 0x64", imm_D);
            fail_count = fail_count + 1;
        end

        // Test 13: ANDI x16, x2, -1
        instr = 32'hFFF17813;  // ANDI x16, x2, -1
        #10;
        check_control_no_rs2(instr, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 2'b00, 4'b0111, 
                     5'd2, 5'd16);
        if (imm_D !== 64'hFFFFFFFFFFFFFFFF) begin
            $display("  FAIL: Immediate value incorrect. Got 0x%h, expected 0xFFFFFFFFFFFFFFFF", imm_D);
            fail_count = fail_count + 1;
        end

        // Test 14: ORI x17, x1, 0xFF
        instr = 32'h0FF0E893;  // ORI x17, x1, 0xFF
        #10;
        check_control_no_rs2(instr, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 2'b00, 4'b0110, 
                     5'd1, 5'd17);

        // Test 15: XORI x18, x2, 0xA5
        instr = 32'h0A514913;  // XORI x18, x2, 0xA5
        #10;
        check_control_no_rs2(instr, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 2'b00, 4'b0100, 
                     5'd2, 5'd18);

        // Test 16: SLLI x19, x1, 5
        instr = 32'h00509993;  // SLLI x19, x1, 5
        #10;
        check_control_no_rs2(instr, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 2'b00, 4'b0001, 
                     5'd1, 5'd19);

        // Test 17: SRLI x20, x2, 3
        instr = 32'h00315A13;  // SRLI x20, x2, 3
        #10;
        check_control_no_rs2(instr, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 2'b00, 4'b0101, 
                     5'd2, 5'd20);

        // Test 18: SRAI x21, x1, 7
        instr = 32'h4070DA93;  // SRAI x21, x1, 7
        #10;
        check_control_no_rs2(instr, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 2'b00, 4'b1101, 
                     5'd1, 5'd21);

        // Test 19: SLTI x22, x1, -50
        instr = 32'hFCE0AB13;  // SLTI x22, x1, -50
        #10;
        check_control_no_rs2(instr, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 2'b00, 4'b0010, 
                     5'd1, 5'd22);

        // Test 20: SLTIU x23, x2, 200
        instr = 32'h0C813B93;  // SLTIU x23, x2, 200
        #10;
        check_control_no_rs2(instr, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 2'b00, 4'b0011, 
                     5'd2, 5'd23);

        $display("\n--- Testing Load Instructions ---");

        // Test 21: LD x24, 16(x2)
        instr = 32'h01013C03;  // LD x24, 16(x2)
        #10;
        check_control_no_rs2(instr, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 1'b1, 2'b01, 4'b0000, 
                     5'd2, 5'd24);
        if (imm_D !== 64'd16) begin
            $display("  FAIL: Immediate value incorrect. Got 0x%h, expected 0x10", imm_D);
            fail_count = fail_count + 1;
        end

        // Test 22: LD x25, -8(x2)
        instr = 32'hFF813C83;  // LD x25, -8(x2)
        #10;
        check_control_no_rs2(instr, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 1'b1, 2'b01, 4'b0000, 
                     5'd2, 5'd25);
        if (imm_D !== 64'hFFFFFFFFFFFFFFF8) begin
            $display("  FAIL: Immediate value incorrect. Got 0x%h, expected 0xFFFFFFFFFFFFFFF8", imm_D);
            fail_count = fail_count + 1;
        end

        $display("\n--- Testing Store Instructions ---");

        // Test 23: SD x3, 24(x2)
        instr = 32'h00313C23;  // SD x3, 24(x2)
        #10;
        check_control(instr, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b1, 2'b00, 4'b0000, 
                     5'd2, 5'd3, 5'd24);
        if (imm_D !== 64'd24) begin
            $display("  FAIL: Immediate value incorrect. Got 0x%h, expected 0x18", imm_D);
            fail_count = fail_count + 1;
        end

        // Test 24: SD x2, -16(x3)
        instr = 32'hFE21B823;  // SD x2, -16(x3)
        #10;
        check_control(instr, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b1, 2'b00, 4'b0000, 
                     5'd3, 5'd2, 5'd16);
        if (imm_D !== 64'hFFFFFFFFFFFFFFF0) begin
            $display("  FAIL: Immediate value incorrect. Got 0x%h, expected 0xFFFFFFFFFFFFFFF0", imm_D);
            fail_count = fail_count + 1;
        end

        $display("\n--- Testing Branch Instructions ---");

        // Test 25: BEQ x1, x2, 32
        instr = 32'h02208063;  // BEQ x1, x2, 32
        #10;
        check_control_branch(instr, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 2'b00, 4'b1000, 
                     5'd1, 5'd2);
        if (imm_D !== 64'd32) begin
            $display("  FAIL: Immediate value incorrect. Got 0x%h, expected 0x20", imm_D);
            fail_count = fail_count + 1;
        end

        // Test 26: BNE x2, x3, -8
        instr = 32'hFE311CE3;  // BNE x2, x3, -8
        #10;
        check_control_branch(instr, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 2'b00, 4'b1000, 
                     5'd2, 5'd3);
        if (imm_D !== 64'hFFFFFFFFFFFFFFF8) begin
            $display("  FAIL: Immediate value incorrect. Got 0x%h, expected 0xFFFFFFFFFFFFFFF8", imm_D);
            fail_count = fail_count + 1;
        end

        // Test 27: BLT x1, x3, 8
        instr = 32'h0030C463;  // BLT x1, x3, 8
        #10;
        check_control_branch(instr, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 2'b00, 4'b1000, 
                     5'd1, 5'd3);

        // Test 28: BGE x2, x1, 12
        instr = 32'h00115663;  // BGE x2, x1, 12
        #10;
        check_control_branch(instr, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 2'b00, 4'b1000, 
                     5'd2, 5'd1);

        // Test 29: BLTU x1, x2, 20
        instr = 32'h0020EA63;  // BLTU x1, x2, 20
        #10;
        check_control_branch(instr, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 2'b00, 4'b1000, 
                     5'd1, 5'd2);

        // Test 30: BGEU x3, x2, 24
        instr = 32'h0021FC63;  // BGEU x3, x2, 24
        #10;
        check_control_branch(instr, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 2'b00, 4'b1000, 
                     5'd3, 5'd2);

        $display("\n--- Testing Jump Instructions ---");

        // Test 31: JAL x26, 100
        instr = 32'h064000EF;  // JAL x1, 100
        #10;
        check_control_jal(instr, 1'b1, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 2'b10, 4'b0000, 
                     5'd1);
        if (imm_D !== 64'd100) begin
            $display("  FAIL: Immediate value incorrect. Got 0x%h, expected 0x64", imm_D);
            fail_count = fail_count + 1;
        end

        // Test 32: JAL x27, -256
        instr = 32'hF01FFDEF;  // JAL x27, -256
        #10;
        check_control_jal(instr, 1'b1, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 2'b10, 4'b0000, 
                     5'd27);
        if (imm_D !== 64'hFFFFFFFFFFFFFF00) begin
            $display("  FAIL: Immediate value incorrect. Got 0x%h, expected 0xFFFFFFFFFFFFFF00", imm_D);
            fail_count = fail_count + 1;
        end

        // Test 33: JALR x1, 8(x1)
        instr = 32'h008080E7;  // JALR x1, 8(x1)
        #10;
        check_control_no_rs2(instr, 1'b1, 1'b0, 1'b0, 1'b0, 1'b1, 1'b1, 2'b10, 4'b0000, 
                     5'd1, 5'd1);
        if (imm_D !== 64'd8) begin
            $display("  FAIL: Immediate value incorrect. Got 0x%h, expected 0x8", imm_D);
            fail_count = fail_count + 1;
        end

        $display("\n--- Testing PC Propagation ---");

        // Test 34: Verify PC values pass through correctly
        pc_F = 64'h1000;
        pc_plus_4_F = 64'h1004;
        instr = 32'h00000013;  // NOP (ADDI x0, x0, 0)
        #10;
        if (pc_D !== 64'h1000 || pc_plus_4_D !== 64'h1004) begin
            $display("FAIL: Test %0d - PC propagation", test_num);
            $display("  Expected: pc_D=0x%h pc_plus_4_D=0x%h", 64'h1000, 64'h1004);
            $display("  Got:      pc_D=0x%h pc_plus_4_D=0x%h", pc_D, pc_plus_4_D);
            fail_count = fail_count + 1;
        end else begin
            $display("PASS: Test %0d - PC propagation", test_num);
            pass_count = pass_count + 1;
        end
        test_num = test_num + 1;

        $display("\n--- Testing Register Writeback from WB Stage ---");

        // Test 35: Write to x5 and read it in next instruction
        write_register(5'd5, 64'hDEADBEEFCAFEBABE);
        instr = 32'h00628333;  // ADD x6, x5, x6
        #10;
        if (rs1_data_D !== 64'hDEADBEEFCAFEBABE) begin
            $display("FAIL: Test %0d - Register writeback from WB stage", test_num);
            $display("  Expected rs1_data_D = 0xDEADBEEFCAFEBABE");
            $display("  Got rs1_data_D = 0x%h", rs1_data_D);
            fail_count = fail_count + 1;
        end else begin
            $display("PASS: Test %0d - Register writeback from WB stage", test_num);
            pass_count = pass_count + 1;
        end
        test_num = test_num + 1;

        $display("\n========================================");
        $display("   TEST SUMMARY");
        $display("========================================");
        $display("Total Tests: %0d", pass_count + fail_count);
        $display("Passed:      %0d", pass_count);
        $display("Failed:      %0d", fail_count);
        $display("========================================\n");

        if (fail_count == 0) begin
            $display("*** ALL TESTS PASSED! ***\n");
        end else begin
            $display("*** SOME TESTS FAILED ***\n");
        end

        $finish;
    end

endmodule