module test(
    input a, b, c,
    output out1,
    output out2,
    output out3
);
  
    // Testing Git out
    or n1(c, a, b);
    or n2(out1, b, c);

    // adding smething else-nikhilesh
    and a1(out2, a, b);
    
    // adding yet another change for fun - ritvik
    or c1(out3, a, b, c);
endmodule