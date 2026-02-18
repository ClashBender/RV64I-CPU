// (sel) ? a : b;
module mux(
    input a, b, sel, 
    output res
);

    wire not_sel;
    not(not_sel, sel);

    wire ans1, ans2;
    and(ans1, a, sel);
    and(ans2, b, not_sel);

    or(res, ans1, ans2);
    
endmodule

module mux64(
    input [63:0] a, b, 
    input sel,
    output [63:0] res
);

    wire not_sel;
    not(not_sel, sel);

    wire [63:0] ans1, ans2;
    genvar i;
    generate
        for(i = 0; i < 64; i = i + 1)
            mux mux64_sel(a[i], b[i], sel, res[i]);
    endgenerate
    
endmodule


module mux_3x8(
    input [63:0] a, b, c, d, e, f, g, h,
    input [2:0] sel,
    output [63:0] res
);

    wire [63:0] mid1a, mid1b, mid1c, mid1d, mid2a, mid2b, mid3;
    mux64 mux1a (b, a, sel[0], mid1a);
    mux64 mux1b (d, c, sel[0], mid1b);
    mux64 mux1c (f, e, sel[0], mid1c);
    mux64 mux1d (h, g, sel[0], mid1d);

    mux64 mux2a (mid1b, mid1a, sel[1], mid2a);
    mux64 mux2b (mid1d, mid1c, sel[1], mid2b);

    mux64 mux3 (mid2b, mid2a, sel[2], res);

endmodule