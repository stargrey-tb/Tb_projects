module Datapath(
input [31:0] set_out,
input [1:0] reg_file_sel,
input shift_mux_sel,
input [1:0] shft_ctrl,
input Clock,
input Reset,
input [1:0] PCSrc,
input ResultSrc,
input MemWrite,
input [3:0] ALUControl,
input ALUSrc,
input [3:0]ImmSrc,
input RegWrite,
input [4:0] Debug_in,
input [1:0] byte_ldr,
output Zero,
output [31:0] Instr,
output [6:0] Op,
output [2:0] Funct3,
output [6:0] Funct7,
output [31:0] rs1,
output [31:0] rs2,
output [31:0] Debug_out,
output [31:0] PC
);

wire [31:0] PCNext,PCTarget,ImmExt,SrcA,SrcB,RD2_out,ALUResult,ReadData,Result,PCPlus4,shift_out,shift_mux_out,reg_file_mux_out;

assign rs1 = SrcA;
assign rs2 = SrcB;
assign Funct7 = Instr[31:25];
assign Funct3 = Instr[14:12];
assign Op = Instr[6:0];

	 
Mux_4to1 #(32)mux_to_PCNext(
.select(PCSrc),
.input_0(PCPlus4),
.input_1(PCTarget),
.input_2(Result),
.input_3(0),
.output_value(PCNext)
 );
	 
Register_reset #(32)	PCNext_to_PC
    (
	.clk(Clock),
	.reset(Reset),
	.DATA(PCNext),
	.OUT(PC)
    );

Instruction_memory #(4,32) Instruction_mem
	(
	.ADDR(PC),
	.RD(Instr)
	);
Adder #(32) Adder4PCP4
    (
	.DATA_A(PC),
	.DATA_B(32'd4),
	.OUT(PCPlus4)
    );

Register_file_riscv #(32) Regfile
    (
	  .clk(Clock), 
	  .write_enable(RegWrite), 
	  .reset(Reset),
	  .Source_select_0(Instr[19:15]), 
	  .Source_select_1(Instr[24:20]), 
	  .Debug_Source_select(Debug_in), 
	  .Destination_select(Instr[11:7]),
	  .DATA(reg_file_mux_out),
	  .out_0(SrcA), 
	  .out_1(RD2_out), 
	  .Debug_out(Debug_out)
    );
Mux_4to1 #(32)reg_file_mux(
.select(reg_file_sel),
.input_0(Result),
.input_1(PCPlus4),
.input_2(PCTarget),
.input_3(set_out),
.output_value(reg_file_mux_out)
 );

Extender_riscv Extender(								
    .Extended_data(ImmExt),
    .DATA(Instr[31:7]),
    .select(ImmSrc)
);

Adder #(32) toPCTarget
    (
	.DATA_A(PC),
	.DATA_B(ImmExt),
	.OUT(PCTarget)
    );


Mux_2to1 #(32)	mux_srcb
    (
	.select(ALUSrc),
	.input_0(RD2_out), 
	.input_1(ImmExt),
	.output_value(SrcB)
    );
ALU #(32)	alu
    (
	  .control(ALUControl),
	  .DATA_A(SrcA),
	  .DATA_B(shift_mux_out),
     .OUT(ALUResult),
	  .Z(Zero)
    );


	
risc_memory#(4,32)DataMemory(
    .hw(byte_ldr), 
    .clk(Clock),
	 .WE(MemWrite),
    .ADDR(ALUResult),
    .WD(RD2_out),
    .RD(ReadData) 
	);

Mux_2to1 #(32)	mux_result
    (
	.select(ResultSrc),
	.input_0(ALUResult), 
	.input_1(ReadData),
	.output_value(Result)
    );
	 
	 
shifter #(32) shftr (
.control(shft_ctrl),
.shamt(SrcB[4:0]),
.DATA(SrcA),
.OUT(shift_out)
  );

  Mux_2to1 #(32)	shift_mux (
.select(shift_mux_sel),
.input_0(SrcB), 
.input_1(shift_out),
.output_value(shift_mux_out)
  );

endmodule
