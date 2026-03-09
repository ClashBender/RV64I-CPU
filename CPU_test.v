`timescale 1ns/1ps
`include "CPU_pipe.v"
module CPU_test;

reg clk;
reg reset;

integer errors;
integer i;
`define IMEM_SIZE 4096

// Instantiate CPU
CPU_pipe dut (
    .clk(clk),
    .reset(reset)
);



// Clock generation (10ns period)
always #5 clk = ~clk;



// Monitor writeback stage
always @(posedge clk) begin
    if(dut.RegWrite_W) begin
        $display("WB: x%0d = %0d", dut.rd_W, dut.result_W);
    end
end



initial begin

    clk = 0;
    reset = 1;
    errors = 0;

    $display("===== PIPELINED CPU TEST START =====");

    // Load instructions into instruction memory
    $readmemh("Testcases/simple.txt", dut.IF_stage.instr_Fuction_memory.byte_mem);
    
    $display("Loaded instructions into instruction memory\n");

    // Convert byte_mem to inst_mem
    for (i = 0; i < `IMEM_SIZE/4; i = i + 1) begin
        dut.IF_stage.instr_Fuction_memory.inst_mem[i] = {
            dut.IF_stage.instr_Fuction_memory.byte_mem[4*i],
            dut.IF_stage.instr_Fuction_memory.byte_mem[4*i+1],
            dut.IF_stage.instr_Fuction_memory.byte_mem[4*i+2],
            dut.IF_stage.instr_Fuction_memory.byte_mem[4*i+3]
        };
    end

    // Apply reset
    #20;
    reset = 0;

    // Run CPU long enough for pipeline to complete
    #500;



    // =====================================================
    // CHECK EXPECTED RESULTS
    // (Modify according to the program in instruction memory)
    // =====================================================

    // Example expectations:
    // addi x1,x0,5
    // addi x2,x0,10
    // add  x3,x1,x2

    if (dut.ID_stage.reg_inst.registers[1] !== 64'd5) begin
        $display("FAIL: x1 incorrect");
        errors = errors + 1;
    end

    if (dut.ID_stage.reg_inst.registers[2] !== 64'd10) begin
        $display("FAIL: x2 incorrect");
        errors = errors + 1;
    end

    if (dut.ID_stage.reg_inst.registers[3] !== 64'd15) begin
        $display("FAIL: x3 incorrect");
        errors = errors + 1;
    end



    // =====================================================
    // FINAL RESULT
    // =====================================================

    if(errors == 0) begin
        $display("\n========================");
        $display("       TEST PASSED");
        $display("========================");
    end
    else begin
        $display("\n========================");
        $display("       TEST FAILED");
        $display("Errors: %0d", errors);
        $display("========================");
    end

    $finish;

end

endmodule