module hazards(
    input [4:0] rs1_d, rs2_d, rs1_e, rs2_e, rs2_m,
    input [4:0] rd_e, rd_m, rd_w,
    input reg_write_m, mem_write_m, reg_write_w, pc_src_m, mem_write_d,
    input [1:0] mem_to_reg_e, //00 for R-type, 01 for ld, 10 for jalr
    output reg [1:0] forward_ae, forward_be,
    output reg forward_m, 
    output reg stall, flush
);

    always @(*) begin

        forward_m = 1'b0;

    // for rs1
        if(((rs1_e == rd_m) && reg_write_m) && (rs1_e != 0)) // EX-MEM hazard
            forward_ae = 2'b10;
        else if(((rs1_e == rd_w) && reg_write_w) && (rs1_e != 0)) // MEM-WB hazard
            forward_ae = 2'b01;
        else
            forward_ae = 2'b00;

    // for rs2
        if(((rs2_e == rd_m) && reg_write_m) && (rs2_e != 0)) // EX-MEM hazard
            forward_be = 2'b10;
        else if(((rs2_e == rd_w) && reg_write_w) && (rs2_e != 0)) // MEM-WB hazard
            forward_be = 2'b01;
        else
            forward_be = 2'b00;

    // ld -> sd forwarding
        if(((rd_w == rs2_m) && reg_write_w && mem_write_m) && (rs2_m != 0))
            forward_m = 1'b1;


    // STALL/FLUSH DETECTION 

        stall = 1'b0;
        flush = 1'b0;
        // Load-use hazard detection
        // 01 => data memory read and will be written into reg in wb stage. 
        // mem_write_d ensures that it does not trigger for the case of "ld followed by sd", since that case can be resolved with forwarding
        if ((mem_to_reg_e == 2'b01) && (mem_write_d) && (rd_e != 0) && ((rs1_d == rd_e) || (rs2_d == rd_e))) begin 
            stall = 1'b1;
        end
        // Control hazard detection (for branches and jal)
        else if (pc_src_m) begin //pc_src_mem is the output of ((zero_flag & branch_signal)||jump)
            flush = 1'b1;
        end
    
    end

endmodule