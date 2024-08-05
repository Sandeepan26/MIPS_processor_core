`include "Register_file.sv"
`include "Instruction_Memory.sv"
`include "Data_Memory.sv"
`include "Control_Unit.sv"
`include "ALU.sv"
`include "PC.sv"
`include "Pipeline_Stages.sv"
`include "Logic_blocks.sv"
`include "Hazard_Unit.sv"
`include "cache.sv"

/*----------------Pipelined Data Path---------------- */

module Pipelined_Data_Path(input clk, [31:0] pc);
  
 
  //declaring signals
  
  wire [31:0] pc_out;
  wire [31:0] pc_plus_4, pc_next_instr;
  //assign pc_out  = pc;
  wire [31:0] Instr;
  wire [31:0] rd_1, rd_2;
  wire RegWrite;
  wire [31:0] sign_imm;
  wire [31:0] alu_result;
  wire zero_flag;
  wire [31:0] read_data_bus;
  wire [31:0] alu_to_reg_out;
  wire mem_to_reg; // this value is 0 for R-type instructrions
  wire ALUsrc; //0 for R-type instructions
  wire [31:0] mx_to_alu;
  wire reg_dest; //1 for R-type instruction
  wire [4:0] write_reg;
  wire branch_sel, BranchD, PCSrcD;
  wire [31:0] mux_to_pc;
  wire [31:0] adder_to_pc;
  wire mem_write;
  wire [2:0] alu_control;
  wire Jump;
  wire [27:0] jump_ext;  //for jump extension signal
  assign jump_ext = Instr[25:0] << 2; //to store shifted bits
  wire [31:0] InstrD, PCPlus4D; 
  wire RegWriteE, RegDstE, BranchE, MemtoRegE, MemWriteE, ALUSrcE;
  wire [2:0] ALUControlE;
  wire [31:0] RD1E, RD2E, SignImmE, PCPlus4E;
  wire [4:0] RtE, RdE, RsE;
  wire RegWriteM, MemtoRegM, MemWriteM, BranchM;
  wire ZeroM;
  wire [4:0] WriteRegM;
  wire [31:0] ALUOutM;
  wire [31:0] WriteDataM, PCBranchM;
  wire RegWriteW, MemtoRegW;
  wire [31:0] ALUOutW, ReadDataW;
  wire [4:0] WriteRegW;
  wire [1:0] Forward_AE, Forward_BE;
  wire[31:0] SrcAE, SrcBE;
  wire StallD, StallF, FlushE;
  wire EqualID;
  wire [31:0] mem_to_cache_data, cache_to_mem_data, cache_to_mem_address;
  wire cache_mem_wr_en;
   //Instantiating components
  
  mux PC_branch_mux(.a(pc_plus_4), .b(adder_to_pc), .sel(branch_sel), .out(mux_to_pc)); //MUX to select next PC
  
  
  
  mux PC_jump_mux(.a(mux_to_pc), .b({{4{1'b0}},jump_ext}), .sel(Jump), .out(pc_next_instr)); //MUX to select next PC (Made the changes over here for jump
  
  PC PC_Inst (.clk(clk), .PC_NEXT(pc), .PC_CRNT(pc_out)); //PC instance
  
  PC_Adder PC_Plus__4 (.PC_instr(pc_out), .PC_nxt_instr(pc_plus_4)); //PC Adder Instance
  
  
  Instruction_Memory Instr_Mem(.PCF(pc_out), .instruction(Instr));  //Instruction Memory instance
  
  //first pipeline register : Fetch to Decode
  
  IF_ID IF_ID_Stage(.CLK(clk), .EN(StallF), .CLR(PCSrcD), .RD_IN(Instr), .PCPlus4F(pc_plus_4), .InstrD(InstrD), .PCPlus4D(PCPlus4D));
  
  //Control Unit instance
  
  Control_Unit cntrl_unit(.opcode(InstrD[31:26]), .funct(InstrD[5:0]),.Mem_to_reg(mem_to_reg), .MemWrite(mem_write), .Branch(BranchD), .ALUSrc(ALUsrc), .RegDst(reg_dest), .RegWrite(RegWrite), .ALUCtl(alu_control), .Jump(Jump)); 
  
  
  //Register file instance
  
  REGISTER_FILE RegFile(.CLK(clk), .A1(InstrD[25:21]), .RD1(rd_1), .RD2(rd_2), .A2(InstrD[20:16]), .A3(WriteRegW), .WD3(alu_to_reg_out), .WE3(RegWriteW)); //RegFile Instance
  
  //sign extension instance
  
  SignExtend SigExtd (.IMM(InstrD[15:0]), .SignImm(sign_imm)); //Sign Immediate instance
  
  //muxes for branch instruction..
  wire Forward_AD, Forward_BD;
  wire [31:0] r_1_out, r_2_out;
  
  mux r_1_mx(.a(rd_1), .b(ALUOutM), .sel(Forward_AD), .out(r_1_out)); //forwardAD as sel
  mux r_2_mx(.a(rd_2), .b(ALUOutM), .sel(Forward_BD), .out(r_2_out)); //forwardBD as sel
  
             
  assign EqualID = (r_1_out == r_2_out);
             
  //ANDing for branch operation to be fed to 0 for PC_branch_MUX
  and(PCSrcD, BranchD, EqualID); 
  
  
  Adder PC_Branch_Adder(.a_1((sign_imm<<2)), .a_2(PCPlus4D), .adder_out(adder_to_pc)); //Adder: PC + 4 + SignImm*4
  
  
  //second pipeleline stage : Decode to Execute 
  
  ID_EX ID_EX_Stage(.CLK(clk), .EN(StallD), .RegWriteD(RegWrite), .RegDstD(reg_dest), .MemtoRegD(mem_to_reg), .MemWriteD(mem_write), .ALUSrcD(ALUsrc), .ALUControlD(alu_control), .RD1(rd_1), .RD2(rd_2), .RsD(InstrD[25:21]), .RtD(InstrD[20:16]), .RdD(InstrD[15:11]), .RegWriteE(RegWriteE), .RegDstE(RegDstE), .MemtoRegE(MemtoRegE), .MemWriteE(MemWriteE), .ALUSrcE(ALUSrcE), .ALUControlE(ALUControlE), .RD1E(RD1E), .RD2E(RD2E), .RtE(RtE), .RdE(RdE), .RsE(RsE));
  
   
  mux regfile_to_alu (.a(SrcBE), .b(SignImmE), .sel(ALUSrcE), .out(mx_to_alu)); 
  //MUX connecting to ALU. This is needed to map the register file output directly for R-type instructions. for I-type, ALUsrc will be set to 1
  
  //this mux takes forward AE as select for rs1
  hazard_mux hmux_rs1(.a(RD1E), .b(alu_to_reg_out), .c(ALUOutM), .sel(Forward_AE), .res(SrcAE));
  
  
  //this mux takes forward AE as select for rs2
  hazard_mux hmux_rs2(.a(RD2E), .b(alu_to_reg_out), .c(ALUOutM), .sel(Forward_BE), .res(SrcBE));
  
  ALU ALU_Inst (.SrcA(SrcAE), .SrcB(mx_to_alu), .ALU_Control(ALUControlE), .Zero(zero_flag), .ALU_Result(alu_result)); //ALU Instance
  
  
  mux register_dest(.a(RtE), .b(RdE), .sel(RegDstE), .out(write_reg)); 
  //MUX to select register destination
  defparam register_dest.width = 5;
  
  
  //third pipeline register : EXECUTE to MEMORY
  
  EX_MEM EX_MEM_Stage(.CLK(clk), .CLR(FlushE), .RegWriteE(RegWriteE), .MemtoRegE(MemtoRegE), .MemWriteE(MemWriteE), .Zero_ALU_E(zero_flag), .WriteRegE(write_reg), .ALUOut_E(alu_result), .WriteDataE(SrcBE), .RegWriteM(RegWriteM), .MemtoRegM(MemtoRegM), .MemWriteM(MemWriteM), .Zero_ALU_M(ZeroM), .WriteRegM(WriteRegM), .ALUOut_M(ALUOutM), .WriteDataM(WriteDataM));
  
    //cache instance
  
  cache_mem cache_mem_inst(.w_e(MemWriteM), .clk(clk), .cpu_address(ALUOutM), .cpu_data(WriteDataM), .mem_to_cache_data(mem_to_cache_data), .cache_data_out(read_data_bus), .cache_to_mem_data(cache_to_mem_data), .cache_to_mem_address(cache_to_mem_address), .wr_mem(cache_mem_wr_en));
  
  Data_Memory Data_Mem (.CLK(clk), .ALUResultM(cache_to_mem_address), .WriteDataM(cache_to_mem_data), .ReadData(mem_to_cache_data), .MemWriteM(cache_wr_mem_en)); //Data Memory Instance
  
 //fourth pipeline register : MEMORY to WRITE BACK
  
  
  MEM_WB MEM_WB_Stage(.CLK(clk), .RegWriteM(RegWriteM), .MemtoRegM(MemtoRegM), .WriteRegM(WriteRegM), .ReadDataM(read_data_bus), .ALUOutM(ALUOutM), .RegWriteW(RegWriteW), .MemtoRegW(MemtoRegW), .ALUOutW(ALUOutW), .ReadDataW(ReadDataW), .WriteRegW(WriteRegW));
  
  
  mux alu_to_reg (.a(ALUOutW), .b(ReadDataW), .sel(MemtoRegW), .out(alu_to_reg_out));       //MUX connecting ALUResult and ReadData of Data Memory as input and proagating the desired value to register file for writeback based on mem_to_reg signal
  
  
connecting ALUResult and ReadData of Data Memory as input and proagating the desired value to register file for writeback based on mem_to_reg signal
  
  
/*----------------------------HAZARD UNIT------------------------------*/
  
  Hazard_Unit hzunit(.WriteRegM(WriteRegM), .RegWriteM(RegWriteM), .RsD(InstrD[25:21]), .RsE(RsE), .RtD(InstrD[20:16]), .RtE(RtE), .RegWriteW(RegWriteW), .WriteRegW(WriteRegW), .BranchD(BranchD), .MemtoRegE(MemtoRegE), .Forward_AE(Forward_AE), .Forward_BE(Forward_BE), .StallF(StallF), .StallD(StallD), .FlushE(FlushE), .ForwardAD(Forward_AD), .ForwardBD(Forward_BD), .WriteRegE(write_reg), .MemtoRegM(MemtoRegM), .RegWriteE(RegWriteE));
  
  
  
endmodule
