
// hazard detection block generates stall and flush control signals

// IF/ID reg: needs to hold previous values if stall is asserted, needs to be flushed with 0s if flush is asserted, else update on clock edge

// ID/EX reg: needs to take 0s if either stall or flush is asserted, else update on clock edge

// EX/MEM reg: needs to take 0s if flush is asserted, else update on clock edge

// MEM/WB reg: updates on every clock edge regardless of stall and flush