

module top_level (
input clk,
input reset,
input [3:0] debug_inp,
output [31:0] debug_outp,
output [31:0] PC
);

wire [31:0] instr;
wire zero;
wire pcsrc;
wire [1:0] regsrc;
wire alusrc;
wire [3:0] alucontrol;
wire [4:0] shmt;
wire [1:0] shift;
wire [1:0] extend;
wire memtoreg;
wire regwrite;
wire memwrite;
wire [1:0] mine_mux;
wire mux_bx;


controller ctrl1(						// assign controller signals to the datapath
.instruction(instr),
.clock(clk),
.Z(zero),
.PCSrc(pcsrc),																																							
.RegSrc(regsrc),
.ALUSrc(alusrc),	
.ALUControl(alucontrol),
.shamt(shmt),
.shift_ctrl(shift),
.ImmSrc(extend),
.MemtoReg(memtoreg),
.RegWrite(regwrite),
.MemWrite(memwrite),
.my_mux(mine_mux),
.bx(mux_bx)
);



datapath  dpt1(					// assign instruction and zeo flag to the controller
.PCSrc(pcsrc),
.RegSrc(regsrc),
.RegWrite(regwrite),
.ImmSrc(extend),
.ALUSrc(alusrc),
.shft_ctrl(shift),
.shamt_ctrl(shmt),
.carry_in(1'b0),
.ALUControl(alucontrol),
.mux_mine(mine_mux),
.bx_mux(mux_bx),
.MemWrite(memwrite),
.MemtoReg(memtoreg),
.clock(clk),
.rst(reset),
.debug_in(debug_inp),
.debug_out(debug_outp),
.Z(zero),
.inst(instr),
.PC(PC)

);




endmodule
