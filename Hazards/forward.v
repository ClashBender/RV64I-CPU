module forward(
    input [4:0] rs1_d, rs2_d, rs1_e, rs2_e, rs2_m,
    input [4:0] rd_e, rd_m, rd_w,
    input reg_write_m, mem_write_m, reg_write_w,
    input [1:0] mem_to_reg_e,
    output reg [1:0] forward_ae, forward_be,
    output reg forward_m, 
    output stall_d, stall_f
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
    
    end

    // load-use data hazard
    wire lw_stall;
    assign lw_stall = mem_to_reg_e[0] & (rd_e != 0) && ((rs1_d == rd_e) || (rs2_d == rd_e));      
    assign stall_d = lw_stall;
    assign stall_f = lw_stall;

endmodule