/*-------ARITHMETIC LOGIC UNIT--------------------- */

module ALU (input [31:0] SrcA, [31:0] SrcB, [2:0] ALU_Control,output  Zero, reg [31:0] ALU_Result);
  
 
 always_comb begin
    case(ALU_Control)
      3'b000: ALU_Result = SrcA & SrcB;
      3'b001: ALU_Result = SrcA | SrcB;
      3'b010: ALU_Result = SrcA + SrcB;
      3'b100: ALU_Result = ~(SrcA | SrcB);  //NOR
      3'b101: ALU_Result = SrcA ^ SrcB; //XOR
      3'b110: ALU_Result = SrcA - SrcB;
      3'b111: ALU_Result = (SrcA < SrcB)? 1'b1 : 1'b0;  //SLT
      default : ALU_Result = 1'b0;
    endcase
  end
  
  assign Zero = !ALU_Result ? 1'b1: 1'b0;
  
endmodule
