/*--------DATA MEMORY------------------ */


module Data_Memory (
    input      [31:0] WriteDataM,
    input      [31:0] ALUResultM,
    input             CLK,
    input             MemWriteM,
   // input             RST,
    output reg [31:0] ReadData
);

    reg [31:0] Data_Mem [255:0];   //2D array for data memory
    integer i;

  
  always @(posedge CLK) 
    begin
        if(MemWriteM) //MemWriteM = 1 for write
         Data_Mem[ALUResultM] <= WriteDataM;
    	
      else
        ReadData <= Data_Mem[ALUResultM];
    end
    
endmodule
