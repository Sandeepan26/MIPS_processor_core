/*-----------pipeline register for mediating signals between FETCH to DECODE stage------*/

module IF_ID (input CLK, EN, CLR, [31:0] RD_IN, PCPlus4F, output reg [31:0] InstrD, PCPlus4D);
  
  always @(posedge CLK, EN)begin
    if(!EN) begin   //EN is asynchronous. active high. when asserted, the output is supposed to retrain old instructions
    	InstrD <= InstrD;
      	PCPlus4D <= PCPlus4D;
    end
    else if (CLR)
    	InstrD <= 'b0; //flushing the pipeline at fetch stage in case of a branch  
    else begin  //if EN == 1;, then it will fetch new instruction
    	InstrD <= RD_IN;
    	PCPlus4D <= PCPlus4F; 
  	end
  end
  
endmodule

/*--------------------pipeline for DECODE to EXECUTE stage---------------------*/

module ID_EX (CLK, EN, RegWriteD, MemtoRegD, MemWriteD, ALUControlD, ALUSrcD, RegDstD, RD1, RD2, RsD, RtD, RdD, RegWriteE, MemtoRegE, MemWriteE, ALUControlE, ALUSrcE, RegDstE, RD1E, RD2E, RsE, RtE, RdE);
  //non-ANSI style port declaration
  
  input CLK, EN, RegWriteD, MemtoRegD, MemWriteD, ALUSrcD, RegDstD;
  input [2:0] ALUControlD;
  input [31:0] RD1, RD2;
  input [4:0] RtD, RdD, RsD;
  
  output reg RegWriteE, MemtoRegE, MemWriteE, ALUSrcE, RegDstE;
  output reg [2:0] ALUControlE;
  output reg [31:0] RD1E, RD2E;
  output reg [4:0] RtE, RdE, RsE; 
  
  always @(posedge CLK)
    begin
      if(!EN)
      {RegWriteE, MemtoRegE, MemWriteE, ALUControlE, ALUSrcE, RegDstE, RD1E, RD2E, RsE, RtE, RdE} = {RegWriteE, MemtoRegE, MemWriteE, ALUControlE, ALUSrcE, RegDstE, RD1E, RD2E, RsE, RtE, RdE};
      else
      {RegWriteE, MemtoRegE, MemWriteE, ALUControlE, ALUSrcE, RegDstE, RD1E, RD2E, RsE, RtE, RdE} = {RegWriteD, MemtoRegD, MemWriteD, ALUControlD, ALUSrcD, RegDstD, RD1, RD2, RsD, RtD, RdD};
    end
  
  
endmodule

/*----------------------pipeline from EXECUTE to MEMORY---------------------*/

module EX_MEM (CLK, CLR, RegWriteE, MemtoRegE, MemWriteE, Zero_ALU_E, ALUOut_E, WriteDataE, WriteRegE, RegWriteM, MemtoRegM, MemWriteM, Zero_ALU_M, ALUOut_M, WriteDataM, WriteRegM);
  
  input CLK, CLR, RegWriteE, MemtoRegE, MemWriteE, Zero_ALU_E;
  input [4:0] WriteRegE;
  input [31:0] ALUOut_E, WriteDataE;
  
  output reg RegWriteM, MemtoRegM, MemWriteM, Zero_ALU_M;
  output reg [4:0] WriteRegM;
  output reg [31:0] ALUOut_M, WriteDataM;
  
  always @(posedge CLK)
    if(CLR)
    {RegWriteM, MemWriteM} = 2'b00;
  	else
    {RegWriteM, MemtoRegM, MemWriteM, Zero_ALU_M, ALUOut_M, WriteDataM, WriteRegM} = {RegWriteE, MemtoRegE, MemWriteE, Zero_ALU_E, ALUOut_E, WriteDataE, WriteRegE};
  
  
endmodule


/*----------------------MEMORY to WRITE-BACK---------------------------*/

module MEM_WB(CLK, RegWriteM, MemtoRegM, WriteRegM, ALUOutM, ReadDataM, RegWriteW, MemtoRegW, WriteRegW, ALUOutW, ReadDataW);
  
  input CLK, RegWriteM, MemtoRegM;
  input [4:0] WriteRegM;
  input [31:0] ALUOutM, ReadDataM;
  
  output reg RegWriteW, MemtoRegW;
  output reg [4:0] WriteRegW;
  output reg [31:0] ALUOutW, ReadDataW;
  
  always @(posedge CLK)
  {RegWriteW, MemtoRegW, WriteRegW, ALUOutW, ReadDataW} = {RegWriteM, MemtoRegM, WriteRegM, ALUOutM, ReadDataM};
  
  
endmodule
