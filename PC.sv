/*----- PROGRAM COUNTER---------------- */

module PC (input clk, [31:0] PC_NEXT, output reg [31:0] PC_CRNT);
  
  always @(posedge clk) 
    PC_CRNT = PC_NEXT;
  
endmodule

/*----PC ADDER----------------------------- */

module PC_Adder(input [31:0] PC_instr, output [31:0] PC_nxt_instr);
  
  assign PC_nxt_instr = PC_instr + 4;
  
endmodule
