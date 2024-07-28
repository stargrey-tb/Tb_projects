

module datapath (
input PCSrc,
input [1:0] RegSrc,
input RegWrite,
input [1:0] ImmSrc,
input ALUSrc,
input [1:0] shft_ctrl,
input [4:0] shamt_ctrl,
input carry_in,
input [3:0] ALUControl,
input [1:0] mux_mine,		// mux select for BL
input bx_mux,					// mux select for BX
input MemWrite,
input MemtoReg,
input clock,
input rst,
input [3:0] debug_in,
output [31:0] debug_out,
output CO,
output OVF,
output N,
output Z,
output wire [31:0] inst,
output wire [31:0] PC
);

wire [31:0] Result;
wire [31:0] pc_in;
wire [31:0] pc_out;
wire [31:0] PCPlus4;
wire [31:0] PCPlus8;
wire [31:0] RA1;
wire [31:0] RA2;
wire [31:0] RD1;
wire [31:0] RD2;
wire [31:0] ExtImm;
wire [31:0] SrcB;
wire [31:0] ALUResult;
wire [31:0] ReadData;
wire [31:0] shifter_out;
wire [31:0] A3_wire;
wire [31:0] WD3_wire;
wire [31:0] bx_out;
assign PC=pc_out;



Mux_2to1 #(32) m1(
.select(PCSrc),
.input_0(PCPlus4),
.input_1(Result),
.output_value(pc_in)
 );
 
Register_reset #(32) pc(
.clk(clock), 
.reset(rst),
.DATA(pc_in),
.OUT(pc_out)
 );
 
Inst_Memory im(
.ADDR(pc_out),
.RD (inst)
);

Adder  a1(
.DATA_A(pc_out),
.DATA_B(32'd4),
.OUT(PCPlus4)
 );
 
 Mux_2to1 #(32) m2(
.select(RegSrc[0]),
.input_0(inst[19:16]),
.input_1(32'd15),
.output_value(RA1)
 );
 
  Mux_2to1 #(32) m3(
.select(RegSrc[1]),
.input_0(inst[3:0]),
.input_1(inst[15:12]),
.output_value(RA2)
 );
 
 Adder  a2(
.DATA_A(32'd4),
.DATA_B(PCPlus4),
.OUT(PCPlus8)
 );
 
Register_file rf(
.clk(clock), 
.write_enable(RegWrite),
.reset(rst),
.Source_select_0(RA1),
.Source_select_1(bx_out),
.Debug_Source_select(debug_in),
.Destination_select(A3_wire),
.DATA(WD3_wire),
.Reg_15(PCPlus8),
.out_0(RD1),
.out_1(RD2),
.Debug_out(debug_out)
 );
 
Extender ext(
.DATA(inst[23:0]),
.select(ImmSrc),
.Extended_data(ExtImm)
);
 
   Mux_2to1#(32) m4(
.select(ALUSrc),
.input_0(RD2),
.input_1(ExtImm),
.output_value(SrcB)
 );
 
 shifter #(32)shft(
.control(shft_ctrl),
.shamt(shamt_ctrl),
.DATA(SrcB),
.OUT(shifter_out)
 );
 
ALU #(32) alu(
.control(ALUControl),
.CI(carry_in),
.DATA_A(RD1),
.DATA_B(shifter_out),
.OUT(ALUResult),
.CO(CO),
.OVF(OVF),
.N(N),
.Z(Z)
);
 
 Memory#(32,32) mem(
.clk(clock),
.WE(MemWrite),
.ADDR(ALUResult),
.WD(RD2),
.RD(ReadData)
);
 
   Mux_2to1 #(32) m5(
.select(MemtoReg),
.input_0(ALUResult),
.input_1(ReadData),
.output_value(Result)
 );
 
 
 
  Mux_2to1 #(32) m6(						//	BL mux 1
.select(mux_mine[0]),
.input_0(inst[15:12]),
.input_1(32'd14),
.output_value(A3_wire)
 );
 
 
  Mux_2to1 #(32) m7(						//	BL mux 2
.select(mux_mine[1]),
.input_0(Result),
.input_1(PCPlus4),
.output_value(WD3_wire)
 );
 
 Mux_2to1 #(32) m8(						// BX mux 1
.select(bx_mux),
.input_0(RA2),
.input_1(32'd14),
.output_value(bx_out)
 );
 
 

 
 endmodule
 