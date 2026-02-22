`timescale 1ns/1ps
`define IMEM_SIZE 4096        // About 4 KiB of memory, so 512 instructions max.
`include "CPU.v"

module seq_tb ();

    reg clk;
    reg reset;

    integer i;
    integer reg_file;
    integer data_file;

    CPU uut (
        .clk(clk), .reset(reset)
    );

    initial begin
        clk = 0;
        reset = 1;
        
        // Load instructions into instruction memory
        $readmemh("Testcases_Hex/simple.txt", uut.A2.byte_mem);

        $display("Loaded instructions into instruction memory...");

        for (i = 0; i < `IMEM_SIZE/4; i = i + 1) begin
            uut.A2.inst_mem[i] = {
                uut.A2.byte_mem[4*i],
                uut.A2.byte_mem[4*i+1],
                uut.A2.byte_mem[4*i+2],
                uut.A2.byte_mem[4*i+3]
            };
        end

        $display("Instruction memory initialized from byte memory...");
        


        #10; // hold reset for 10ns
        reset = 0;

        #30;
        $display("Instruction: %h", uut.A2.inst_mem[10]);
    end

    always #5 begin
        clk = ~clk; // 10ns clock period
        $display("Time: %0t | PC: %h | Instr: %h | addr: %h | Write enable: %b", 
             $time, uut.A1.pc_out, uut.A2.instr, uut.A8.address, uut.A4.MemWrite);
    
    
        

    
        // $display("Instruction: %h | PC: %h | RegWrite: %b | MemRead: %b | MemWrite: %b | ALUOp: %b | ALUSrc: %b | MemToReg: %b",
        //           uut.instr, uut.A1.pc_out, uut.A3.RegWrite, uut.mcu.MemRead, uut.mcu.MemWrite, uut.mcu.ALUOp, uut.mcu.ALUSrc, uut.mcu.MemToReg);
       
    
        if(uut.A2.instr == 32'b0) begin
            // Write register and data memory values to file
            reg_file = $fopen("logs/register.txt", "w");
            data_file = $fopen("logs/data_memory.txt", "w");

            $display("Final Register State:");
            for (i = 0; i < 1024; i = i + 1) begin
                if(i<32) begin
                    $display("x%0d: %h", i, uut.A3.registers[i]);
                    $fwrite(reg_file, "x%0d: %h\n", i, uut.A3.registers[i]);
                end

                $fwrite(data_file, "%0d: %h\n", i, uut.A8.data[i]);
            end
            $fclose(reg_file);
            $fclose(data_file);
            $display("Logs written to logs/register.txt and logs/data_memory.txt");

            // reset =1'b1;
            $display("Simulation complete. Reset asserted.");


            $finish;
        end
    end
    

        
    



endmodule