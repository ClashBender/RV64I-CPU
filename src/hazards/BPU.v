module branch_prediction_unit(
    input clk, reset, 

    // wires in IF
    input [63:0] PC_F,
    output reg [63:0] pred_PC_F,
    output reg pred_taken_F,

    // wires from EX
    input update_E,             // enable to rewrite 
    input [63:0] PC_E,          // original pc in EX 
    input [63:0] res_target_E,  // actual next pc
    input res_taken_E           // actual outcome - 1 if branch, 0 if pc + 4
);

reg [51:0] tag_table [0:1023];  // tag bits = PC[63:12]
reg [63:0] btb_table [0:1023];  // [63:2] predicted target, [1:0] 2-bit counter
reg        valid_table [0:1023];

// Combinational prediction path
always @(*) begin
    pred_taken_F = 1'b0;
    pred_PC_F = PC_F + 64'd4;

    if (valid_table[PC_F[11:2]] && (tag_table[PC_F[11:2]] == PC_F[63:12])) begin
        pred_taken_F = btb_table[PC_F[11:2]][1];
        if (btb_table[PC_F[11:2]][1])
            pred_PC_F = {btb_table[PC_F[11:2]][63:2], 2'b00};
    end
end

// Sequential update path
integer i;
always @(posedge clk or posedge reset) begin
    if (reset) begin
        for (i = 0; i < 1024; i = i + 1) begin
            valid_table[i] <= 1'b0;
            tag_table[i] <= 52'b0;
            btb_table[i] <= {62'b0, 2'b01};
        end
    end
    else if (update_E) begin
        valid_table[PC_E[11:2]] <= 1'b1;
        tag_table[PC_E[11:2]] <= PC_E[63:12];
        btb_table[PC_E[11:2]][63:2] <= res_target_E[63:2];

        // 2-bit saturating FSM update
        if (res_taken_E) begin
            if (btb_table[PC_E[11:2]][1:0] < 2'b11)
                btb_table[PC_E[11:2]][1:0] <= btb_table[PC_E[11:2]][1:0] + 2'b01;
        end
        else begin
            if (btb_table[PC_E[11:2]][1:0] > 2'b00)
                btb_table[PC_E[11:2]][1:0] <= btb_table[PC_E[11:2]][1:0] - 2'b01;
        end
    end
end

endmodule