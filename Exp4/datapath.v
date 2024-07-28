
module datapath (
input clock,
input rst,
input PCSrcW,
input BranchTakenE,
input StallF,
input StallD,
input FlushD,
input [1:0] RegSrcD,
input bx_mux_sel,
input [1:0] bl_mux_sel,
input [3:0] debug_inp,
input RegWriteW,
input [1:0] ImmSrcD,
input FlushE,
input [1:0] ForwardAE,
input [1:0] ForwardBE,
input ALUSrcE,
input [3:0] ALUControlE,
input MemWriteM,
input MemtoRegW,
input [1:0] shft_ctrl,
input [4:0] shamt,


output zero_flag,
output [31:0] debug_out,
output wire [3:0] WA3E,
output wire [3:0] WA3M,
output wire [3:0] WA3W,
output wire [3:0] RA1D,
output wire [3:0] RA2D,
output wire [3:0] RA1E,
output wire [3:0] RA2E,
output wire [31:0] InstructionD,
output wire [31:0] PCF
);

wire [31:0] PCPlus4F;
wire [31:0] ResultW;
wire [31:0] PC_in;
wire [31:0] ALUResultE;
wire [31:0] PC_prime;

wire [31:0] InstructionF;



wire [3:0] bx_mux_out;
wire [3:0] bl_mux_out1;
wire [31:0] pc_plus4;
wire [31:0] RD1_out;
wire [31:0] bl_mux_out2;
wire [31:0] RD1;
wire [31:0] RD2;
wire [31:0] extender_out;
wire [31:0] RD_wire;
wire [31:0] RD2_out;



wire [31:0] ExtImmE;
wire [31:0] pc_plus4_1;
wire [31:0] ALUOutM;
wire [31:0] SrcAE;
wire [31:0] m9_out;
wire [31:0] shifter_out;
wire [31:0] SrcBE;
wire [31:0] WD_wire;
wire [31:0] ReadDataW;
wire [31:0] ALUOutW;
wire [31:0] WriteDataE;



Mux_2to1 #(32) m1(
.select(PCSrcW),
.input_0(PCPlus4F),
.input_1(ResultW),
.output_value(PC_in)
);


Mux_2to1 #(32) m2(
.select(BranchTakenE),
.input_0(PC_in),
.input_1(ALUResultE),
.output_value(PC_prime)
);

Register_rsten#(32) fetch_reg (
.clk(clock),
.reset(rst),										// reset var mı acaba?
.we(~StallF),										// StallF tersi mi alıncak?
.DATA(PC_prime),
.OUT(PCF)
);

Instruction_memory#(4,32) im(
.ADDR(PCF),
.RD(InstructionF) 
);

Adder #(32) addr (
.DATA_A(PCF),
.DATA_B(32'd4),
.OUT(PCPlus4F)
);

Register_rsten#(32) decode_reg (
.clk(clock),
.reset(FlushD),									// Problem varsa reset control et	
.we(~StallD),										// StallD tersi mi alıncak?
.DATA(InstructionF),
.OUT(InstructionD)
);

Mux_2to1 #(4) m3(
.select(RegSrcD[0]),
.input_0(InstructionD[19:16]),
.input_1(4'd15),
.output_value(RA1D)
);

Mux_2to1 #(4) m4(
.select(RegSrcD[1]),
.input_0(InstructionD[3:0]),
.input_1(InstructionD[15:12]),
.output_value(RA2D)
);

Mux_2to1 #(4) m5(					// BX MUX
.select(bx_mux_sel),
.input_0(RA2D),
.input_1(4'd14),
.output_value(bx_mux_out)
);

Mux_2to1 #(4) m6(					// BL MUX 1
.select(bl_mux_sel[0]),
.input_0(WA3W),
.input_1(4'd14),
.output_value(bl_mux_out1)
);


Mux_2to1 #(32) m7(				// BL MUX 2
.select(bl_mux_sel[1]),
.input_0(ResultW),
.input_1(pc_plus4_1),							
.output_value(bl_mux_out2)
);

