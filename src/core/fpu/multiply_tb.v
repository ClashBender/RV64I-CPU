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

    integer i;

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
            $display("----------------------------------------------------------");
            i = i + 1;
        end
    endtask

    initial begin
        i = 0;
        mode = 1'b1;
        a = 64'd0;
        b = 64'd0;
        apply_flags_a(1'b0, 1'b0, 1'b0, 1'b0, 1'b0);
        apply_flags_b(1'b0, 1'b0, 1'b0, 1'b0, 1'b0);

        $display("-------Section 1: FP64 Tests--------");

        $display("-------Subsection 1.1: Special Cases (NaN, Inf, Zero)--------");
        run_case("NaN * normal", 64'h7ff8_0000_0000_0001, 64'h3ff0_0000_0000_0000,
                 1'b1, 1'b0, 1'b0, 1'b0, 1'b0,
                 1'b0, 1'b0, 1'b0, 1'b0, 1'b1);

        run_case("0 * NaN", 64'h0000_0000_0000_0000, 64'h7ff8_0000_0000_0011,
                 1'b0, 1'b0, 1'b0, 1'b0, 1'b1,
                 1'b1, 1'b0, 1'b0, 1'b0, 1'b0);

        run_case("NaN * Inf", 64'h7ff8_0000_0000_0001, 64'h7ff0_0000_0000_0000,
                 1'b1, 1'b0, 1'b0, 1'b0, 1'b0,
                 1'b0, 1'b1, 1'b0, 1'b0, 1'b0);

        run_case("+Inf * normal", 64'h7ff0_0000_0000_0000, 64'h4000_0000_0000_0000,
                 1'b0, 1'b1, 1'b0, 1'b0, 1'b0,
                 1'b0, 1'b0, 1'b0, 1'b0, 1'b1);

        run_case("-Inf * normal", 64'hfff0_0000_0000_0000, 64'h4000_0000_0000_0000,
                 1'b0, 1'b1, 1'b0, 1'b0, 1'b0,
                 1'b0, 1'b0, 1'b0, 1'b0, 1'b1);

        run_case("Inf * 0 (invalid => NaN)", 64'h7ff0_0000_0000_0000, 64'h0000_0000_0000_0000,
                 1'b0, 1'b1, 1'b0, 1'b0, 1'b0,
                 1'b0, 1'b0, 1'b1, 1'b0, 1'b0);

        run_case("0 * Inf (invalid => NaN)", 64'h0000_0000_0000_0000, 64'h7ff0_0000_0000_0000,
                 1'b0, 1'b0, 1'b1, 1'b0, 1'b0,
                 1'b0, 1'b1, 1'b0, 1'b0, 1'b0);

        run_case("+0 * normal", 64'h0000_0000_0000_0000, 64'h3ff0_0000_0000_0000,
                 1'b0, 1'b0, 1'b1, 1'b0, 1'b0,
                 1'b0, 1'b0, 1'b0, 1'b0, 1'b1);

        run_case("-0 * normal", 64'h8000_0000_0000_0000, 64'h3ff0_0000_0000_0000,
                 1'b0, 1'b0, 1'b1, 1'b0, 1'b0,
                 1'b0, 1'b0, 1'b0, 1'b0, 1'b1);

        run_case("0 * -0", 64'h0000_0000_0000_0000, 64'h8000_0000_0000_0000,
                 1'b0, 1'b0, 1'b1, 1'b0, 1'b0,
                 1'b0, 1'b0, 1'b1, 1'b0, 1'b0);

        $display("-------Subsection 1.2: Subnormal * Subnormal--------");
        run_case("min_subnormal * min_subnormal", 64'h0000_0000_0000_0001, 64'h0000_0000_0000_0001,
                 1'b0, 1'b0, 1'b0, 1'b1, 1'b0,
                 1'b0, 1'b0, 1'b0, 1'b1, 1'b0);

        run_case("max_subnormal * min_subnormal", 64'h000f_ffff_ffff_ffff, 64'h0000_0000_0000_0001,
                 1'b0, 1'b0, 1'b0, 1'b1, 1'b0,
                 1'b0, 1'b0, 1'b0, 1'b1, 1'b0);

        run_case("max_subnormal * max_subnormal", 64'h000f_ffff_ffff_ffff, 64'h000f_ffff_ffff_ffff,
                 1'b0, 1'b0, 1'b0, 1'b1, 1'b0,
                 1'b0, 1'b0, 1'b0, 1'b1, 1'b0);

        run_case("signed subnormal product", 64'h8000_0000_0000_0001, 64'h0000_0000_0000_0002,
                 1'b0, 1'b0, 1'b0, 1'b1, 1'b0,
                 1'b0, 1'b0, 1'b0, 1'b1, 1'b0);

        $display("-------End FP64 Section 1--------");
        $finish;
    end


endmodule