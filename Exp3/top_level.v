

module top_level (
input clk,
input reset,
input [3:0] debug_inp,
output [31:0] debug_outp,
output [31:0] PC,
output [3:0] fsm_state
);

wire [31:0] instr;
wire zero_f;
wire ir;
wire adrsrc;
wire alusrca;
wire [1:0] alusrcb;
wire [1:0] resultsrc;
wire [1:0] immsrc;
wire [1:0] regsrc;
wire [3:0] aluctrl;
wire memwrt;
wire regwrt;
wire pcwrt;
wire reg_ctl;
wire bx_ctrl;
wire [1:0] shft;
wire [4:0] shmt;
wire [1:0] bl_mux;
wire [1:0] r15_ctrl;

controller ctl1(				
.clk(~clk),
.inst(instr),
.reset(1'b0),
.Z(zero_f),
.IRWrite(ir),
.AdrSrc(adrsrc),
.ALUSrcA(alusrca),
.ALUSrcB(alusrcb),
.ResultSrc(resultsrc),
.ImmSrc(immsrc),
.RegSrc(regsrc),
.ALUControl(aluctrl),
.MemWrite(memwrt),
.RegWrite(regwrt),
.PCWrite(pcwrt),
.shift(shft),
.shamt(shmt),
.my_mux(bl_mux),
.r15(r15_ctrl),
.reg_control(reg_ctl),
.bx_mux(bx_ctrl),
.fsm(fsm_state)
);

datapath my_datapath(
.clock(~clk),
.rst(1'b0),
.PCWrite(pcwrt),
.MemWrite(memwrt),
.IRWrite(ir),
.AdrSrc(adrsrc),
.RegSrc(regsrc),
.RegWrite(regwrt),
.debug_inp(debug_inp),
.ImmSrc(immsrc),
.ALUSrcA(alusrca),
.ALUSrcB(alusrcb),
.ALUControl(aluctrl),
.ResultSrc(resultsrc),
.bl_mux(bl_mux),
.shft_ctrl(shft),
.shamt_ctrl(shmt),
.pc15_slct(r15_ctrl),
.reg_ctrl(reg_ctl),
.bx_mux(bx_ctrl),			
.zero_flag(zero_f),
.debug_out(debug_outp),
.Instr(instr),
.pcounter(PC)
);


endmodule
