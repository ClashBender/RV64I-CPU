`timescale 1ns/1ps
`include "forward.v"

module forward_tb;

    reg [4:0] rs1_d, rs2_d, rs1_e, rs2_e, rs2_m;
    reg [4:0] rd_e, rd_m, rd_w;
    reg reg_write_m, mem_write_m, reg_write_w;
    reg [1:0] mem_to_reg_e;
    wire [1:0] forward_ae, forward_be;
    wire forward_m;
    wire stall_d, stall_f;

    integer passed, failed;

    forward uut(
        .rs1_d(rs1_d),
        .rs2_d(rs2_d),
        .rs1_e(rs1_e),
        .rs2_e(rs2_e),
        .rs2_m(rs2_m),
        .rd_e(rd_e),
        .rd_m(rd_m),
        .rd_w(rd_w),
        .reg_write_m(reg_write_m),
        .mem_write_m(mem_write_m),
        .reg_write_w(reg_write_w),
        .mem_to_reg_e(mem_to_reg_e),
        .forward_ae(forward_ae),
        .forward_be(forward_be),
        .forward_m(forward_m),
        .stall_d(stall_d),
        .stall_f(stall_f)
    );

    // Task to reset all inputs
    task reset_inputs;
    begin
        rs1_d = 0; rs2_d = 0;
        rs1_e = 0; rs2_e = 0; rs2_m = 0;
        rd_e = 0; rd_m = 0; rd_w = 0;
        reg_write_m = 0; mem_write_m = 0; reg_write_w = 0;
        mem_to_reg_e = 2'b00;
    end
    endtask

    // Task to check and report results
    task check;
        input [1:0] exp_fwd_ae, exp_fwd_be;
        input exp_fwd_m, exp_stall;
        input [255:0] test_name;
    begin
        #1;
        if (forward_ae === exp_fwd_ae && forward_be === exp_fwd_be && 
            forward_m === exp_fwd_m && stall_d === exp_stall) begin
            $display("PASS: %0s", test_name);
            passed = passed + 1;
        end else begin
            $display("FAIL: %0s", test_name);
            $display("  Expected: fwd_ae=%b, fwd_be=%b, fwd_m=%b, stall=%b",
                     exp_fwd_ae, exp_fwd_be, exp_fwd_m, exp_stall);
            $display("  Got:      fwd_ae=%b, fwd_be=%b, fwd_m=%b, stall=%b",
                     forward_ae, forward_be, forward_m, stall_d);
            failed = failed + 1;
        end
    end
    endtask

    initial begin
        $display("\n========================================");
        $display("    Forwarding Unit Testbench");
        $display("========================================\n");
        
        passed = 0;
        failed = 0;
        reset_inputs;
        #10;

        // =============================================
        // TEST 1: No hazard (no forwarding needed)
        // =============================================
        $display("--- No Hazard Tests ---");
        reset_inputs;
        rs1_e = 5'd1; rs2_e = 5'd2;
        rd_m = 5'd3; rd_w = 5'd4;
        reg_write_m = 1; reg_write_w = 1;
        check(2'b00, 2'b00, 1'b0, 1'b0, "No hazard - different registers");

        // =============================================
        // TEST 2: EX-MEM hazard for rs1
        // add x1, x2, x3  (in MEM, writes to x1)
        // sub x4, x1, x5  (in EX, reads x1)
        // =============================================
        $display("\n--- EX-MEM Hazard Tests ---");
        reset_inputs;
        rs1_e = 5'd1;       // EX stage reads x1
        rd_m = 5'd1;        // MEM stage writes x1
        reg_write_m = 1;
        check(2'b10, 2'b00, 1'b0, 1'b0, "EX-MEM hazard on rs1");

        // =============================================
        // TEST 3: EX-MEM hazard for rs2
        // add x2, x3, x4  (in MEM, writes to x2)
        // sub x5, x6, x2  (in EX, reads x2)
        // =============================================
        reset_inputs;
        rs2_e = 5'd2;       // EX stage reads x2
        rd_m = 5'd2;        // MEM stage writes x2
        reg_write_m = 1;
        check(2'b00, 2'b10, 1'b0, 1'b0, "EX-MEM hazard on rs2");

        // =============================================
        // TEST 4: EX-MEM hazard on both rs1 and rs2
        // add x1, x2, x3  (in MEM, writes to x1)
        // sub x4, x1, x1  (in EX, reads x1 twice)
        // =============================================
        reset_inputs;
        rs1_e = 5'd1; rs2_e = 5'd1;
        rd_m = 5'd1;
        reg_write_m = 1;
        check(2'b10, 2'b10, 1'b0, 1'b0, "EX-MEM hazard on both rs1 and rs2");

        // =============================================
        // TEST 5: MEM-WB hazard for rs1
        // add x1, x2, x3  (in WB, writes to x1)
        // nop             (in MEM)
        // sub x4, x1, x5  (in EX, reads x1)
        // =============================================
        $display("\n--- MEM-WB Hazard Tests ---");
        reset_inputs;
        rs1_e = 5'd1;       // EX stage reads x1
        rd_w = 5'd1;        // WB stage writes x1
        reg_write_w = 1;
        check(2'b01, 2'b00, 1'b0, 1'b0, "MEM-WB hazard on rs1");

        // =============================================
        // TEST 6: MEM-WB hazard for rs2
        // =============================================
        reset_inputs;
        rs2_e = 5'd2;       // EX stage reads x2
        rd_w = 5'd2;        // WB stage writes x2
        reg_write_w = 1;
        check(2'b00, 2'b01, 1'b0, 1'b0, "MEM-WB hazard on rs2");

        // =============================================
        // TEST 7: Priority - EX-MEM over MEM-WB
        // Both MEM and WB writing to same register
        // EX-MEM should take priority (more recent value)
        // =============================================
        $display("\n--- Priority Tests ---");
        reset_inputs;
        rs1_e = 5'd1;
        rd_m = 5'd1; rd_w = 5'd1;
        reg_write_m = 1; reg_write_w = 1;
        check(2'b10, 2'b00, 1'b0, 1'b0, "EX-MEM priority over MEM-WB for rs1");

        reset_inputs;
        rs2_e = 5'd2;
        rd_m = 5'd2; rd_w = 5'd2;
        reg_write_m = 1; reg_write_w = 1;
        check(2'b00, 2'b10, 1'b0, 1'b0, "EX-MEM priority over MEM-WB for rs2");

        // =============================================
        // TEST 8: x0 should never forward (always 0)
        // =============================================
        $display("\n--- x0 Register Tests ---");
        reset_inputs;
        rs1_e = 5'd0;       // Reading x0
        rd_m = 5'd0;        // MEM "writes" x0
        reg_write_m = 1;
        check(2'b00, 2'b00, 1'b0, 1'b0, "No forward for x0 on rs1 (EX-MEM)");

        reset_inputs;
        rs2_e = 5'd0;
        rd_w = 5'd0;
        reg_write_w = 1;
        check(2'b00, 2'b00, 1'b0, 1'b0, "No forward for x0 on rs2 (MEM-WB)");

        // =============================================
        // TEST 9: RegWrite disabled - no forwarding
        // =============================================
        $display("\n--- RegWrite Disabled Tests ---");
        reset_inputs;
        rs1_e = 5'd1;
        rd_m = 5'd1;
        reg_write_m = 0;    // Not writing!
        check(2'b00, 2'b00, 1'b0, 1'b0, "No forward when reg_write_m=0");

        reset_inputs;
        rs1_e = 5'd1;
        rd_w = 5'd1;
        reg_write_w = 0;    // Not writing!
        check(2'b00, 2'b00, 1'b0, 1'b0, "No forward when reg_write_w=0");

        // =============================================
        // TEST 10: Load-to-Store forwarding (ld -> sd)
        // ld x1, 0(x2)    (in WB, loaded value ready)
        // sd x1, 0(x3)    (in MEM, needs x1 value)
        // =============================================
        $display("\n--- Load-to-Store Forwarding Tests ---");
        reset_inputs;
        rd_w = 5'd1;        // WB has x1 loaded
        rs2_m = 5'd1;       // MEM store needs x1
        reg_write_w = 1;    // Load writes to register
        mem_write_m = 1;    // Store is writing to memory
        check(2'b00, 2'b00, 1'b1, 1'b0, "ld->sd forwarding");

        // No forward if rs2_m is x0
        reset_inputs;
        rd_w = 5'd0;
        rs2_m = 5'd0;
        reg_write_w = 1;
        mem_write_m = 1;
        check(2'b00, 2'b00, 1'b0, 1'b0, "No ld->sd forward for x0");

        // No forward if not a store
        reset_inputs;
        rd_w = 5'd1;
        rs2_m = 5'd1;
        reg_write_w = 1;
        mem_write_m = 0;    // Not a store
        check(2'b00, 2'b00, 1'b0, 1'b0, "No ld->sd forward when not storing");

        // =============================================
        // TEST 11: Load-Use Hazard (must stall)
        // ld x1, 0(x2)    (in EX, loading)
        // add x3, x1, x4  (in ID, needs x1)
        // =============================================
        $display("\n--- Load-Use Stall Tests ---");
        reset_inputs;
        rd_e = 5'd1;        // EX is loading to x1
        rs1_d = 5'd1;       // ID needs x1
        mem_to_reg_e = 2'b01; // Load instruction in EX
        check(2'b00, 2'b00, 1'b0, 1'b1, "Load-use stall on rs1");

        reset_inputs;
        rd_e = 5'd1;
        rs2_d = 5'd1;       // ID needs x1 on rs2
        mem_to_reg_e = 2'b01;
        check(2'b00, 2'b00, 1'b0, 1'b1, "Load-use stall on rs2");

        // Both rs1 and rs2 depend on load
        reset_inputs;
        rd_e = 5'd1;
        rs1_d = 5'd1; rs2_d = 5'd1;
        mem_to_reg_e = 2'b01;
        check(2'b00, 2'b00, 1'b0, 1'b1, "Load-use stall on both rs1 and rs2");

        // No stall if rd_e is x0
        reset_inputs;
        rd_e = 5'd0;
        rs1_d = 5'd0;
        mem_to_reg_e = 2'b01;
        check(2'b00, 2'b00, 1'b0, 1'b0, "No stall for x0 load");

        // No stall if not a load
        reset_inputs;
        rd_e = 5'd1;
        rs1_d = 5'd1;
        mem_to_reg_e = 2'b00; // Not a load
        check(2'b00, 2'b00, 1'b0, 1'b0, "No stall when not a load");

        // =============================================
        // TEST 12: Complex scenario - multiple hazards
        // =============================================
        $display("\n--- Complex Scenario Tests ---");
        reset_inputs;
        // EX-MEM hazard on rs1, MEM-WB hazard on rs2
        rs1_e = 5'd1; rs2_e = 5'd2;
        rd_m = 5'd1; rd_w = 5'd2;
        reg_write_m = 1; reg_write_w = 1;
        check(2'b10, 2'b01, 1'b0, 1'b0, "EX-MEM on rs1 + MEM-WB on rs2");

        // Forwarding + stall scenario
        reset_inputs;
        rs1_e = 5'd1; rd_m = 5'd1; reg_write_m = 1;  // Forward
        rs1_d = 5'd2; rd_e = 5'd2; mem_to_reg_e = 2'b01;  // Stall
        check(2'b10, 2'b00, 1'b0, 1'b1, "Forward rs1 + stall for load-use");

        // =============================================
        // TEST 13: Edge cases with high register numbers
        // =============================================
        $display("\n--- Edge Case Tests ---");
        reset_inputs;
        rs1_e = 5'd31;      // x31
        rd_m = 5'd31;
        reg_write_m = 1;
        check(2'b10, 2'b00, 1'b0, 1'b0, "EX-MEM hazard on x31");

        reset_inputs;
        rs2_e = 5'd15;
        rd_w = 5'd15;
        reg_write_w = 1;
        check(2'b00, 2'b01, 1'b0, 1'b0, "MEM-WB hazard on x15");

        // =============================================
        // Summary
        // =============================================
        $display("\n========================================");
        $display("    Test Summary");
        $display("========================================");
        $display("  Passed: %0d", passed);
        $display("  Failed: %0d", failed);
        $display("========================================\n");

        if (failed == 0)
            $display("All tests PASSED!");
        else
            $display("Some tests FAILED!");

        $finish;
    end

endmodule
