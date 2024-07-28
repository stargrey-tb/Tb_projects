module datapath(
input clock,
input rst,
input PCWrite,
input MemWrite,
input IRWrite,
input AdrSrc,
input [1:0] RegSrc,
input RegWrite,
input [3:0] debug_inp,
input [1:0] ImmSrc,
input ALUSrcA,
input [1:0] ALUSrcB,
input [3:0] ALUControl,
input [1:0] ResultSrc,
input [1:0] bl_mux,
input [1:0] shft_ctrl,
input [4:0] shamt_ctrl,
input [1:0] pc15_slct,
input reg_ctrl,
input bx_mux,
output wire zero_flag,
output wire [31:0] debug_out,
output wire [31:0] Instr,
output wire [31:0] pcounter,
output wire [31:0] SrcA,
output wire [31:0] SrcB,
output wire [31:0] ALUResult,
output wire [31:0] Result,
output wire [31:0] ReadData,
output wire [31:0] ExtImm,
output wire [31:0] WriteData
);


wire [31:0] PC;
wire [31:0] Adr;


wire [31:0] Data;
wire [3:0] RA1;
wire [3:0] RA2;
wire [3:0] bx_mux_out;
wire [31:0] RD1;
wire [31:0] RD2;
wire [31:0] A;
wire [31:0] r15;
wire [31:0] reg_out;

wire [31:0] ALUOut;
wire [3:0] blmux1_out;
wire [31:0] blmux2_out;
wire [31:0] shift_out;
wire [31:0] adder_out;


assign pcounter=PC;



Register_rsten#(32) pc_reg(
.clk(clock),
.reset(rst),
.we(PCWrite),
.DATA(Result),
.OUT(PC)
);


Mux_2to1 #(32) m1(
.select(AdrSrc),
.input_0(PC),
.input_1(Result),
.output_value(Adr)
 );

ID_memory#(4,32) idm(
.clk(clock),
.WE(MemWrite),
.ADDR(Adr),
.WD(WriteData),
.RD(ReadData) 
);
	 
Register_rsten#(32) reg1(
.clk(clock),
.reset(1'b0),
.we(IRWrite),
.DATA(ReadData),
.OUT(Instr)
);

Register_rsten#(32) reg2(
.clk(clock),
.reset(1'b0),
.we(1'b1),
.DATA(ReadData),
.OUT(Data)
);

Mux_2to1 #(4) m2(
.select(RegSrc[0]),
.input_0(Instr[19:16]),
.input_1(4'd15),
.output_value(RA1)
 );

Mux_2to1 #(4) m3(
.select(RegSrc[1]),
.input_0(Instr[3:0]),
.input_1(Instr[15:12]),
.output_value(RA2)
 ); 
	 
Register_file #(32)  reg_file_dp(
.clk(clock),
.write_enable(RegWrite),
.reset(1'b0),
.Source_select_0(RA1),
.Source_select_1(bx_mux_out),
.Debug_Source_select(debug_inp),
.Destination_select(blmux1_out),
.DATA(blmux2_out),
.Reg_15(r15),
.out_0(RD1),
.out_1(RD2),
.Debug_out(debug_out)
);
	 
Extender ext1(
    
.DATA(Instr[23:0]),
.select(ImmSrc),
.Extended_data(ExtImm)
);

Register_simple#(32) reg3(
.clk(clock),
.DATA(RD1),
.OUT(A)
);

Register_simple#(32) reg4(
.clk(clock),
.DATA(RD2),
.OUT(WriteData)
);

Mux_2to1 #(32) m4(
.select(ALUSrcA),
.input_0(A),
.input_1(PC),
.output_value(SrcA)
 ); 
 
Mux_4to1 #(32) m5 (				
.select(ALUSrcB),
.input_0(WriteData),
.input_1(ExtImm),
.input_2(32'd4),
.input_3(32'd0),
.output_value(SrcB)
);

ALU #(32) al1 (
.control(ALUControl),
.CI(1'b0),
.DATA_A(SrcA),
.DATA_B(shift_out),
.OUT(ALUResult),
.Z(zero_flag)
);

Register_rsten#(32) reg5(
.clk(clock),
.reset(1'b0),
.we(1'b1),
.DATA(ALUResult),
.OUT(ALUOut)
);


Mux_4to1 #(32) m6 (
.select(ResultSrc),
.input_0(ALUOut),
.input_1(Data),
.input_2(ALUResult),
.input_3(32'd0),
.output_value(Result)
);


Mux_2to1 #(4) m7(									// BL mux1
.select(bl_mux[0]),
.input_0(Instr[15:12]),
.input_1(4'd14),
.output_value(blmux1_out)
 ); 
 
 Mux_2to1 #(32) m8(								// BL mux2
.select(bl_mux[1]),
.input_0(Result),
.input_1(PC),
.output_value(blmux2_out)
 ); 

shifter #(32) shftr(								// Shifter
.control(shft_ctrl),
.shamt(shamt_ctrl),
.DATA(SrcB),
.OUT(shift_out)
);

Adder #(32) addr1(
.DATA_A(Result),
.DATA_B(32'd4),
.OUT(adder_out)
);

Register_rsten #(32) reg6(		
.clk(clock),
.reset(1'b0),
.we(reg_ctrl),
.DATA(Result),
.OUT(reg_out)
);

Mux_4to1 #(32)  m9(
.select(pc15_slct),
.input_0(reg_out),
.input_1(Result),
.input_2(adder_out),
.input_3(32'd0),
.output_value(r15)
);

 Mux_2to1 #(4) m10(								// BX mux
.select(bx_mux),
.input_0(RA2),
.input_1(4'd14),
.output_value(bx_mux_out)
 ); 


	 
endmodule
