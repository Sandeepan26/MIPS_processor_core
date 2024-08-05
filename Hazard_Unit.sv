module Hazard_Unit (WriteRegM, RegWriteM, RsD, RsE, RtD, RtE, RegWriteW, WriteRegW, MemtoRegE, Forward_AE, Forward_BE, StallF, StallD, FlushE, BranchD, RegWriteE, WriteRegE, MemtoRegM, ForwardAD, ForwardBD);
  
  input [4:0] RsE, RsD, RtD, RtE;  //source registers
  input RegWriteM, RegWriteE, RegWriteW, MemtoRegE, MemtoRegM, BranchD;
  input [4:0] WriteRegM, WriteRegW, WriteRegE;
  
  output reg [1:0] Forward_AE, Forward_BE;
  output StallD, StallF, FlushE, ForwardAD, ForwardBD;
  
  reg stall; //store the value for stalling the pipeline
  reg bstall; //branch stall
  
  assign {StallD, StallF, FlushE} = {3{bstall || stall}}; //all outputs to be mapped with stall value to be fed as inputs to the pipeline
  
  assign ForwardAD = ((RsD!='b0) && ((RsD == WriteRegM) && RegWriteM)); //sets value for ForwardAD
  
  assign ForwardBD = ((RtD!='b0) && ((RtD == WriteRegM) && RegWriteM)); //sets value for ForwardBD
  
  //forwarding 
  always @(WriteRegM, RegWriteM, RegWriteW, WriteRegW, RsE, RtE)
    begin
      //condition check for Forward_AE
      
  	if((RsE != 'b0) && ((RsE == WriteRegM) && RegWriteM))
    	Forward_AE = 2'b10;  // input from ALU
    else if((RsE!= 'b0) && ((RsE == WriteRegW) && RegWriteW))
    	Forward_AE = 2'b01; // input from memory
  	else
    	Forward_AE = 2'b00; //normal input from pipeline..no hazard detected
    
      //condition check for Forward_BE
      
      if((RtE != 'b0) && ((RtE == WriteRegM) && RegWriteM))
    	Forward_BE = 2'b10;  // input from ALU
      else if((RtE!= 'b0) && ((RtE == WriteRegW) && RegWriteW))
    	Forward_BE = 2'b01; // input from memory
  	else
    	Forward_BE = 2'b00; //normal input from pipeline..no hazard detected
      
    end
  
  
  //stalling
  
  always @(RsD, RtE, RtD)
    begin
    stall = (((RsD == RtE) || ((RtD == RtE) && MemtoRegE)));
    bstall = (((BranchD && RegWriteE) && ((WriteRegE == RsD) || (WriteRegE == RtD))) || ((BranchD && MemtoRegM) && ((WriteRegM == RsD) || (WriteRegM == RtD))));
    end
endmodule
