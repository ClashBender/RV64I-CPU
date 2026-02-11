`timescale 1ns / 1ps

module mcu_tb();

    reg [6:0] opcode;
    wire branch;
    wire MemRead;
    wire MemToReg;
    wire [1:0] ALUOp;
    wire MemWrite;
    wire ALUSrc;
    wire RegWrite;
    
    mcu uut (
        .opcode(opcode),
        .branch(branch),
        .MemRead(MemRead),
        .MemToReg(MemToReg),
        .ALUOp(ALUOp),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite)
    );
    
    initial begin
        $dumpfile("mcu_tb.vcd");
        $dumpvars(0, mcu_tb);
        
        $display("Opcode   Branch MemRead MemToReg ALUOp MemWrite ALUSrc RegWrite\n");
        
        opcode = 7'b0000000;
        #10;
        
        // Test case 1: R-type instruction (0110011)
        $display("R-type instruction");
        opcode = 7'b0110011;
        #10;
        $display("%7b     %b      %b        %b      %2b      %b       %b       %b", 
                 opcode, branch, MemRead, MemToReg, ALUOp, MemWrite, ALUSrc, RegWrite);
        
        // Expected: RegWrite=1, ALUOp=10, ALUSrc=0, others=0
        if (RegWrite !== 1'b1 || ALUOp !== 2'b10 || ALUSrc !== 1'b0 || 
            branch !== 1'b0 || MemRead !== 1'b0 || MemToReg !== 1'b0 || MemWrite !== 1'b0)
            $display("FAIL");
        else
            $display("PASS");
        
        // Test case 2: I-type instruction (0010011)
        $display("I-type instruction");
        opcode = 7'b0010011;
        #10;
        $display("%7b     %b      %b        %b      %2b      %b       %b       %b", 
                 opcode, branch, MemRead, MemToReg, ALUOp, MemWrite, ALUSrc, RegWrite);
        
        // Expected: RegWrite=1, ALUOp=10, ALUSrc=1, others=0
        if (RegWrite !== 1'b1 || ALUOp !== 2'b10 || ALUSrc !== 1'b1 || 
            branch !== 1'b0 || MemRead !== 1'b0 || MemToReg !== 1'b0 || MemWrite !== 1'b0)
            $display("FAIL");
        else
            $display("PASS");
        
        // Test case 3: Load instruction (0000011)
        $display("Load instruction");
        opcode = 7'b0000011;
        #10;
        $display("%7b     %b      %b        %b      %2b      %b       %b       %b", 
                 opcode, branch, MemRead, MemToReg, ALUOp, MemWrite, ALUSrc, RegWrite);
        
        // Expected: RegWrite=1, ALUSrc=1, MemRead=1, MemToReg=1, others=0
        if (RegWrite !== 1'b1 || ALUSrc !== 1'b1 || MemRead !== 1'b1 || MemToReg !== 1'b1 ||
            branch !== 1'b0 || ALUOp !== 2'b00 || MemWrite !== 1'b0)
            $display("FAIL");
        else
            $display("PASS");
        
        // Test case 4: Store instruction (0100011)
        $display("Store instruction");
        opcode = 7'b0100011;
        #10;
        $display("%7b     %b      %b        %b      %2b      %b       %b       %b", 
                 opcode, branch, MemRead, MemToReg, ALUOp, MemWrite, ALUSrc, RegWrite);
        
        // Expected: MemWrite=1, ALUSrc=1, others=0
        if (MemWrite !== 1'b1 || ALUSrc !== 1'b1 || 
            RegWrite !== 1'b0 || branch !== 1'b0 || MemRead !== 1'b0 || MemToReg !== 1'b0 || ALUOp !== 2'b00)
            $display("FAIL");
        else
            $display("PASS");
        
        // Test case 5: Branch instruction (1100011)
        $display("Branch instruction");
        opcode = 7'b1100011;
        #10;
        $display("%7b     %b      %b        %b      %2b      %b       %b       %b", 
                 opcode, branch, MemRead, MemToReg, ALUOp, MemWrite, ALUSrc, RegWrite);
        
        // Expected: branch=1, ALUOp=01, others=0
        if (branch !== 1'b1 || ALUOp !== 2'b01 || 
            RegWrite !== 1'b0 || MemRead !== 1'b0 || MemToReg !== 1'b0 || MemWrite !== 1'b0 || ALUSrc !== 1'b0)
            $display("FAIL");
        else
            $display("PASS");
        
        // Test case 6: Invalid/Unknown opcode
        $display("unknown opcode");
        opcode = 7'b1111111;
        #10;
        $display("%7b     %b      %b        %b      %2b      %b       %b       %b", 
                 opcode, branch, MemRead, MemToReg, ALUOp, MemWrite, ALUSrc, RegWrite);
        
        // Expected: All outputs should be 0 (default case)
        if (branch !== 1'b0 || MemRead !== 1'b0 || MemToReg !== 1'b0 || ALUOp !== 2'b00 || 
            MemWrite !== 1'b0 || ALUSrc !== 1'b0 || RegWrite !== 1'b0)
            $display("FAIL");
        else
            $display("PASS");
        
        $finish;
    end

endmodule