`timescale 1ns/1ps
`define IMEM_SIZE 4096        // About 4 KiB of memory, so 512 instructions max.
`include "CPU_pipe.v"

module pipe_tb ();

    reg clk;
    reg reset;

    integer i,k;
    integer cycle_count = 0;
    integer reg_log;
    integer reg_file;
    integer data_log;
    CPU_pipe uut (
        .clk(clk), .reset(reset)
    );

    integer control = 0;
    initial begin
        clk = 0;
        reset = 1;

        $dumpfile("pipe_tb.vcd");
        $dumpvars(0, pipe_tb);

        // for (k = 0; k < 32; k = k + 1) begin
        //     $dumpvars(0, uut.ID_stage.reg_inst.registers[k]);
        // end


        // Load instructions into instruction memory
        if(control == 0)
            $readmemh("Testcases/haz_test_3.txt", uut.IF_stage.instr_memory.byte_mem);
        else if (control == 1)
            $readmemh("instructions.txt", uut.IF_stage.instr_memory.byte_mem);

        $display("\nLoaded instructions into instruction memory\n");

        for (i = 0; i < `IMEM_SIZE/4; i = i + 1) begin
            uut.IF_stage.instr_memory.inst_mem[i] = {
                uut.IF_stage.instr_memory.byte_mem[4*i],
                uut.IF_stage.instr_memory.byte_mem[4*i+1],
                uut.IF_stage.instr_memory.byte_mem[4*i+2],
                uut.IF_stage.instr_memory.byte_mem[4*i+3]
            };
        end

        $display("Starting program\n");
    
        #10; // hold reset
        reset = 0;

    end

    always #5 begin
        clk = ~clk; // 10ns clock period
        if(clk == 1'b1) begin
            cycle_count = cycle_count + 1;
        end
        
        if(uut.IF_stage.instr_F == 32'b0) begin

            // Write register and data memory values to respective logs, and to register_file.txt
            reg_log = $fopen("logs/register.txt", "w");
            reg_file = $fopen("register_file.txt", "w");
            data_log = $fopen("logs/data_memory.txt", "w");
           
            for (i = 0; i < 1024; i = i + 1) begin
                if(i<32) begin
                    $fwrite(reg_log, "x%0d: %h\n", i, uut.ID_stage.reg_inst.registers[i]);
                    $fwrite(reg_file, "%h\n", uut.ID_stage.reg_inst.registers[i]);
                end
                else if(i==32) begin
                    $fwrite(reg_log, "Clock Cycle: %d\n", cycle_count);
                    $fwrite(reg_file,"%0d", cycle_count);
                end

                $fwrite(data_log, "%0d: %h\n", i,  uut.MEM_stage.data_mem.data[i]);
                // if((i+1)%8 == 0)
                //     $fwrite(data_log, "\n");
            end

            $fclose(reg_log);
            $fclose(reg_file);
            $fclose(data_log);

            $display("Logs written to logs/register.txt and logs/data_memory.txt");

            reset =1'b1;
            $display("Simulation complete. register_file.txt produced. Reset asserted.\n");

            $finish;
        end
    end

endmodule

