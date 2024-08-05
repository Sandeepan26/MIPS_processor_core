/*------ Control Unit-------------------- */

module Control_Unit(input [5:0] opcode, [5:0] funct, output reg Mem_to_reg, MemWrite, Branch, ALUSrc, RegDst, Jump, RegWrite, reg [2:0] ALUCtl);

  
  reg [1:0] ALUop; //register to store ALU Operation
  
  always_comb begin
    case(opcode)
      0 : {Mem_to_reg, MemWrite, Branch, ALUSrc, RegDst, RegWrite, ALUop} = {1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b1, 2'b10};
      
      35 : {Mem_to_reg, MemWrite, Branch, ALUSrc, RegDst, RegWrite, ALUop} = {1'b1, 1'b0, 1'b0, 1'b1, 1'b0, 1'b1, 2'b00};
      
      43 : {Mem_to_reg, MemWrite, Branch, ALUSrc, RegDst, RegWrite, ALUop} = {1'bx, 1'b1, 1'b0, 1'b1, 1'bx, 1'b0, 2'b00};
      
      4 : {Mem_to_reg, MemWrite, Branch, ALUSrc, RegDst, RegWrite, ALUop} = {1'bx, 1'b0, 1'b1, 1'b0, 1'bx, 1'b0, 2'b01};
        
      8 : {Mem_to_reg, MemWrite, Branch, ALUSrc, RegDst, RegWrite, ALUop, Jump} = {1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 2'b00, 1'b0}; // made changes for jump
      
      2 : {Mem_to_reg, MemWrite, Branch, ALUSrc, RegDst, RegWrite, ALUop, Jump} = {1'b0, 1'bx, 1'bx, 1'bx, 1'b0, 1'bx, 2'bxx, 1'b1}; //made the changes for jump
      
    endcase
  end
  
 //ALU Decoder
  
   always_comb begin
     case(ALUop)
      2'b00 : ALUCtl = 3'b010; //add 
      2'b01 : ALUCtl = 3'b110; //subtract
      2'b10:
        begin
          case(funct)
            6'b100000 : ALUCtl = 3'b010; //add
            6'b100010 : ALUCtl = 3'b110; //subtract
            6'b100100 : ALUCtl = 3'b000; //and
            6'b100101 : ALUCtl = 3'b001; //or
            6'b101010 : ALUCtl = 3'b111; //slt
          endcase
        end
      default : ALUCtl = 3'b010; //add operation set as default
    endcase
  end 
   
  
endmodule
