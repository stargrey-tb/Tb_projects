

module top_level(

input clk,
input reset,
input [3:0] debug_inp,
output [31:0] debug_out,
output [31:0] fetchPC

);


wire PCSrcW;
wire BranchTakenE;
wire StallF;
wire StallD;
wire FlushD;
wire [1:0] RegSrcD;
wire bx_mux_sel;
wire [1:0] bl_mux_sel;
wire RegWriteW;
wire [1:0] ImmSrcD;
wire FlushE;
wire [1:0] ForwardAE;
wire [1:0] ForwardBE;
wire ALUSrcE;
wire [3:0] ALUControlE;
wire MemWriteM;
wire MemtoRegW;
wire [1:0] shft_ctrl;
wire [4:0] shamt;

wire zero_flag;
wire [3:0] WA3E;
wire [3:0] WA3M;
wire [3:0] WA3W;
wire [3:0] RA1D;
wire [3:0] RA2D;
wire [3:0] RA1E;
wire [3:0] RA2E;


wire [31:0] instr;
wire RegWriteM;
wire MemtoRegE;
wire PCSrcD;
wire PCSrcE;
wire PCSrcM;




datapath my_datapath(
.clock(clk),
.rst(reset),
.PCSrcW(PCSrcW),
.BranchTakenE(BranchTakenE),
.StallF(StallF),
.StallD(StallD),
.FlushD(FlushD),
.RegSrcD(RegSrcD),
.bx_mux_sel(bx_mux_sel),
.bl_mux_sel(bl_mux_sel),
.debug_inp(debug_inp),
.RegWriteW(RegWriteW),
.ImmSrcD(ImmSrcD),
.FlushE(FlushE),
.ForwardAE(ForwardAE),
.ForwardBE(ForwardBE),
.ALUSrcE(ALUSrcE),
.ALUControlE(ALUControlE),
.MemWriteM(MemWriteM),
.MemtoRegW(MemtoRegW),
.shft_ctrl(shft_ctrl),
.shamt(shamt),

.zero_flag(zero_flag),
.debug_out(debug_out),
.WA3E(WA3E),
.WA3M(WA3M),
.WA3W(WA3W),
.RA1D(RA1D),
.RA2D(RA2D),
.RA1E(RA1E),
.RA2E(RA2E),
.InstructionD(instr),
.PCF(fetchPC)
);



controller my_controller(
.clock(clk),
.rst(reset),
.instruction(instr),
.Flags(zero_flag),								// Zero_Flag
.FlushE(FlushE),

.RegSrcD(RegSrcD),
.BranchTakenE(BranchTakenE),
.ALUControlE(ALUControlE),
.ALUSrcE(ALUSrcE),
.ImmSrcD(ImmSrcD),
.MemWriteM(MemWriteM),
.PCSrcW(PCSrcW),
.RegWriteW(RegWriteW),
.MemtoRegW(MemtoRegW),
.shift_ctlE(shft_ctrl),
.shmtE(shamt),

.bl_mux_ctrlE(bl_mux_sel),
.bx_mux(bx_mux_sel),
.RegWriteM(RegWriteM),
.MemtoRegE(MemtoRegE),
.PCSrcD(PCSrcD),
.PCSrcE(PCSrcE),
.PCSrcM(PCSrcM)

);


hazard hzrd_unit(
.RA1E(RA1E),
.WA3M(WA3M),
.WA3W(WA3W),
.RegWriteM(RegWriteM),
.RegWriteW(RegWriteW),
.MemtoRegE(MemtoRegE),

.RA2E(RA2E),
.RA1D(RA1D),
.WA3E(WA3E),
.RA2D(RA2D),

.PCSrcD(PCSrcD),
.PCSrcW(PCSrcW),

.BranchTakenE(BranchTakenE),


.ForwardAE(ForwardAE),
.ForwardBE(ForwardBE),
.StallF(StallF),
.StallD(StallD),
.FlushD(FlushD),
.FlushE(FlushE)

);








endmodule

