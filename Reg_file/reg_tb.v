`timescale 1ns/1ps

module reg_tb;
reg [63:0] registers [31:0];
reg clk, reset;
reg [4:0] read_reg1, read_reg2, write_reg;
reg [63:0] write_data;
reg reg_write_en;
wire [63:0] read_data1, read_data2;
// Instantiate
reg_file uut (
    .clk(clk),
    .reset(reset),
    .read_reg1(read_reg1),
    .read_reg2(read_reg2),
    .write_reg(write_reg),
    .write_data(write_data),
    .reg_write_en(reg_write_en)
);

// Testbench stimulus
initial begin
    clk = 0;
    reset = 1;
    #10 reset = 0;
    
    // Test writing to register 5
    write_reg = 5;
    write_data = 64'hDEADBEEFCAFEBABE;
    reg_write_en = 1;
    #10 reg_write_en = 0;

    //  Test reading from register 5
    read_reg1 = 5;
    read_reg2 = 0; // Read from register 0 (should be zero)
    
end

always #5 clk = ~clk;
// writing all the register outputs to file registers.txt
integer file_handle;
integer i;
integer clk_count = 0;
always @(posedge clk)
    clk_count = clk_count + 1;

initial begin
    file_handle = $fopen("registers.txt", "w");

    if (file_handle == 0) begin
        $display("Error: Could not open file.");
        $finish;
    end

    $dumpfile("reg_tb.vcd");
    $dumpvars(0, reg_tb);

    #100;   

    // Writing contents of all registers to file
    for (i = 0; i < 32; i = i + 1) begin
        $fdisplay(file_handle, "%h", uut.registers[i]);
    end

    // Wriing CLock cycles to file
    $fdisplay(file_handle, "%0d", clk_count);

    $fclose(file_handle);
    $finish;
end


endmodule