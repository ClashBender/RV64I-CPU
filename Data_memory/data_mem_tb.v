`timescale 1ns/1ps
`include "data_mem.v"
module data_mem_tb;

    reg clk;
    reg reset;
    reg MemWrite;
    reg MemRead;
    reg [9:0] address;
    reg [63:0] write_data;
    wire [63:0] read_data;

    integer fd;
    integer i;

    // Instantiate the data memory module
    data_mem dut (
        .clk(clk),
        .reset(reset),
        .MemWrite(MemWrite),
        .MemRead(MemRead),
        .address(address),
        .write_data(write_data),
        .read_data(read_data)
    );

    // Clock generation (10ns period = 100MHz)
    always begin
        #5 clk = ~clk;
    end

    // Test stimulus
    initial begin
        clk = 0;
        reset = 0;
        MemWrite = 0;
        MemRead = 0;
        address = 0;
        write_data = 0;
        

        // Wait for initial setup
        #10;

        // Test 1: Write data to address 0
        $display("Test 1: Write 64'hDEADBEEFCAFEBABE to address 0");
        @(posedge clk);
        MemWrite = 1'b1;
        address = 10'd0;
        write_data = 64'hDEADBEEFCAFEBABE;
        @(posedge clk);
        MemWrite = 1'b0;

        // Test 2: Read from address 0
        $display("Test 2: Read from address 0");
        @(posedge clk);
        MemRead = 1'b1;
        address = 10'd0;
        @(posedge clk);
        $display("Read data: %016h", read_data);
        MemRead = 1'b0;

        // Test 3: Write data to address 8
        $display("Test 3: Write 64'h1234567887654321 to address 8");
        @(posedge clk);
        MemWrite = 1'b1;
        address = 10'd8;
        write_data = 64'h1234567887654321;
        @(posedge clk);
        MemWrite = 1'b0;

        // Test 4: Read from address 8
        $display("Test 4: Read from address 8");
        @(posedge clk);
        MemRead = 1'b1;
        address = 10'd8;
        @(posedge clk);
        $display("Read data: %016h", read_data);
        MemRead = 1'b0;

        // Test 5: Reset and dump data
        $display("Test 5: Asserting reset (will dump data to file)");
        //dump contents of data memory to a file (not required acc to new project doc)
            fd = $fopen("data_memory.txt", "w");
            for (i = 0; i < `MEM_SIZE; i = i + 1) begin
                $fwrite(fd, "%02h\n", dut.data[i]);
            end
            $fclose(fd);
        @(posedge clk);
        reset = 1'b1;
        @(posedge clk);
        reset = 1'b0;

        // Test 6: Verify data is cleared after reset
        $display("Test 6: Read from address 0 after reset (should be 0)");
        @(posedge clk);
        MemRead = 1'b1;
        address = 10'd0;
        @(posedge clk);
        $display("Read data: %016h", read_data);
        MemRead = 1'b0;

        $display("Test 7: Read from address 8 after reset (should be 0)");
        @(posedge clk);
        MemRead = 1'b1;
        address = 10'd8;
        @(posedge clk);
        $display("Read data: %016h", read_data);
        MemRead = 1'b0;

        // Wait a few cycles
        repeat(5) @(posedge clk);

        $display("Test completed");
        $finish;
    end

endmodule
