`ifndef GATE64_V
`define GATE64_V

module gate64(
    input [63:0] a, b, 
    output [63:0] res_and, res_or, res_xor
);

    and64 and_block(a, b, res_and);
    or64 or_block(a, b, res_or);
    xor64 xor_block(a, b, res_xor);
    
endmodule

module and64(
    input [63:0] a, b,
    output [63:0] result
);

    genvar i;
    generate 
        for(i = 0; i < 64; i = i + 1)
            and(result[i], a[i], b[i]);
    endgenerate
    
endmodule

module xor64(
    input [63:0] a, b,
    output [63:0] result
);

    genvar i;
    generate 
        for(i = 0; i < 64; i = i + 1)
            xor(result[i], a[i], b[i]);
    endgenerate
    
endmodule

module or64(
    input [63:0] a, b,
    output [63:0] result
);

    genvar i;
    generate 
        for(i = 0; i < 64; i = i + 1)
            or(result[i], a[i], b[i]);
    endgenerate
    
endmodule

`endif