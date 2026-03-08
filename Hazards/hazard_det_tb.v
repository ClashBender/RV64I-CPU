`timescale 1ns/1ps

module hazard_det_tb;
    reg [4:0] rs1_id;
    reg [4:0] rs2_id;
    reg [4:0] rd_ex;
    reg       mem_read_ex;
    reg       pc_src_mem;

    wire stall;
    wire flush;

    integer pass_count;
    integer fail_count;

    hazard_det dut (
        .rs1_id(rs1_id),
        .rs2_id(rs2_id),
        .rd_ex(rd_ex),
        .mem_read_ex(mem_read_ex),
        .pc_src_mem(pc_src_mem),
        .stall(stall),
        .flush(flush)
    );

    task run_case;
        input [4:0] t_rs1;
        input [4:0] t_rs2;
        input [4:0] t_rd;
        input       t_mem_read;
        input       t_pc_src;
        input       exp_stall;
        input       exp_flush;
        input [255:0] case_name;
        begin
            rs1_id = t_rs1;
            rs2_id = t_rs2;
            rd_ex = t_rd;
            mem_read_ex = t_mem_read;
            pc_src_mem = t_pc_src;
            #1;

            if (stall === exp_stall && flush === exp_flush) begin
                pass_count = pass_count + 1;
                $display("[PASS] %0s | rs1=%0d rs2=%0d rd=%0d mem_read=%0b pc_src=%0b -> stall=%0b flush=%0b",
                         case_name, rs1_id, rs2_id, rd_ex, mem_read_ex, pc_src_mem, stall, flush);
            end else begin
                fail_count = fail_count + 1;
                $display("[FAIL] %0s | got(stall=%0b, flush=%0b) exp(stall=%0b, flush=%0b)",
                         case_name, stall, flush, exp_stall, exp_flush);
            end
        end
    endtask

    initial begin
        pass_count = 0;
        fail_count = 0;

        // Case 1: No load-use hazard, no branch
        run_case(5'd1, 5'd2, 5'd3, 1'b0, 1'b0, 1'b0, 1'b0, "No hazard");

        // Case 2: Load-use hazard on rs1
        run_case(5'd5, 5'd2, 5'd5, 1'b1, 1'b0, 1'b1, 1'b0, "Load-use hazard via rs1");

        // Case 3: Load-use hazard on rs2
        run_case(5'd4, 5'd8, 5'd8, 1'b1, 1'b0, 1'b1, 1'b0, "Load-use hazard via rs2");

        // Case 4: mem_read active but rd_ex matches neither source register
        run_case(5'd7, 5'd9, 5'd1, 1'b1, 1'b0, 1'b0, 1'b0, "Load in EX but independent regs");

        // Case 5: Branch taken only -> flush
        run_case(5'd3, 5'd4, 5'd1, 1'b0, 1'b1, 1'b0, 1'b1, "Control hazard flush");

        // Case 6: Both load-use and branch true -> load-use condition has priority
        run_case(5'd10, 5'd11, 5'd10, 1'b1, 1'b1, 1'b1, 1'b0, "Load-use priority over branch");

        // Case 7: Boundary value check with register zero
        run_case(5'd0, 5'd15, 5'd0, 1'b1, 1'b0, 1'b1, 1'b0, "x0 match behavior");

        $display("\nSummary: PASS=%0d FAIL=%0d", pass_count, fail_count);
        if (fail_count == 0)
            $display("All hazard_det tests passed.");
        else
            $display("Some hazard_det tests failed.");

        $finish;
    end
endmodule
