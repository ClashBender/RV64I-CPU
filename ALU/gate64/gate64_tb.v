`timescale 1ns / 1ps

module gate64_tb;

    // Testbench signals
    reg [63:0] a, b;
    wire [63:0] res_and, res_or, res_xor;
    
    integer i;
    
    // Instantiate the 64-bit gate module (top module)
    gate64 uut (
        .a(a),
        .b(b),
        .res_and(res_and),
        .res_or(res_or),
        .res_xor(res_xor)
    );
    
    initial begin
        $dumpfile("gate64.vcd");
        $dumpvars(0, gate64_tb);
        
        $display("=== 64-bit Logic Gates Testbench (gate64) ===\n");
        
        // Test 1: All zeros
        $display("--- Test 1: Gates with all zeros ---");
        a = 64'h0000000000000000;
        b = 64'h0000000000000000;
        #10;
        $display("a = %h", a);
        $display("b = %h", b);
        $display("AND result = %h (expected: 0000000000000000)", res_and);
        $display("OR  result = %h (expected: 0000000000000000)", res_or);
        $display("XOR result = %h (expected: 0000000000000000)\n", res_xor);
        
        // Test 2: All ones
        $display("--- Test 2: Gates with all ones ---");
        a = 64'hFFFFFFFFFFFFFFFF;
        b = 64'hFFFFFFFFFFFFFFFF;
        #10;
        $display("a = %h", a);
        $display("b = %h", b);
        $display("AND result = %h (expected: FFFFFFFFFFFFFFFF)", res_and);
        $display("OR  result = %h (expected: FFFFFFFFFFFFFFFF)", res_or);
        $display("XOR result = %h (expected: 0000000000000000)\n", res_xor);
        
        // Test 3: Complementary patterns
        $display("--- Test 3: Gates with complementary patterns ---");
        a = 64'h0000000000000000;
        b = 64'hFFFFFFFFFFFFFFFF;
        #10;
        $display("a = %h", a);
        $display("b = %h", b);
        $display("AND result = %h (expected: 0000000000000000)", res_and);
        $display("OR  result = %h (expected: FFFFFFFFFFFFFFFF)", res_or);
        $display("XOR result = %h (expected: FFFFFFFFFFFFFFFF)\n", res_xor);
        
        // Test 4: Alternating bit patterns (0x5555... AND 0xAAAA...)
        $display("--- Test 4: Gates with alternating patterns ---");
        a = 64'h5555555555555555;
        b = 64'hAAAAAAAAAAAAAAAA;
        #10;
        $display("a = %h", a);
        $display("b = %h", b);
        $display("AND result = %h (expected: 0000000000000000)", res_and);
        $display("OR  result = %h (expected: FFFFFFFFFFFFFFFF)", res_or);
        $display("XOR result = %h (expected: FFFFFFFFFFFFFFFF)\n", res_xor);
        
        // Test 5: Same value (AND=OR=value, XOR=0)
        $display("--- Test 5: Gates with identical values ---");
        a = 64'hDEADBEEFCAFEBABE;
        b = 64'hDEADBEEFCAFEBABE;
        #10;
        $display("a = %h", a);
        $display("b = %h", b);
        $display("AND result = %h (expected: DEADBEEFCAFEBABE)", res_and);
        $display("OR  result = %h (expected: DEADBEEFCAFEBABE)", res_or);
        $display("XOR result = %h (expected: 0000000000000000)\n", res_xor);
        
        // Test 6: Partial overlap patterns
        $display("--- Test 6: Gates with partial overlap ---");
        a = 64'h00FF00FF00FF00FF;
        b = 64'h0F0F0F0F0F0F0F0F;
        #10;
        $display("a = %h", a);
        $display("b = %h", b);
        $display("AND result = %h (expected: 000F000F000F000F)", res_and);
        $display("OR  result = %h (expected: 0FFF0FFF0FFF0FFF)", res_or);
        $display("XOR result = %h (expected: 0FF00FF00FF00FF0)\n", res_xor);
        
        // Test 7: Byte patterns
        $display("--- Test 7: Byte patterns ---");
        a = 64'hFFFF0000FFFF0000;
        b = 64'h00FFFF0000FFFF00;
        #10;
        $display("a = %h", a);
        $display("b = %h", b);
        $display("AND result = %h", res_and);
        $display("OR  result = %h", res_or);
        $display("XOR result = %h\n", res_xor);
        
        // Test 8: Random patterns
        $display("--- Test 8: Random patterns ---");
        for (i = 0; i < 5; i = i + 1) begin
            a = {$random, $random};
            b = {$random, $random};
            #10;
            $display("Test 8.%d:", i);
            $display("  a   = %h", a);
            $display("  b   = %h", b);
            $display("  AND = %h", res_and);
            $display("  OR  = %h", res_or);
            $display("  XOR = %h\n", res_xor);
        end
        
        // Test 9: Verify logical properties
        $display("--- Test 9: Verifying logical properties ---");
        a = 64'hABCDEF0123456789;
        b = 64'h123456789ABCDEF0;
        #10;
        
        // Property 1: (a AND b) OR (a XOR b) should equal (a OR b)
        if ((res_and | res_xor) == res_or) begin
            $display("PASS: (AND) OR (XOR) == (OR)");
        end else begin
            $display("FAIL: (AND) OR (XOR) != (OR)");
        end
        
        // Property 2: (a AND b) AND (a XOR b) should equal 0
        if ((res_and & res_xor) == 64'h0) begin
            $display("PASS: (AND) AND (XOR) == 0");
        end else begin
            $display("FAIL: (AND) AND (XOR) != 0");
        end
        
        // Property 3: a XOR b = (a OR b) AND NOT(a AND b)
        if (res_xor == (res_or & ~res_and)) begin
            $display("PASS: XOR == (OR AND NOT(AND))");
        end else begin
            $display("FAIL: XOR != (OR AND NOT(AND))");
        end
        
        $display("\n=== Testbench Complete ===");
        $finish;
    end

endmodule
