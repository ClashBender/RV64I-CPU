`timescale 1ns/1ps
`include "fetch.v"

module fetch_tb();

    reg clk, reset;
    reg [63:0] pc_plus_imm;
    reg PCSrc;
    wire [63:0] pc_out;
    wire [31:0] instr;

    fetch uut(
        .clk(clk),
        .reset(reset),
        .pc_plus_imm(pc_plus_imm),
        .PCSrc(PCSrc),
        .pc_out(pc_out),
        .instr(instr)
    );

    always #5 clk = ~clk;

    // Task to initialize instruction memory from instructions.txt
    task init_instruction_memory;
        reg [7:0] byte_mem [0:4095];
        integer i;
        begin
            // Read byte data from instructions.txt
            $readmemh("instructions.txt", byte_mem);
            
            // Load bytes into instruction memory (4 bytes per instruction)
            for (i = 0; i < 1024; i = i + 1) begin
                uut.instruction_memory.inst_mem[i] = {
                    byte_mem[4*i],
                    byte_mem[4*i+1], 
                    byte_mem[4*i+2],
                    byte_mem[4*i+3]
                };
            end
            
            $display("Instruction memory initialization complete.");
            $display("Sample instructions loaded:");
            $display("Address 0x00: 0x%08h", uut.instruction_memory.inst_mem[0]);
            $display("Address 0x04: 0x%08h", uut.instruction_memory.inst_mem[1]);
            $display("Address 0x08: 0x%08h", uut.instruction_memory.inst_mem[2]);
            $display("Address 0x0C: 0x%08h", uut.instruction_memory.inst_mem[3]);
            $display("Address 0x10: 0x%08h", uut.instruction_memory.inst_mem[4]);
            $display("Address 0x14: 0x%08h", uut.instruction_memory.inst_mem[5]);
            $display("Address 0x18: 0x%08h", uut.instruction_memory.inst_mem[6]);
            $display("Address 0x1C: 0x%08h", uut.instruction_memory.inst_mem[7]);
            $display("Address 0x20: 0x%08h", uut.instruction_memory.inst_mem[8]);
            $display("Address 0x24: 0x%08h", uut.instruction_memory.inst_mem[9]);
        end
    endtask

    initial begin
        $display("=== Fetch Module Testbench with Instruction Memory ===");
        
        // Initialize signals
        clk = 0;
        reset = 1;
        #10;
        
        // Initialize instruction memory
        init_instruction_memory();
        #10;
        reset = 0;
        PCSrc = 0;
        pc_plus_imm = 64'h0;
        #5;

        $display("PC = 0x%016h, Instruction = 0x%08h", pc_out, instr);
        #10;
        $display("PC = 0x%016h, Instruction = 0x%08h", pc_out, instr);
        #10;
        $display("PC = 0x%016h, Instruction = 0x%08h", pc_out, instr);
        #10;
        $display("PC = 0x%016h, Instruction = 0x%08h", pc_out, instr);
        #10;
        $display("PC = 0x%016h, Instruction = 0x%08h", pc_out, instr);
        #10;
        $display("PC = 0x%016h, Instruction = 0x%08h", pc_out, instr);
        #10;
        $display("PC = 0x%016h, Instruction = 0x%08h", pc_out, instr);
        #10;
        $display("PC = 0x%016h, Instruction = 0x%08h", pc_out, instr);
        #10;
        $display("PC = 0x%016h, Instruction = 0x%08h", pc_out, instr);
        #10;
        $display("PC = 0x%016h, Instruction = 0x%08h", pc_out, instr);
        #10;
        $finish;
    end

endmodule