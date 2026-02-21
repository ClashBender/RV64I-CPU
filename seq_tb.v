`timescale 1ns/1ps
`define IMEM_SIZE 4096        // About 4 KiB of memory, so 512 instructions max.
`include "CPU.v"

module cpu_tb ();

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
        $readmemh("instructions.txt", uut.A2.byte_mem);

        for (i = 0; i < `IMEM_SIZE/4; i = i + 1) begin
            inst_mem[i] = {
                byte_mem[4*i],
                byte_mem[4*i+1],
                byte_mem[4*i+2],
                byte_mem[4*i+3]
            };
        end
        


        #10; // hold reset for 10ns
        reset = 0;
    end

    always #5 begin

        $display("Instruction: %h | PC: %h | RegWrite: %b | MemRead: %b | MemWrite: %b | ALUOp: %b | ALUSrc: %b | MemToReg: %b",
                  uut.instr, uut.pc.pc_out, uut.mcu.RegWrite, uut.mcu.MemRead, uut.mcu.MemWrite, uut.mcu.ALUOp, uut.mcu.ALUSrc, uut.mcu.MemToReg);
       
       if(uut.instr == 32'h0) begin
            $display("Final Register State:");
            for (i = 0; i < 32; i = i + 1) begin
                $display("x%0d: %h", i, uut.rf.registers[i]);
            end
            
            // Write register values to file
            reg_file = $fopen("logs/register.txt", "w");
            for (i = 0; i < 32; i = i + 1) begin
                $fwrite(reg_file, "x%0d: %h\n", i, uut.rf.registers[i]);
            end
            $fclose(reg_file);

            // Write Data memory values to file
            data_file = $fopen("logs/data_memory.txt", "w");
            for (i = 0; i < 32; i = i + 1) begin
                $fwrite(data_file, "x%0d: %h\n", i, uut.A8.data[i]);
            end
            $fclose(data_file);
            $display("Logs written to logs/register.txt and logs/data_memory.txt");

            reset =1'b1;
            $display("Simulation complete. Reset asserted.");


            $finish;
        end



        clk = ~clk; // 10ns clock period
    end



endmodule