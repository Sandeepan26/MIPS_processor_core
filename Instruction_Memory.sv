//`include "machine_code.dat"


/*-------------INSTRUCTION MEMORY----------------- */


module Instruction_Memory (
    input      [31:0] PCF,
    output [31:0] instruction
);
    
  reg [31:0] RAM [1023:0];   //maximum 1024 instructions stored

  
  assign instruction =  RAM[PCF]; 
    
  initial begin
    $readmemh("machine.dat", RAM, 0, 17);
    #1 $display("Contents of RAM : %p", RAM[17:0]);
  end
endmodule
