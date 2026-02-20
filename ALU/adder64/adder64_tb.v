`timescale 1ns / 1ps

module adder64_tb;

    // Testbench signals
    reg [63:0] a, b;
    reg adder_op;
    wire [63:0] result;
    wire cout;
    wire carry_flag;
    wire overflow_flag;
    wire neg_flag;
    
    integer i;
    
    // Instantiate the 64-bit adder
    adder64 uut (
        .a(a),
        .b(b),
        .adder_op(adder_op),
        .result(result),
        .cout(cout),
        .carry_flag(carry_flag),
        .overflow_flag(overflow_flag),
        .neg_flag(neg_flag)
    );
    
    initial begin
        $dumpfile("adder64.vcd");
        $dumpvars(0, adder64_tb);
        
        $display("=== 64-bit Adder/Subtractor Testbench ===\n");
        $display("adder_op=0 for ADDITION, adder_op=1 for SUBTRACTION\n");
        
        // Test 1: Simple addition
        $display("--- Test 1: Addition (5 + 3, adder_op=0) ---");
        a = 64'h0000000000000005;
        b = 64'h0000000000000003;
        adder_op = 1'b0;
        #10;
        $display("a=%h, b=%h, adder_op=%b (ADDITION)", a, b, adder_op);
        $display("result=%h, neg=%b, cout=%b, overflow=%b\n", result, neg_flag, cout, overflow_flag);
        
        // Test 2: Addition with larger numbers
        $display("--- Test 2: Subtraction (5 - 3, adder_op=1) ---");
        a = 64'h0000000000000005;
        b = 64'h0000000000000003;
        adder_op = 1'b1;
        #10;
        $display("a=%h, b=%h, adder_op=%b (SUBTRACTION)", a, b, adder_op);
        $display("result=%h, neg=%b, cout=%b, overflow=%b (expected: result=2, neg=0)\n", result, neg_flag, cout, overflow_flag);
        
        // Test 3: Subtraction (5 - 3)
        $display("--- Test 3: Subtraction with borrow (3 - 5, adder_op=1) ---");
        a = 64'h0000000000000003;
        b = 64'h0000000000000005;
        adder_op = 1'b1;
        #10;
        $display("a=%h, b=%h, adder_op=%b (SUBTRACTION)", a, b, adder_op);
        $display("result=%h, neg=%b, cout=%b, overflow=%b (expected: result=-2, neg=1)\n", result, neg_flag, cout, overflow_flag);
        
        // Test 4: Subtraction resulting in borrow
        $display("--- Test 4: Result is zero (0 + 0, adder_op=0) ---");
        a = 64'h0000000000000000;
        b = 64'h0000000000000000;
        adder_op = 1'b0;
        #10;
        $display("a=%h, b=%h, adder_op=%b", a, b, adder_op);
        $display("result=%h, neg=%b (expected 0), cout=%b, overflow=%b\n", result, neg_flag, cout, overflow_flag);
        
        // Test 5: Addition with carry propagation
        $display("--- Test 5: Subtraction resulting in zero (same - same, adder_op=1) ---");
        a = 64'hDEADBEEFCAFEBABE;
        b = 64'hDEADBEEFCAFEBABE;
        adder_op = 1'b1;
        #10;
        $display("a=%h, b=%h, adder_op=%b (SUBTRACTION)", a, b, adder_op);
        $display("result=%h, neg=%b (expected 0), cout=%b, overflow=%b\n", result, neg_flag, cout, overflow_flag);
        
        // Test 6: Subtraction (same - same = 0)
        $display("--- Test 6: Addition with carry out (0xFFFF...FFFF + 1, adder_op=0) ---");
        a = 64'hFFFFFFFFFFFFFFFF;
        b = 64'h0000000000000001;
        adder_op = 1'b0;
        #10;
        $display("a=%h, b=%h, adder_op=%b", a, b, adder_op);
        $display("result=%h, cout=%b (expected 1), neg=%b (expected 0), overflow=%b\n", result, cout, neg_flag, overflow_flag);
        
        // Test 7: Addition (0 + 0)
        $display("--- Test 7: Signed overflow (max_positive + max_positive, adder_op=0) ---");
        a = 64'h7FFFFFFFFFFFFFFF;
        // b = 64'h7FFFFFFFFFFFFFFF;
        b = 64'h0000000000000001;
        adder_op = 1'b0;
        #10;
        $display("a=%h (max positive), b=%h (max positive), adder_op=%b", a, b, adder_op);
        $display("result=%h, overflow=%b (expected 1), neg=%b (expected 1), cout=%b\n", result, overflow_flag, neg_flag, cout);
        
        $display("\n=== Testbench Complete ===");
        $finish;
    end

endmodule
