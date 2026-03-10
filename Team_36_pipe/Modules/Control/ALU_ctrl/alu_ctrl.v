`ifndef ALU_CTRL_V
`define ALU_CTRL_V

module ALU_Control(
    input [1:0] ALUOp,
    input [6:0] funct7,
    input [2:0] funct3,
    input inst5,        // this is the only diff between R-type and I-type ALU functions
    output reg [3:0] ALU_ctrl
);

    wire inst30 = funct7[5];

    always @ (*) begin
        case(ALUOp)
            2'b00: ALU_ctrl = 4'b0000;                          // lw + sw
            2'b01: ALU_ctrl = 4'b1000;                          // beq, bne, etc.
            2'b10: begin                                        // add, srli, etc.
                if(funct3 == 3'b000)
                    ALU_ctrl = {inst30 & inst5, 3'b000};        // only add, sub, addi 
                else if(funct3 == 3'b101)   
                    ALU_ctrl = {inst30, 3'b101};                // need to diff for both srl/sra and srli/srai
                else
                    ALU_ctrl = {1'b0, funct3};                  // others dont need inst30 as a choice
            end
            default: ALU_ctrl = 4'b0000;
        endcase
    end

endmodule

`endif