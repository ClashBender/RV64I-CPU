// FP32 {1 sign, 8 exponent, 23 fraction}
// FP64 {1 sign, 11 exponent, 52 fraction}

module multiplyFD (
    input mode, // 0 for FP32, 1 for FP64
    input [63:0] a, b,
    input nanA, infA, zeroA, subnA, normalA,
    input nanB, infB, zeroB, subnB, normalB, 
    output reg [63:0] result
);

reg sign;
reg [9:0] exponentF; //need to account for exponent overflow when adding and the sign.
reg [12:0] exponentD; //need to account for exponent overflow when adding and the sign.
reg [47:0] mantissaF; // both a and b are written as 1.mantissa, so 24 bits each, total 48 bits after multiplication
reg [105:0] mantissaD; // both a and b are written as 1.mantissa, so 53 bits each, total 106 bits after multiplication

always @(*) begin
    if(mode) begin //fp64
        exponentD = a[62:52] + b[62:52] - 1023; 
        sign = a[63] ^ b[63];
        
        if (nanA || nanB) begin
            result = {sign, 11'h7ff, 1'b1, 51'b0}; // sNaN
        end
        else if (infA || infB) begin
            result = (zeroA || zeroB) ? {sign, 11'h7ff, 1'b1, 51'b0} : {sign, 11'h7ff, 52'd0}; // sNaN or infinity
        end
        else if (zeroA || zeroB || (subnA && subnB)) begin
            result = 0; // zero or both subnormals
        end
        else begin //cases with atleast one normal

            if(normalA && normalB)  //both normal
                mantissaD = {1'b1,a[51:0]} * {1'b1,b[51:0]};

            else if(normalA && subnB)  //a normal, b subnormal
                mantissaD = {1'b1,a[51:0]} * {1'b0,b[51:0]};

            else if(subnA && normalB)  //a subnormal, b normal
                mantissaD = {1'b0,a[51:0]} * {1'b1,b[51:0]};

            
            // normalizing mantissa
            if(mantissaD[105]) begin
                exponentD = exponentD + 1; //still need to handle overflow
                mantissaD = mantissaD >> 1;
            end

            //checking for overflow and underflow
            if(exponentD <= -52) //number is too small, even for a subnormal => underflow to zero
                result = {sign, 63'b0}; 

            else if(exponentD <= 0) begin //will get a subnormal result, need to shift mantissa right by -exponentD + 1 to get the correct value
                mantissaD = mantissaD >> (-exponentD + 1);
                result = {sign, 11'b0, mantissaD[103:52]};
            end

            else if(exponentD >= 2047) //too large, overflow to infinity
                result = {sign, 11'h7ff, 52'd0}; 
            else
                result = {sign, exponentD[10:0], mantissaD[103:52]}; 
        end
    end
    else begin //fp32
        exponentF = a[30:23] + b[30:23] - 127; 
        sign = a[31] ^ b[31];
        
        
        if (nanA || nanB) begin
            result = {32'd0, sign, 8'hff, 1'b1, 23'd0}; // sNaN
        end
        else if (infA || infB) begin
            result = (zeroA || zeroB) ? {32'd0,sign, 8'hff, 1'b1, 23'd0} : {32'd0, sign, 8'hff, 23'd0}; // sNaN or infinity
        end
        else if (zeroA || zeroB || (subnA && subnB)) begin
            result = 0; // zero or both subnormals
        end
        else begin //cases with atleast one normal

            if(normalA && normalB)  //both normal
                mantissaF = {1'b1,a[22:0]} * {1'b1,b[22:0]};

            else if(normalA && subnB)  //a normal, b subnormal
                mantissaF = {1'b1,a[22:0]} * {1'b0,b[22:0]};

            else if(subnA && normalB)  //a subnormal, b normal
                mantissaF = {1'b0,a[22:0]} * {1'b1,b[22:0]};
            
            
            // normalizing mantissa
            if(mantissaF[47]) begin
                exponentF = exponentF + 1; //still need to handle overflow
                mantissaF = mantissaF >> 1;
            end

            //checking for overflow and underflow
            if(exponentF <= -23) //too small, underflow to zero
                result = {32'd0, sign, 31'd0};

            else if(exponentF <= 0) begin //will get a subnormal result, need to shift mantissa right by -exponentF + 1 to get the correct value
                mantissaF = mantissaF >> (-exponentF + 1);
                result = {32'd0, sign, 8'h0, mantissaF[45:23]};
            end

            else if(exponentF >= 255) //too large, overflow to infinity
                result = {32'd0, sign, 8'hff, 23'd0};

            else
                result = {32'd0, sign, exponentF[7:0], mantissaF[45:23]}; 
        end
    end
            
      

    end
    


endmodule