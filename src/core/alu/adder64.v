`ifndef ADDER64_V
`define ADDER64_V

module adder64(
    input [63:0] a, b,
    input adder_op, // Addition or subtraction?
    output [63:0] result,
    output cout,
    output carry_flag,
    output overflow_flag,
    output neg_flag
);

    wire [64:0] carry_arr;
    assign carry_arr[0] = adder_op;

    // This is for generating output
    wire [63:0] b_in;
    genvar i;
    generate
        for(i = 0; i < 64; i = i + 1) begin
            xor(b_in[i], b[i], adder_op);
            adder addx(a[i], b_in[i], carry_arr[i], result[i], carry_arr[i+1]);
        end
    endgenerate

    // I'm assigning flags here
    assign cout = carry_arr[64];
    assign carry_flag = carry_arr[64];
    assign neg_flag = result[63];
    xor(overflow_flag, carry_arr[63], carry_arr[64]);

endmodule

module adder(
    input a, b, cin,
    output result, cout
);

    // For sum
    wire a_xor_b;
    xor(a_xor_b, a, b);
    xor(result, a_xor_b, cin);

    // For cout
    wire a_and_b, cin_and_xor;
    and(a_and_b, a, b);
    and(cin_and_xor, cin, a_xor_b);
    or(cout, cin_and_xor, a_and_b); 

endmodule

`endif
