`timescale 1ns/1ps

module inst_tb;

reg clk, reset;
reg [63:0] addr;
wire [31:0] inst;

// Instantiating
instmem dut (
    .clk(clk),
    .reset(reset),
    .addr(addr),
    .inst(inst)
);

always #5 clk = ~clk;
initial begin
    clk = 0;
    reset = 1;
    addr = 0;
    $dumpfile("inst_tb.vcd");
    $dumpvars(0, inst_tb);
    #10;
    reset = 0;
// Reading first 10 instructions from instruction memory
    repeat (10) begin
        #10;
        $display("Time=%0t | PC=%0d | Instruction=%h",
                  $time, addr, inst);

        addr = addr + 4;   // incrementing PC
    end

    #20;
    $finish;
end

endmodule
