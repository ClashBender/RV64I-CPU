module classifyFD(
    input mode, // 0 for FP32, 1 for FP64
    input [63:0] a,
    output reg [9:0] classify, //this follows the IEEE 754-2008 standard for classifying floating point numbers
    output reg nan, inf, zero, subn, normal
);

always @(*) begin
    
    if(mode) begin
        if(a[62:52] == 11'h7ff) begin // Exponent all 1s
            if(a[51:0] == 0) 
                classify = a[63] ? 10'b00_0000_0001 : 10'b00_1000_0000; // Infinity
            else if(a[51] == 1) 
                classify = 10'b01_0000_0000; // sNaN
            else 
                classify = 10'b10_0000_0000; // qNaN
        end
        else if(a[62:52] == 0) begin // Exponent all 0s
            if(a[51:0] == 0) 
                classify = a[63] ? 10'b00_0000_1000 : 10'b00_0001_0000; // Zero
            else 
                classify = a[63] ? 10'b00_0000_0100 : 10'b00_0010_0000; // Subnormal
        end
        else 
            classify = a[63] ? 10'b00_0000_0010 : 10'b00_0100_0000; // Normal
    end
    else begin
        if(a[30:23] == 8'hff) begin // Exponent all 1s
            if(a[22:0] == 0) 
                classify = a[31] ? 10'b00_0000_0001 : 10'b00_1000_0000; // Infinity
            else if(a[22] == 1) 
                classify = 10'b01_0000_0000; // sNaN
            else 
                classify = 10'b10_0000_0000; // qNaN
        end
        else if(a[30:23] == 0) begin // Exponent all 0s
            if(a[22:0] == 0) 
                classify = a[31] ? 10'b00_0000_1000 : 10'b00_0001_0000; // Zero
            else 
                classify = a[31] ? 10'b00_0000_0100 : 10'b00_0010_0000; // Subnormal
        end
        else 
            classify = a[31] ? 10'b00_0000_0010 : 10'b00_0100_0000; // Normal
    end
        
    nan = classify[9] | classify[8];
    inf = classify[7] | classify[0];
    zero = classify[4] | classify[3];
    subn = classify[5] | classify[2];
    normal = classify[6] | classify[1];
    
end

endmodule