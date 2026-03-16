`timescale 1ns/1ps
`define IMEM_SIZE 4096        // About 4 KiB of memory, so 512 instructions max.
`include "src/arch/CPU_seq.v"

module seq_tb ();

    reg clk;
    reg reset;

    integer i;
    integer cycle_count =0;
    integer reg_log;
    integer reg_file;
    integer data_log;

    CPU_seq uut (
        .clk(clk), .reset(reset)
    );

    parameter MAX_CYCLES = 10000;

    initial begin
        clk = 0;
        reset = 1;
        
        $dumpfile("seq_tb.vcd");
        $dumpvars(0, seq_tb);

        // Reset instruction memory
        for (i = 0; i < `IMEM_SIZE/4; i = i + 1) begin
            uut.A2.inst_mem[i] = 32'b0;
            uut.A2.byte_mem[4*i] = 8'b0;
            uut.A2.byte_mem[4*i+1] = 8'b0;
            uut.A2.byte_mem[4*i+2] = 8'b0;
            uut.A2.byte_mem[4*i+3] = 8'b0;
        end

        // Load instructions into instruction memory
        $readmemh("testcases/asm.txt", uut.A2.byte_mem);

        $display("\nLoaded instructions into instruction memory\n");

        for (i = 0; i < `IMEM_SIZE/4; i = i + 1) begin
            uut.A2.inst_mem[i] = {
                uut.A2.byte_mem[4*i],
                uut.A2.byte_mem[4*i+1],
                uut.A2.byte_mem[4*i+2],
                uut.A2.byte_mem[4*i+3]
            };
        end

        $display("Starting program\n");
    
        #10; // hold reset for 10ns
        reset = 0;

    end

    always #5 begin
        clk = ~clk; // 10ns clock period
        if(clk == 1'b1) begin
            cycle_count = cycle_count + 1;
        end 

        if(uut.A2.instr == 32'b0) begin
            
            // Write register and data memory values to respective logs, and to register_file.txt
            reg_log = $fopen("logs/register.txt", "w");
            data_log = $fopen("logs/data_memory.txt", "w");
           
            for (i = 0; i < 1024; i = i + 1) begin
                if(i<32)
                    //$display("x%0d: %h", i, uut.A3.registers[i]);
                    $fwrite(reg_log, "x%0d: %h\n", i, uut.A3.registers[i]);
                else if(i==32)
                    $fwrite(reg_log, "Clock Cycle: %d\n", cycle_count);

                $fwrite(data_log, "%h ", uut.A8.data[i]);
                if((i+1)%8 == 0) begin
                    $fwrite(data_log, "\n");
                    $fwrite(data_log, "%0d: ", ((i+1)/8));
                end
            end

            $fclose(reg_log);
            $fclose(data_log);

            $display("Logs written to logs/register.txt and logs/data_memory.txt");

            reset =1'b1;
            $display("Simulation complete.\n");

            $finish;
        end
    end

endmodule
