module hazard_det (
    //these inputs detect a load use stall
    input [4:0] rs1_id, rs2_id, rd_ex,
    input mem_read_ex,

    //these inputs r for a flush
    input pc_src_mem,
    
    output reg stall, flush
);

    always @(*) begin
        // Load-use hazard detection
        if (mem_read_ex && ((rd_ex == rs1_id) || (rd_ex == rs2_id))) begin
            stall = 1'b1;
            flush = 1'b0;
        end
        // Control hazard detection (for branches)
        else if (pc_src_mem) begin //pc_src_mem is the output of (zero_flag & branch_signal)
            stall = 1'b0;
            flush = 1'b1;
        end
        else begin
            stall = 1'b0;
            flush = 1'b0;
        end
    end



endmodule