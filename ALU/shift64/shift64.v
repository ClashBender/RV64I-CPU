// `include "../mux64/mux64.v" 

module barrel_shifter(
    input [63:0] a, b, 
    input lr_flag, // shift left(0) or right(1) ?
    input logic_flag, // logical(0) or arithmetic(1)
    output [63:0] result
);

    wire sign_bit;
    and(sign_bit, logic_flag, lr_flag, a[63]);

    // Implementing shift left operation
    wire [63:0] a_in, a_out, mid1, mid2, mid3, mid4, mid5;
    genvar i;
    generate

        // Left or Right shift?
        for(i = 0; i < 64; i = i + 1) begin
            mux mux_sel_in(a[63-i], a[i], lr_flag, a_in[i]);
        end
        
        // First Layer
        for(i = 0; i < 64; i = i + 1) begin
            if(i < 1)
                mux mux1(sign_bit, a_in[i], b[0], mid1[i]);
            else
                mux mux1(a_in[i-1], a_in[i], b[0], mid1[i]);            
        end

        // Second Layer
        for(i = 0; i < 64; i = i + 1) begin
            if(i < 2)
                mux mux2(sign_bit, mid1[i], b[1], mid2[i]);
            else
                mux mux2(mid1[i-2], mid1[i], b[1], mid2[i]);            
        end

        // Third Layer
        for(i = 0; i < 64; i = i + 1) begin
            if(i < 4)
                mux mux3(sign_bit, mid2[i], b[2], mid3[i]);
            else
                mux mux3(mid2[i-4], mid2[i], b[2], mid3[i]);            
        end

        // Fourth Layer
        for(i = 0; i < 64; i = i + 1) begin
            if(i < 8)
                mux mux4(sign_bit, mid3[i], b[3], mid4[i]);
            else
                mux mux4(mid3[i-8], mid3[i], b[3], mid4[i]);            
        end

        // Fifth Layer
        for(i = 0; i < 64; i = i + 1) begin
            if(i < 16)
                mux mux5(sign_bit, mid4[i], b[4], mid5[i]);
            else
                mux mux5(mid4[i-16], mid4[i], b[4], mid5[i]);            
        end

        // Sixth Layer
        for(i = 0; i < 64; i = i + 1) begin
            if(i < 32)
                mux mux6(sign_bit, mid5[i], b[5], a_out[i]);
            else
                mux mux6(mid5[i-32], mid5[i], b[5], a_out[i]);            
        end

        // Rotate back, if right shift
        for(i = 0; i < 64; i = i + 1) begin
            mux mux_sel_out(a_out[63-i], a_out[i], lr_flag, result[i]);
        end

    endgenerate

endmodule
