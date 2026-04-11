`include "multiply.v"
`include "classify.v"

module multiply_tb;

    reg mode, nanA, infA, zeroA, subnA, normalA, nanB, infB, zeroB, subnB, normalB;
    reg [63:0] a, b;
    wire [63:0] result;

    // DUT
    multiplyFD uut(
        .mode(mode), .a(a), .b(b),
        .nanA(nanA), .infA(infA), .zeroA(zeroA), .subnA(subnA), .normalA(normalA),
        .nanB(nanB), .infB(infB), .zeroB(zeroB), .subnB(subnB), .normalB(normalB),
        .result(result)
    );

    classifyFD uut_output_classify(
        .mode(mode), .a(result),
        .classify(), .nan(), .inf(), .zero(), .subn(), .normal()
    );

    integer i,j;

    task apply_flags_a;
        input isNan, isInf, isZero, isSubn, isNorm;
        begin
            nanA    = isNan;
            infA    = isInf;
            zeroA   = isZero;
            subnA   = isSubn;
            normalA = isNorm;
        end
    endtask

    task apply_flags_b;
        input isNan, isInf, isZero, isSubn, isNorm;
        begin
            nanB    = isNan;
            infB    = isInf;
            zeroB   = isZero;
            subnB   = isSubn;
            normalB = isNorm;
        end
    endtask

    task run_case;
        input [255:0] name;
        input [63:0] inA;
        input [63:0] inB;
        input aNan, aInf, aZero, aSubn, aNorm;
        input bNan, bInf, bZero, bSubn, bNorm;
        input [63:0] expectedResult;
        begin
            a = inA;
            b = inB;
            apply_flags_a(aNan, aInf, aZero, aSubn, aNorm);
            apply_flags_b(bNan, bInf, bZero, bSubn, bNorm);

            #1;
            $display("[%0d] %0s", i, name);
            $display("a=%h b=%h result=%h", a, b, result);
            $display("output: NaN | Inf | Zero | Subnormal | Normal |");
            $display("      |  %b  |  %b  |  %b   |     %b     |   %b    |", uut_output_classify.nan, uut_output_classify.inf, uut_output_classify.zero, uut_output_classify.subn, uut_output_classify.normal);
            $display("exponentD=%d, exponentA=%d, exponentB=%d", uut.exponentD, uut.a[62:52], uut.b[62:52]);
            if(expectedResult != result) begin
                $display("TEST CASE FAILED!");
                $display("Expected result: %h", expectedResult);
            end
            else begin
                $display("TEST CASE PASSED!");
                j = j+1;
            end
            $display("----------------------------------------------------------");

            i = i + 1;
        end
    endtask

    initial begin
        i = 0; j = 0;
        mode = 1'b1;
        a = 64'd0;
        b = 64'd0;
        apply_flags_a(1'b0, 1'b0, 1'b0, 1'b0, 1'b0);
        apply_flags_b(1'b0, 1'b0, 1'b0, 1'b0, 1'b0);

        $display("-------Section 1: FP64 Tests--------");

        $display("-------Subsection 1.1: Special Cases (NaN, Inf, Zero)--------");
        run_case("NaN * normal", 64'h7ff8_0000_0000_0001, 64'h3ff0_0000_0000_0000,
                 1'b1, 1'b0, 1'b0, 1'b0, 1'b0,
                 1'b0, 1'b0, 1'b0, 1'b0, 1'b1,
                 64'h7ff8_0000_0000_0000);

        run_case("0 * NaN", 64'h0000_0000_0000_0000, 64'h7ff8_0000_0000_0011,
                 1'b0, 1'b0, 1'b0, 1'b0, 1'b1,
                 1'b1, 1'b0, 1'b0, 1'b0, 1'b0,
                 64'h7ff8_0000_0000_0000);

        run_case("NaN * Inf", 64'h7ff8_0000_0000_0001, 64'h7ff0_0000_0000_0000,
                 1'b1, 1'b0, 1'b0, 1'b0, 1'b0,
                 1'b0, 1'b1, 1'b0, 1'b0, 1'b0,
                 64'h7ff8_0000_0000_0000);

        run_case("+Inf * normal", 64'h7ff0_0000_0000_0000, 64'h4000_0000_0000_0000,
                 1'b0, 1'b1, 1'b0, 1'b0, 1'b0,
                 1'b0, 1'b0, 1'b0, 1'b0, 1'b1,
                 64'h7ff0_0000_0000_0000);

        run_case("-Inf * normal", 64'hfff0_0000_0000_0000, 64'h4000_0000_0000_0000,
                 1'b0, 1'b1, 1'b0, 1'b0, 1'b0,
                 1'b0, 1'b0, 1'b0, 1'b0, 1'b1,
                 64'hfff0_0000_0000_0000);

        run_case("Inf * 0 (invalid => NaN)", 64'h7ff0_0000_0000_0000, 64'h0000_0000_0000_0000,
                 1'b0, 1'b1, 1'b0, 1'b0, 1'b0,
                 1'b0, 1'b0, 1'b1, 1'b0, 1'b0,
                 64'h7ff8_0000_0000_0000);

        run_case("0 * Inf (invalid => NaN)", 64'h0000_0000_0000_0000, 64'h7ff0_0000_0000_0000,
                 1'b0, 1'b0, 1'b1, 1'b0, 1'b0,
                 1'b0, 1'b1, 1'b0, 1'b0, 1'b0,
                 64'h7ff8_0000_0000_0000);

        run_case("+0 * normal", 64'h0000_0000_0000_0000, 64'h3ff0_0000_0000_0000,
                 1'b0, 1'b0, 1'b1, 1'b0, 1'b0,
                 1'b0, 1'b0, 1'b0, 1'b0, 1'b1,
                 64'h0000_0000_0000_0000);

        run_case("-0 * normal", 64'h8000_0000_0000_0000, 64'h3ff0_0000_0000_0000,
                 1'b0, 1'b0, 1'b1, 1'b0, 1'b0,
                 1'b0, 1'b0, 1'b0, 1'b0, 1'b1,
                 64'h8000_0000_0000_0000);

        run_case("0 * -0", 64'h0000_0000_0000_0000, 64'h8000_0000_0000_0000,
                 1'b0, 1'b0, 1'b1, 1'b0, 1'b0,
                 1'b0, 1'b0, 1'b1, 1'b0, 1'b0,
                 64'h8000_0000_0000_0000);

        $display("-------Subsection 1.2: Subnormal * Subnormal--------");
        run_case("min_subnormal * min_subnormal", 64'h0000_0000_0000_0001, 64'h0000_0000_0000_0001,
                 1'b0, 1'b0, 1'b0, 1'b1, 1'b0,
                 1'b0, 1'b0, 1'b0, 1'b1, 1'b0,
                 64'h0000_0000_0000_0000);

        run_case("max_subnormal * min_subnormal", 64'h000f_ffff_ffff_ffff, 64'h0000_0000_0000_0001,
                 1'b0, 1'b0, 1'b0, 1'b1, 1'b0,
                 1'b0, 1'b0, 1'b0, 1'b1, 1'b0,
                 64'h0000_0000_0000_0000);

        run_case("max_subnormal * max_subnormal", 64'h000f_ffff_ffff_ffff, 64'h000f_ffff_ffff_ffff,
                 1'b0, 1'b0, 1'b0, 1'b1, 1'b0,
                 1'b0, 1'b0, 1'b0, 1'b1, 1'b0,
                 64'h0000_0000_0000_0000);

        run_case("signed subnormal product", 64'h8000_0000_0000_0001, 64'h0000_0000_0000_0002,
                 1'b0, 1'b0, 1'b0, 1'b1, 1'b0,
                 1'b0, 1'b0, 1'b0, 1'b1, 1'b0,
                 64'h8000_0000_0000_0000);

        $display("-------FP64 Section 2: Normal * Normal--------");
        $display("-------Subsection 2.1: Underflow --------");
        run_case("min_normal * min_normal(2^-1022)", 64'h0010_0000_0000_0000, 64'h0010_0000_0000_0000,
                 1'b0, 1'b0, 1'b0, 1'b0, 1'b1,
                 1'b0, 1'b0, 1'b0, 1'b0, 1'b1,
                 64'h0000_0000_0000_0000);
        run_case("1.101x2^(-560) * 1.101x2^(-560)", 64'h1CFA_0000_0000_0000, 64'h1CFA_0000_0000_0000,
                 1'b0, 1'b0, 1'b0, 1'b0, 1'b1,
                 1'b0, 1'b0, 1'b0, 1'b0, 1'b1,
                 64'h0000_0000_0000_0000);
        run_case("-1.0011^(-800) * 1.101x2^(-300)", 64'h8DF3_0000_0000_0000, 64'h2D3A_0000_0000_0000,
                 1'b0, 1'b0, 1'b0, 1'b0, 1'b1,
                 1'b0, 1'b0, 1'b0, 1'b0, 1'b1,
                 64'h8000_0000_0000_0000);
        
        $display("-------Subsection 2.2: Normal * Normal = subnormal--------");
        run_case("1.111....1x2^(-1) * 1x2^(-1022)", 64'h3feF_FFFF_FFFF_FFFF, 64'h0010_0000_0000_0000,
                 1'b0, 1'b0, 1'b0, 1'b0, 1'b1,
                 1'b0, 1'b0, 1'b0, 1'b0, 1'b1,
                 64'h000f_ffff_ffff_ffff);
        run_case("1.111....1x2^(-52) * 1x2^(-1022)", 64'h3cbF_FFFF_FFFF_FFFF, 64'h0010_0000_0000_0000,
                 1'b0, 1'b0, 1'b0, 1'b0, 1'b1,
                 1'b0, 1'b0, 1'b0, 1'b0, 1'b1,
                 64'h0000_0000_0000_0001);
        run_case("1.111....1x2^(-50) * 1x2^(-1022)", 64'h3cdF_FFFF_FFFF_FFFF, 64'h0010_0000_0000_0000,
                 1'b0, 1'b0, 1'b0, 1'b0, 1'b1,
                 1'b0, 1'b0, 1'b0, 1'b0, 1'b1,
                 64'h0000_0000_0000_0007);
        $display("-------Subsection 2.3: Overflow to Inf--------");
        run_case("max_normal * 2", 64'h7feF_FFFF_FFFF_FFFF, 64'h4000_0000_0000_0000,
                 1'b0, 1'b0, 1'b0, 1'b0, 1'b1,
                 1'b0, 1'b0, 1'b0, 1'b0, 1'b1,
                 64'h7ff0_0000_0000_0000);
        run_case("-1.1x2^600 * 1.1x2^(600)", 64'he578_0000_0000_0000, 64'h6578_0000_0000_0000,
                 1'b0, 1'b0, 1'b0, 1'b0, 1'b1,
                 1'b0, 1'b0, 1'b0, 1'b0, 1'b1,
                 64'hfff0_0000_0000_0000);
        run_case("2 * -1.1x2^(1023)", 64'h4000_0000_0000_0000, 64'hffe8_0000_0000_0000,
                 1'b0, 1'b0, 1'b0, 1'b0, 1'b1,
                 1'b0, 1'b0, 1'b0, 1'b0, 1'b1,
                 64'hfff0_0000_0000_0000);

        $display("-------Subsection 2.4: Mixed Sign Cases--------");
        run_case("1.5 * 2.0", 64'h3ff8_0000_0000_0000, 64'h4000_0000_0000_0000,
                 1'b0, 1'b0, 1'b0, 1'b0, 1'b1,
                 1'b0, 1'b0, 1'b0, 1'b0, 1'b1,
                 64'h4008_0000_0000_0000);
        run_case("-2.0 * -0.5", 64'hc000_0000_0000_0000, 64'hbfe0_0000_0000_0000,
                 1'b0, 1'b0, 1'b0, 1'b0, 1'b1,
                 1'b0, 1'b0, 1'b0, 1'b0, 1'b1,
                 64'h3ff0_0000_0000_0000);
        run_case("-2.0 * 0.5", 64'hc000_0000_0000_0000, 64'h3fe0_0000_0000_0000,
                 1'b0, 1'b0, 1'b0, 1'b0, 1'b1,
                 1'b0, 1'b0, 1'b0, 1'b0, 1'b1,
                 64'hbff0_0000_0000_0000);
        run_case("1.0 * min_normal", 64'h3ff0_0000_0000_0000, 64'h0010_0000_0000_0000,
                 1'b0, 1'b0, 1'b0, 1'b0, 1'b1,
                 1'b0, 1'b0, 1'b0, 1'b0, 1'b1,
                 64'h0010_0000_0000_0000);
        run_case("max_normal * 0.5", 64'h7fef_ffff_ffff_ffff, 64'h3fe0_0000_0000_0000,
                 1'b0, 1'b0, 1'b0, 1'b0, 1'b1,
                 1'b0, 1'b0, 1'b0, 1'b0, 1'b1,
                 64'h7fdf_ffff_ffff_ffff);
        run_case("min_normal * 2.0", 64'h0010_0000_0000_0000, 64'h4000_0000_0000_0000,
                 1'b0, 1'b0, 1'b0, 1'b0, 1'b1,
                 1'b0, 1'b0, 1'b0, 1'b0, 1'b1,
                 64'h0020_0000_0000_0000);
        run_case("min_subnormal * 1.0", 64'h0000_0000_0000_0001, 64'h3ff0_0000_0000_0000,
                 1'b0, 1'b0, 1'b0, 1'b1, 1'b0,
                 1'b0, 1'b0, 1'b0, 1'b0, 1'b1,
                 64'h0000_0000_0000_0000);
        run_case("max_subnormal * 1.0", 64'h000f_ffff_ffff_ffff, 64'h3ff0_0000_0000_0000,
                 1'b0, 1'b0, 1'b0, 1'b1, 1'b0,
                 1'b0, 1'b0, 1'b0, 1'b0, 1'b1,
                 64'h0007_ffff_ffff_ffff);
        run_case("-max_subnormal * 1.0", 64'h800f_ffff_ffff_ffff, 64'h3ff0_0000_0000_0000,
                 1'b0, 1'b0, 1'b0, 1'b1, 1'b0,
                 1'b0, 1'b0, 1'b0, 1'b0, 1'b1,
                 64'h8007_ffff_ffff_ffff);
        run_case("2.0 * min_subnormal", 64'h4000_0000_0000_0000, 64'h0000_0000_0000_0001,
                 1'b0, 1'b0, 1'b0, 1'b0, 1'b1,
                 1'b0, 1'b0, 1'b0, 1'b1, 1'b0,
                 64'h0010_0000_0000_0001);
        
        $display("Score %d/%d", j, i);
        $finish;
    end


endmodule