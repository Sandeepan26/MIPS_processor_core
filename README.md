# MIPS_processor_core
This repository is code base related to the design of a MIPS (Microprocessor without Interlocked Pipeline Stages) Core

Features of the core:
1. 5- stage pipeline: Instruction Fetch, Instrution Decode, Execute, Memory, Write-Back.
2. Direct Mapped Cache with 4KiB size mapping to a Single-port RAM of size 4M x 32.
3.  Datapapath to enable support R-type (Register-Register), I-type(Integer-Immediate), J-type (Jump and Link), and B-type (Branch).
4.  Hazard Control Unit for handling data and control hazards via Forwarding, Stalling, and Flushing.
5.  Coprocessor for exception handling (undefined instruction  and arithmetic overflow).

Languages Used: System Verilog (IEEE 1800-2017) |
Methodology for Verification: Universal Verification Methodology (IEEE 1800.2-2020)

Data Path:

Instruction is read from a file "machine.dat" and is accessed by the Program Counter at every positive edge of the clock. The instructions are then fed to the pipeline register IF_ID. IF_ID is also connected with hazard control unit which enables "stall" and "flush" signals for stalling and flushing the pipeline. The next stage is decode where The controller decodes the instruction and enables the datapath for the operation of the MIPS hart (core). Register file access the indexes for writing and reading data to and from the registers. The stage aslo has a sign-immediate unit to convert an immediate value for arithmetic operation to 32-bits in length for being used as an operand in the arithmetic and logic unit.

The values read from the controller, register files and the sign-immediate unit is fed to the pipeline stage ID_EX. ID_EX propagates those signals to the Execute stage for arithmetic operation. This stage comprises of an Arithmetic and Logic Unit (ALU) which uses two operands to perform operations specified by the controller. The ALU takes two operands: one read from the register file and the other from either second register file read or sign-immediate unit depending on the instruction operation specified in the machine code. The values are then to be either stored in the memory or sent to the register file for writing data to the specified register. This is mediated by the pipleine register EX_MEM. EX_MEM takes data from the ALU and propagates it to the Memory. The core is accompanied by a single-port RAM of 4Mx32 memory. The address is specified by the rt (decond register read from register file) for reading and writing data.

The memory access is done via a direct mapped cache with 4KiB memory. The cache has 1024 cache block lines each with 53 bits of storage. The 32 bits from the LSB (indexes 0 to 31) contain the data mapped by the tag (indexes 32 to 51). The valid data is indicated by valid bit (index 52). Cache accesses the data from the memory in case of cache miss, and stores the data in the spcified cache block line. The data is then fed to the pipeline register MEM_WB. MEM_WB sends data to the register file and data is written to the register file on the positive clock edge.

The core has branch prediction done via comparison of values obtained from the register file (rs and rt). If the values are equal, that instruction is flushed and new instruction is fetched from Instruction Memory.

System Verilog assertions have been used for verifying the clock frequency and pipeline registers.
UVM is used for verifying the core operation. 

