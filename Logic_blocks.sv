/*--------------SIGN IMMEDIATE--------------- */

module SignExtend(input [15:0] IMM, output[31:0] SignImm);
  
  assign SignImm = {{16{IMM[15]}} , IMM}; //32 bits..MSB of IMM copied to upper 16 bits
  
endmodule

/*-----------MUX LOGIC---------------- */

module mux #(parameter width = 32)(input [(width-1):0]a, b, wire sel, output [(width-1):0]out);
  assign out = sel? b : a;
endmodule


/*-----------ADDER--------------------- */

module Adder #(parameter width = 32)(input [(width-1): 0] a_1, a_2, output [(width-1):0]adder_out);
  
  assign adder_out = a_1 + a_2;

endmodule

/*------HAZARD MUX------------ */

module hazard_mux #(parameter width = 32)(input [1:0] sel, [(width-1):0] a, b, c, output [(width-1):0] res);
  
  reg [(width-1):0] val;
  assign res = val;
  
  always @(a, b, c, sel) begin
    case(sel)
      2'b00 : val = a;
      2'b01 : val = b;
      2'b10: val = c;
    endcase
  end
  
endmodule
