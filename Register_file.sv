/*--------REGISTER FILE----------------- */

module REGISTER_FILE #(parameter XLEN = 32, index = 5)(input CLK, [(index-1):0] A1, A2, A3, wire WE3, wire [(XLEN-1):0] WD3, output  [(XLEN-1):0] RD1, [(XLEN-1):0] RD2);
  
  reg [(XLEN-1):0] register [(XLEN-1):0]; //x0 - x31, available: x1 - x31
  //mixed array
  
  //register[0], register[1] : each 32 bits
  //can be accessed by 5 bit IDX: 2**5 = 32 values..
  // IDX = 5'b10000; last reg point
  
  reg [(XLEN-1):0] PC_REG;
  
  //initial register[0] = {32{1'b0}}; //x0 is hardwired to zero

  assign RD1 = register[A1];
  assign RD2 = register[A2];
  
  int i = 1;
  
  always @(posedge CLK) begin
    if((WE3) && (A3 != 'b0)) //WE3 = 1 for write, only when RegWrite is set to 1. Two c
    	register[A3] <= WD3;
  end
  
endmodule
