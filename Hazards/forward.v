module forward(
    input [4:0] rs1_ie, rs2_ie, rs2_em,
    input [4:0] rd_em, rd_mw,
    input reg_write_em, mem_write_em, reg_write_mw,
    output reg [1:0] forward_ae, forward_be,
    output reg forward_m
);

    always @(*) begin

    // for rs1
        if(((rs1_ie == rd_em) && reg_write_em) & (rs1_ie)) // EX-MEM hazard
            forward_ae = 2'b10;
        else if(((rs1_ie == rd_mw) && reg_write_mw) & (rs1_ie)) // MEM-WB hazard
            forward_ae = 2'b01;
        else
            forward_ae = 2'b00;

    // for rs2
        if(((rs2_ie == rd_em) && reg_write_em) & (rs2_ie)) // EX-MEM hazard
            forward_be = 2'b10;
        else if(((rs2_ie == rd_mw) && reg_write_mw) & (rs2_ie)) // MEM-WB hazard
            forward_be = 2'b01;
        else
            forward_be = 2'b00;

    // ld -> sd forwarding
        if(((rd_mw == rs2_em) && mem_write_em) & (rd_mw))
            forward_m = 1'b1;
    end

    // load-use data hazard


endmodule