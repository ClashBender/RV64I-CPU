`ifndef CPU_PIPE_V
`define CPU_PIPE_V

`include "1_fetch/IF.v"
`include "2_decode/ID.v"
`include "3_execute/EX.v"
`include "4_memory/MEM.v"
`include "5_writeback/WB.v"
`include "Hazards/hazards.v"



module CPU_pipe(
    input clk, 
    input reset
);



// hazard detection block generates stall and flush control signals

// IF/ID reg: needs to hold previous values if stall is asserted, needs to be flushed with 0s if flush is asserted, else update on clock edge

// ID/EX reg: needs to take 0s if either stall or flush is asserted, else update on clock edge

// EX/MEM reg: needs to take 0s if flush is asserted, else update on clock edge

// MEM/WB reg: updates on every clock edge regardless of stall and flush

endmodule