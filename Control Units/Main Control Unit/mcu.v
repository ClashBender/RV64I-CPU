module mcu(
    input [6:0] opcode,
    output reg branch,
    output reg jump,
    output reg MemRead,
    output reg [1:0] MemToReg,
    output reg [1:0] ALUOp,
    output reg MemWrite,
    output reg ALUSrc,
    output reg RegWrite 
);

    always @ (*) begin

        branch <= 1'b0;
        jump <= 1'b0;
        MemRead <= 1'b0;
        MemToReg <= 2'b00;
        ALUOp <= 2'b00;
        MemWrite <= 1'b0;
        ALUSrc <= 1'b0;
        RegWrite <= 1'b0;

        casez(opcode)
            7'b0z10011: begin       // R/I type ALU instructions
                RegWrite <= 1'b1;
                ALUOp <= 2'b10;
                ALUSrc <= ~opcode[5];
            end
            7'b0z00011: begin      // lw(0) and sw(1) type instructions
                ALUSrc <= 1'b1;
                RegWrite <= ~opcode[5];
                MemRead  <= ~opcode[5];
                MemWrite <= opcode[5];
                MemToReg <= {1'b0, ~opcode[5]};
            end
            7'b1100011: begin      // B type
                branch <= 1'b1;
                ALUOp <= 2'b01;
            end
            7'b110z111: begin      // J type
                jump <= 1'b1;
                RegWrite <= 1'b1;
                MemToReg <= 2'b10;
            end
        endcase
    end

endmodule