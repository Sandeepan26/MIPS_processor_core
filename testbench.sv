`include "Top_module.sv"

`timescale 1ps/1fs 

module test;
  
  reg clk;
  reg [31:0] pc;
  wire [31:0] pc_1;
  
  //PC PC_ii(clk, pc, pc_1);
  Pipelined_Data_Path PDP(clk, pc);
  always #2 clk = ~clk;
  
 
  initial begin
    $monitor("PC input : %b \t Instr output : %b", pc, PDP.Instr);
    pc = {32{1'b0}};
    clk = 'b0;
    
    repeat(18) @(negedge clk) begin
      	pc = pc+ 1;
    end
    
    $dumpfile("proc.vcd");
    $dumpvars(2, PDP);
    
    #500 $finish(1);
  end
endmodule
