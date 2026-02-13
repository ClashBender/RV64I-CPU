`timescale 1ns / 1ps

module ALU_Control_tb;

    reg [1:0] ALUOp;
    reg [6:0] funct7;
    reg [2:0] funct3;
    reg inst5;
    wire [3:0] ALU_ctrl;
    
    integer test_count = 0;
    integer pass_count = 0;
    integer fail_count = 0;
    
    ALU_Control uut (
        .ALUOp(ALUOp),
        .funct7(funct7),
        .funct3(funct3),
        .inst5(inst5),
        .ALU_ctrl(ALU_ctrl)
    );

    task check_result;
        input [1:0] alu_op;
        input [6:0] func7;
        input [2:0] func3;
        input inst_5;
        input [3:0] expected;
        input [3:0] actual;
        input [300:0] test_name;
        begin
            test_count = test_count + 1;
            if (expected == actual) begin
                pass_count = pass_count + 1;
                $display("[PASS] %s", test_name);
            end else begin
                fail_count = fail_count + 1;
                $display("[FAIL] %s", test_name);
                $display("       ALUOp=%b, funct7=%b, funct3=%b, inst5=%b", alu_op, func7, func3, inst_5);
                $display("       Expected: %b, Got: %b", expected, actual);
            end
        end
    endtask

    initial begin

        $dumpfile("alu_ctrl_tb.vcd");
        $dumpvars(0, ALU_Control_tb);
        
        ALUOp = 2'b00;
        funct7 = 7'b0000000;
        funct3 = 3'b000;
        inst5 = 1'b0;
        #5;
        
        // EDGE CASE CATEGORY 1: ALUOp = 00 (Load/Store) 
        $display("Testing ALUOp = 00 (Load/Store Instructions):");
        
        ALUOp = 2'b00;
        
        // Test with all zeros
        funct7 = 7'b0000000; funct3 = 3'b000; inst5 = 1'b0;
        #10; check_result(ALUOp, funct7, funct3, inst5, 4'b0000, ALU_ctrl, "Load/Store with all inputs zero");
        
        // Test with maximum values (should be ignored)
        funct7 = 7'b1111111; funct3 = 3'b111; inst5 = 1'b1;
        #10; check_result(ALUOp, funct7, funct3, inst5, 4'b0000, ALU_ctrl, "Load/Store with max inputs (ignored)");
        
        // Test with random pattern (should be ignored)
        funct7 = 7'b1010101; funct3 = 3'b101; inst5 = 1'b0;
        #10; check_result(ALUOp, funct7, funct3, inst5, 4'b0000, ALU_ctrl, "Load/Store with random inputs (ignored)");
        
        // EDGE CASE CATEGORY 2: ALUOp = 01 (Branch)
        $display("\nTesting ALUOp = 01 (Branch Instructions):");
        
        ALUOp = 2'b01;
        
        // Test with all zeros
        funct7 = 7'b0000000; funct3 = 3'b000; inst5 = 1'b0;
        #10; check_result(ALUOp, funct7, funct3, inst5, 4'b1000, ALU_ctrl, "Branch with all inputs zero");
        
        // Test with maximum values (should be ignored)
        funct7 = 7'b1111111; funct3 = 3'b111; inst5 = 1'b1;
        #10; check_result(ALUOp, funct7, funct3, inst5, 4'b1000, ALU_ctrl, "Branch with max inputs (ignored)");
        
        // Test with alternating pattern (should be ignored)
        funct7 = 7'b0101010; funct3 = 3'b010; inst5 = 1'b1;
        #10; check_result(ALUOp, funct7, funct3, inst5, 4'b1000, ALU_ctrl, "Branch with alternating inputs (ignored)");
        
        // EDGE CASE CATEGORY 3: ALUOp = 10 (Arithmetic) 
        $display("\nTesting ALUOp = 10 - Critical inst5 Edge Cases:");
        
        ALUOp = 2'b10;
        
        // EDGE CASE: funct3 = 000 with inst5 variations
        funct3 = 3'b000;
        
        // ADD/ADDI: inst30=0, inst5=0 -> should be 0000
        funct7 = 7'b0000000; inst5 = 1'b0;
        #10; check_result(ALUOp, funct7, funct3, inst5, 4'b0000, ALU_ctrl, "ADD (inst30=0, inst5=0)");
        
        // ADDI: inst30=0, inst5=1 -> should be 0000 (is don't care)
        funct7 = 7'b0000000; inst5 = 1'b1;
        #10; check_result(ALUOp, funct7, funct3, inst5, 4'b0000, ALU_ctrl, "ADDI (inst30=0, inst5=1)");
        
        // SUB: inst30=1, inst5=1 -> should be 1000 
        funct7 = 7'b0100000; inst5 = 1'b1;
        #10; check_result(ALUOp, funct7, funct3, inst5, 4'b1000, ALU_ctrl, "SUB (inst30=1, inst5=1)");
        
        // CRITICAL EDGE CASE: inst30=1, inst5=0 -> should be 0000 (inst5=0 blocks inst30)
        funct7 = 7'b0100000; inst5 = 1'b0;
        #10; check_result(ALUOp, funct7, funct3, inst5, 4'b0000, ALU_ctrl, "EDGE: inst30=1 but inst5=0 blocks it");
        
        // EDGE CASE: funct3 = 101 with inst5 variations
        funct3 = 3'b101;
        
        // SRL: inst30=0, any inst5 -> should be 0101
        funct7 = 7'b0000000; inst5 = 1'b0;
        #10; check_result(ALUOp, funct7, funct3, inst5, 4'b0101, ALU_ctrl, "SRL (inst30=0, inst5=0)");
        
        funct7 = 7'b0000000; inst5 = 1'b1;
        #10; check_result(ALUOp, funct7, funct3, inst5, 4'b0101, ALU_ctrl, "SRLI (inst30=0, inst5=1)");
        
        // SRA: inst30=1, any inst5 -> should be 1101
        funct7 = 7'b0100000; inst5 = 1'b0;
        #10; check_result(ALUOp, funct7, funct3, inst5, 4'b1101, ALU_ctrl, "SRA (inst30=1, inst5=0)");
        
        funct7 = 7'b0100000; inst5 = 1'b1;
        #10; check_result(ALUOp, funct7, funct3, inst5, 4'b1101, ALU_ctrl, "SRAI (inst30=1, inst5=1)");
        
        // EDGE CASE CATEGORY 4: Boundary testing for funct7 bit patterns
        $display("\nTesting funct7 Boundary Conditions:");
        
        funct3 = 3'b010; // Use SLT for these tests
        inst5 = 1'b1;
        
        // Test that only bit 5 of funct7 matters, other bits are ignored
        funct7 = 7'b0000000; // Only bit 5 = 0
        #10; check_result(ALUOp, funct7, funct3, inst5, 4'b0010, ALU_ctrl, "funct7 all zeros except bit5=0");
        
        funct7 = 7'b0100000; // Only bit 5 = 1
        #10; check_result(ALUOp, funct7, funct3, inst5, 4'b0010, ALU_ctrl, "funct7 only bit5=1, rest=0");
        
        funct7 = 7'b1011111; // All bits except 5 = 1, bit 5 = 0
        #10; check_result(ALUOp, funct7, funct3, inst5, 4'b0010, ALU_ctrl, "funct7 all=1 except bit5=0");
        
        funct7 = 7'b1111111; // All bits = 1, bit 5 = 1  
        #10; check_result(ALUOp, funct7, funct3, inst5, 4'b0010, ALU_ctrl, "funct7 all bits=1");
        
        // EDGE CASE CATEGORY 5: All funct3 combinations with edge conditions
        $display("\nTesting All funct3 Values with Edge Conditions:");
        
        inst5 = 1'b1; 
        funct7 = 7'b0000000;
        
        for (integer i = 0; i < 8; i = i + 1) begin
            funct3 = i;
            #10;
            case (i)
                3'b000: check_result(ALUOp, funct7, funct3, inst5, 4'b0000, ALU_ctrl, "funct3=000 (ADD/ADDI)");
                3'b001: check_result(ALUOp, funct7, funct3, inst5, 4'b0001, ALU_ctrl, "funct3=001 (SLL/SLLI)");
                3'b010: check_result(ALUOp, funct7, funct3, inst5, 4'b0010, ALU_ctrl, "funct3=010 (SLT/SLTI)");
                3'b011: check_result(ALUOp, funct7, funct3, inst5, 4'b0011, ALU_ctrl, "funct3=011 (SLTU/SLTIU)");
                3'b100: check_result(ALUOp, funct7, funct3, inst5, 4'b0100, ALU_ctrl, "funct3=100 (XOR/XORI)");
                3'b101: check_result(ALUOp, funct7, funct3, inst5, 4'b0101, ALU_ctrl, "funct3=101 (SRL/SRLI)");
                3'b110: check_result(ALUOp, funct7, funct3, inst5, 4'b0110, ALU_ctrl, "funct3=110 (OR/ORI)");
                3'b111: check_result(ALUOp, funct7, funct3, inst5, 4'b0111, ALU_ctrl, "funct3=111 (AND/ANDI)");
            endcase
        end
        
        $display("\n=== TEST SUMMARY ===");
        $display("Total Tests: %0d", test_count);
        $display("Passed: %0d", pass_count);
        $display("Failed: %0d", fail_count);
        $display("Success Rate: %0.1f%%", (pass_count * 100.0) / test_count);
        
        $finish;
    end

endmodule