Register_rsten#(32) bl_reg (
.clk(clock),
.reset(1'b0),									// BL REgister 1
.we(1'b1),										
.DATA(PCPlus4F),
.OUT(pc_plus4)
);

Register_file #(32) reg_file_dp(
.clk(~clock),
.write_enable(RegWriteW),
.reset(rst),
.Source_select_0(RA1D),
.Source_select_1(bx_mux_out),
.Debug_Source_select(debug_inp),
.Destination_select(bl_mux_out1),
.DATA(bl_mux_out2),
.Reg_15(PCPlus4F),
.out_0(RD1),
.out_1(RD2),
.Debug_out(debug_out)
);

Extender extndr(
.DATA(InstructionD[23:0]),
.select(ImmSrcD),
.Extended_data(extender_out)
);

Register_rsten#(32) execute_reg1 (
.clk(clock),
.reset(FlushE),									
.we(1'b1),										
.DATA(RD1),
.OUT(RD1_out)
);

Register_rsten#(32) execute_reg2 (
.clk(clock),
.reset(FlushE),									
.we(1'b1),										
.DATA(RD2),
.OUT(WriteDataE)
);

Register_rsten#(4) execute_reg3 (
.clk(clock),
.reset(FlushE),									
.we(1'b1),										
.DATA(InstructionD[15:12]),
.OUT(WA3E)
);


Register_rsten#(32) execute_reg4 (
.clk(clock),
.reset(FlushE),									
.we(1'b1),										
.DATA(extender_out),
.OUT(ExtImmE)
);


Register_rsten#(32) execute_reg5 (
.clk(clock),
.reset(FlushE),									
.we(1'b1),										
.DATA(pc_plus4),
.OUT(pc_plus4_1)
);

Register_rsten#(4) execute_reg6 (
.clk(clock),
.reset(FlushE),									
.we(1'b1),										
.DATA(RA1D),
.OUT(RA1E)
);

Register_rsten#(4) execute_reg7 (
.clk(clock),
.reset(FlushE),									
.we(1'b1),										
.DATA(RA2D),
.OUT(RA2E)
);



Mux_4to1 #(32) m8(
.select(ForwardAE),
.input_0(RD1_out),
.input_1(ResultW),
.input_2(ALUOutM),
.input_3(32'd0),
.output_value(SrcAE)
);

Mux_4to1 #(32) m9(
.select(ForwardBE),
.input_0(WriteDataE),
.input_1(ResultW),
.input_2(ALUOutM),
.input_3(32'd0),
.output_value(m9_out)
);

Mux_2to1 #(32) m10(				
.select(ALUSrcE),
.input_0(shifter_out),
.input_1(ExtImmE),							
.output_value(SrcBE)
);

ALU #(32) alu1 (
.control(ALUControlE),
.CI(1'b0),
.DATA_A(SrcAE),
.DATA_B(SrcBE),
.OUT(ALUResultE),
.Z(zero_flag)
);

Register_rsten#(32) memory_reg1 (
.clk(clock),
.reset(rst),									
.we(1'b1),										
.DATA(ALUResultE),
.OUT(ALUOutM)
);

Register_rsten#(32) memory_reg2 (
.clk(clock),
.reset(rst),									
.we(1'b1),										
.DATA(WriteDataE),
.OUT(WD_wire)
);

Register_rsten#(4) memory_reg3 (
.clk(clock),
.reset(rst),									
.we(1'b1),										
.DATA(WA3E),
.OUT(WA3M)
);


Memory#(4, 32) data_memory(
.clk(clock),
.WE(MemWriteM),
.ADDR(ALUOutM),
.WD(WD_wire),				
.RD(RD_wire) 
);

Register_rsten#(32) write_back_reg1 (
.clk(clock),
.reset(rst),									
.we(1'b1),										
.DATA(RD_wire),
.OUT(ReadDataW)
);

Register_rsten#(32) write_back_reg2 (
.clk(clock),
.reset(rst),									
.we(1'b1),										
.DATA(ALUOutM),
.OUT(ALUOutW)
);

Register_rsten#(4) write_back_reg3 (
.clk(clock),
.reset(rst),									
.we(1'b1),										
.DATA(WA3M),
.OUT(WA3W)
);


Mux_2to1 #(32) m11(				
.select(MemtoRegW),
.input_0(ALUOutW),
.input_1(ReadDataW),							
.output_value(ResultW)
);

shifter #(32) shftr (
.control(shft_ctrl),
.shamt(shamt),
.DATA(m9_out),
.OUT(shifter_out)
);




endmodule

