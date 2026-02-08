module test(
    input a, b, c,
    output out1,
    output out2
);
  
    // Testing Git out
    or n1(c, a, b);
    or n2(out1, b, c);

    // adding smething else-nikhilesh
    and a1(out2, a, b);
    
endmodule