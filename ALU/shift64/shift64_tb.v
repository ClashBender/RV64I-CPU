`timescale 1ns / 1ps

module barrel_shifter_tb;
    reg [63:0] a, b;
    reg lr_flag, logic_flag;
    wire [63:0] result;

    barrel_shifter uut (
        .a(a),
        .b(b),
        .lr_flag(lr_flag),
        .logic_flag(logic_flag),
        .result(result)
    );

    initial begin
        $display("========== Barrel Shifter Test Bench ==========");
        $display("lr_flag: 0=left, 1=right | logic_flag: 0=logical, 1=arithmetic\n");

        // Test 1: Left Shift (Logical)
        $display("--- Left Shift (Logical) ---");
        a = 64'h0000000000000001; b = 64'd1; lr_flag = 1'b0; logic_flag = 1'b0; #10;
        $display("%-28s a=%64b | result=%64b", "Left shift by 1:", a, result);
        
        a = 64'h0000000000000001; b = 64'd2; lr_flag = 1'b0; logic_flag = 1'b0; #10;
        $display("%-28s a=%64b | result=%64b", "Left shift by 2:", a, result);
        
        a = 64'h0000000000000001; b = 64'd8; lr_flag = 1'b0; logic_flag = 1'b0; #10;
        $display("%-28s a=%64b | result=%64b", "Left shift by 8:", a, result);
        
        a = 64'h0000000000000001; b = 64'd32; lr_flag = 1'b0; logic_flag = 1'b0; #10;
        $display("%-28s a=%64b | result=%64b", "Left shift by 32:", a, result);
        
        a = 64'h000000000000000F; b = 64'd4; lr_flag = 1'b0; logic_flag = 1'b0; #10;
        $display("%-28s a=%64b | result=%64b", "Left shift 0xF by 4:", a, result);

        // Test 2: Right Shift (Logical)
        $display("\n--- Right Shift (Logical) ---");
        a = 64'h8000000000000000; b = 64'd1; lr_flag = 1'b1; logic_flag = 1'b0; #10;
        $display("%-28s a=%64b | result=%64b", "Right logical by 1:", a, result);
        
        a = 64'h8000000000000000; b = 64'd2; lr_flag = 1'b1; logic_flag = 1'b0; #10;
        $display("%-28s a=%64b | result=%64b", "Right logical by 2:", a, result);
        
        a = 64'h8000000000000000; b = 64'd8; lr_flag = 1'b1; logic_flag = 1'b0; #10;
        $display("%-28s a=%64b | result=%64b", "Right logical by 8:", a, result);
        
        a = 64'hFFFFFFFFFFFFFFFF; b = 64'd1; lr_flag = 1'b1; logic_flag = 1'b0; #10;
        $display("%-28s a=%64b | result=%64b", "Right logical all 1s by 1:", a, result);

        // Test 3: Right Shift (Arithmetic)
        $display("\n--- Right Shift (Arithmetic) ---");
        a = 64'h8000000000000000; b = 64'd1; lr_flag = 1'b1; logic_flag = 1'b1; #10;
        $display("%-28s a=%64b | result=%64b", "Right arith by 1 (sign=1):", a, result);
        
        a = 64'h8000000000000000; b = 64'd8; lr_flag = 1'b1; logic_flag = 1'b1; #10;
        $display("%-28s a=%64b | result=%64b", "Right arith by 8 (sign=1):", a, result);
        
        a = 64'h8000000000000000; b = 64'd32; lr_flag = 1'b1; logic_flag = 1'b1; #10;
        $display("%-28s a=%64b | result=%64b", "Right arith by 32 (sign=1):", a, result);
        
        a = 64'h7FFFFFFFFFFFFFFF; b = 64'd1; lr_flag = 1'b1; logic_flag = 1'b1; #10;
        $display("%-28s a=%64b | result=%64b", "Right arith by 1 (sign=0):", a, result);
        
        a = 64'h7FFFFFFFFFFFFFFF; b = 64'd8; lr_flag = 1'b1; logic_flag = 1'b1; #10;
        $display("%-28s a=%64b | result=%64b", "Right arith by 8 (sign=0):", a, result);

        // Test 4: Edge Cases
        $display("\n--- Edge Cases ---");
        a = 64'h0000000000000000; b = 64'd32; lr_flag = 1'b0; logic_flag = 1'b0; #10;
        $display("%-28s a=%64b | result=%64b", "Left shift zero:", a, result);
        
        a = 64'hFFFFFFFFFFFFFFFF; b = 64'd0; lr_flag = 1'b0; logic_flag = 1'b0; #10;
        $display("%-28s a=%64b | result=%64b", "Shift by 0:", a, result);
        
        a = 64'h0000000000000001; b = 64'd63; lr_flag = 1'b0; logic_flag = 1'b0; #10;
        $display("%-28s a=%64b | result=%64b", "Left shift by 63:", a, result);

        // Test 5: Pattern Tests
        $display("\n--- Pattern Tests ---");
        a = 64'h5555555555555555; b = 64'd1; lr_flag = 1'b0; logic_flag = 1'b0; #10;
        $display("%-28s a=%64b | result=%64b", "Left shift alternating:", a, result);
        
        a = 64'hAAAAAAAAAAAAAAAA; b = 64'd1; lr_flag = 1'b1; logic_flag = 1'b0; #10;
        $display("%-28s a=%64b | result=%64b", "Right logical alternating:", a, result);
        
        a = 64'hAAAAAAAAAAAAAAAA; b = 64'd1; lr_flag = 1'b1; logic_flag = 1'b1; #10;
        $display("%-28s a=%64b | result=%64b", "Right arith alternating:", a, result);

        $display("\n========== Test Complete ==========");
        $finish;
    end

endmodule
