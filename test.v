module test(
    input a, b, c,
    output out
);

    // Testing Git out
    or n1(c, a, b);
    or n2(out, b, c);
    
endmodule