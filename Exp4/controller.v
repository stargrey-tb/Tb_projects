


module controller(
input clock,
input rst,
input [31:0] instruction,
input wire Flags,								// Zero Flag
input wire FlushE,

output wire [1:0] RegSrcD,
output wire BranchTakenE,
output wire [3:0] ALUControlE,
output wire ALUSrcE,
output wire [1:0] ImmSrcD,
output wire MemWriteM,
output wire PCSrcW,
output wire RegWriteW,
output wire MemtoRegW,
output wire [1:0] shift_ctlE,
output wire [4:0] shmtE,

output wire [1:0] bl_mux_ctrlE,
output reg bx_mux,
output wire RegWriteM,
output wire MemtoRegE,
output wire PCSrcD,
output wire PCSrcE,
output wire PCSrcM


);


wire [3:0] cond;						
wire [1:0] op;
wire [5:0] funct;
wire [3:0] Rd;
reg [1:0] bl_mux_ctrl;
reg Branch;
reg MemtoReg;
reg MemW;
reg ALUSrc;
reg [1:0] ImmSrc;
reg RegW;
reg [1:0] RegSrc;
reg ALUOp;
reg FlagW;
reg PCS;
reg [3:0] ALUControl;
reg [1:0] shift_ctl;
reg [4:0] shmt;
reg RegW_Inst;

wire BranchD;
wire RegWriteD;
wire MemWriteD;
wire MemtoRegD;
wire [3:0] ALUControlD;
wire ALUSrcD;
wire FlagWriteD;
wire RegW_InstD;

wire [1:0] bl_mux_ctrlD;										
reg CondEx;
reg dummy;
reg start;

wire BranchE;
wire RegWriteE;
wire MemWriteE;



wire FlagWriteE;
wire [3:0] condE;
wire FlagsE;

wire PCSrcG;
wire RegWriteG;
wire MemWriteG;
wire FlagWriteG;
wire RegWriteW_prime;
wire [1:0] shift_ctlD;
wire [4:0] shmtD;


wire MemtoRegM;
wire [1:0] bl_mux_ctrlM;

assign PCSrcD=PCS;
assign BranchD=Branch;
assign RegWriteD=RegW;
assign MemWriteD=MemW;



assign ALUControlD=ALUControl;
assign ALUSrcD=ALUSrc;
assign FlagWriteD=FlagW;
assign ImmSrcD=ImmSrc;
assign RegSrcD=RegSrc;
assign bl_mux_ctrlD=bl_mux_ctrl;

assign shift_ctlD=shift_ctl;
assign shmtD=shmt;
assign RegW_InstD=RegW_Inst;

assign cond=instruction[31:28];
assign op=instruction[27:26];
assign funct=instruction[25:20];
assign Rd=instruction[15:12];

and(MemtoRegD,~op[1],op[0],funct[0]);

and(PCSrcG,PCSrcE,CondEx);
and(BranchTakenE,BranchE,CondEx);
and(RegWriteG,RegWriteE,CondEx);
and(MemWriteG,MemWriteE,CondEx);
and(FlagWriteG,FlagWriteE,CondEx);
or(RegWriteW,RegW_InstD,RegWriteW_prime);


always@(negedge clock) begin
	if(start==1) begin
		ImmSrc=op;
		RegSrc[0]=op[1] && ~op[0] ;
		RegSrc[1]=(op==2'b01) && (funct[0]==0);
		if(funct[4:1]==4'b1001) begin
			bx_mux=1;
		end
		else begin
			bx_mux=0;
		end
			
	end



end






always @(posedge clock) begin
	
	if(dummy==1)
		start=1;
	
	
	if(op==2'b00) begin							// Data processing
		bl_mux_ctrl=2'b00;
		
		if(funct[5]==0) begin					
			Branch=0;
			MemtoReg=0;
			MemW=0;
			ALUSrc=0;
			RegW=1;
			
			ALUOp=1;
			shift_ctl=instruction[6:5];
			shmt=instruction[11:7];
			dummy=1;
			
			
			if(funct[4:1]==4'b1010) begin
				RegW=0;
			end
			if(funct[4:1]==4'b1001) begin
				shmt=5'd0;
				
			end
			
		end
		
		else begin														// Immediate
			Branch=0;
			MemtoReg=0;
			MemW=0;
			ALUSrc=1;
		
			RegW=1;
		
			ALUOp=1;
			shift_ctl=2'b11;
			shmt=instruction[11:8]<<1;		
		end
	
	end
	
	else if(op==2'b01) begin
		bl_mux_ctrl=2'b00;
		shift_ctl=2'b00;
		shmt=5'd0;
		if(funct[0]==0) begin	// STR
			Branch=0;
			MemW=1;
			ALUSrc=1;
			
			RegW=0;
		
			ALUOp=0;
		
		end
		
		else begin					// LOAD
			
			Branch=0;
			MemtoReg=1;
			MemW=0;
			ALUSrc=1;
	
			RegW=1;
			
			ALUOp=0;
			
		end

	end
	
	else if(op==2'b10) begin
		shift_ctl=2'b00;
		shmt=5'd0;
		if(funct[4]==0) begin				// Branch
			Branch=1;
			MemtoReg=0;
			MemW=0;
			ALUSrc=1;
		
			RegW=0;
		
			ALUOp=0;
			bl_mux_ctrl=2'b00;
		end
		
		else begin								// BL
			Branch=1;
			MemtoReg=0;
			MemW=0;
			ALUSrc=1;
		
			RegW_Inst=1;
		
			ALUOp=0;
			bl_mux_ctrl=2'b11;
		
		end

	end
		
		////////////////////////////////////////////// Start of ALU DECODER
		
		
		if(ALUOp==1) begin
		
			if(funct[0]==0) begin
				FlagW=0;
			end
			
			else begin
				FlagW=1;
			end
			
			ALUControl=funct[4:1];
			
			if(funct[4:1]==4'b1010) begin
				ALUControl=4'b0010;
			end
			if(funct[4:1]==4'b1001) begin
				ALUControl=4'b1101;
			end
			
		end
	
		else begin
			ALUControl=4'b0100;
			FlagW=0;
		end
		
		////////////////////////////////////////////// Start of PC LOGIC
		
		PCS= ((Rd==4'd15)&&RegW);


		
		////////////////////////////////////////////// Start of CONDITION CHECK
		
		
		if((FlagsE==1 && condE==4'b0000)|| (FlagsE==0 && condE==4'b0001) || condE==4'b1110) begin
				CondEx=1;
		end
		
		else begin
				CondEx=0;
		end

end


Register_rsten#(1)  execute_reg1(
.clk(clock),
.reset(FlushE),
.we(1'b1),
.DATA(PCSrcD),
.OUT(PCSrcE)
);

Register_rsten#(1)  execute_reg2(
.clk(~clock),
.reset(rst),
.we(1'b1),
.DATA(BranchD),
.OUT(BranchE)
);

Register_rsten#(1)  execute_reg3(
.clk(~clock),
.reset(rst),
.we(1'b1),
.DATA(RegWriteD),
.OUT(RegWriteE)
);

Register_rsten#(1)  execute_reg4(
.clk(clock),
.reset(FlushE),
.we(1'b1),
.DATA(MemWriteD),
.OUT(MemWriteE)
);

Register_rsten#(1)  execute_reg5(
.clk(clock),
.reset(FlushE),
.we(1'b1),
.DATA(MemtoRegD),
.OUT(MemtoRegE)
);

Register_rsten#(4)  execute_reg6(
.clk(~clock),
.reset(rst),
.we(1'b1),
.DATA(ALUControlD),
.OUT(ALUControlE)
);

Register_rsten#(1)  execute_reg7(
.clk(~clock),											
.reset(rst),
.we(1'b1),
.DATA(ALUSrcD),
.OUT(ALUSrcE)
);

Register_rsten#(1)  execute_reg8(
.clk(~clock),
.reset(FlushE),
.we(1'b1),
.DATA(FlagWriteD),
.OUT(FlagWriteE)
);


Register_rsten#(4)  execute_reg9(
.clk(~clock),													
.reset(FlushE),
.we(1'b1),
.DATA(cond),
.OUT(condE)
);

Register_rsten#(1)  execute_reg10(
.clk(~clock),
.reset(FlushE),
.we(FlagWriteG),													// FLAG Write
.DATA(Flags),
.OUT(FlagsE)
);

Register_rsten#(2)  execute_reg11(	
.clk(~clock),
.reset(rst),
.we(1'b1),													
.DATA(shift_ctlD),												// shift control
.OUT(shift_ctlE)
);

Register_rsten#(5)  execute_reg12(
.clk(~clock),
.reset(rst),
.we(1'b1),														
.DATA(shmtD),														// shamt control
.OUT(shmtE)
);

Register_rsten#(2)  execute_reg13(
.clk(clock),
.reset(FlushE),
.we(1'b1),
.DATA(bl_mux_ctrlD),
.OUT(bl_mux_ctrlE)
);

Register_rsten#(1)  memory_reg1(
.clk(clock),
.reset(rst),
.we(1'b1),
.DATA(PCSrcG),
.OUT(PCSrcM)
);

Register_rsten#(1)  memory_reg2(
.clk(clock),
.reset(rst),
.we(1'b1),
.DATA(RegWriteG),
.OUT(RegWriteM)
);

Register_rsten#(1)  memory_reg3(
.clk(clock),
.reset(rst),
.we(1'b1),
.DATA(MemWriteG),
.OUT(MemWriteM)
);

Register_rsten#(1)  memory_reg4(
.clk(clock),
.reset(rst),
.we(1'b1),
.DATA(MemtoRegE),
.OUT(MemtoRegM)
);



Register_rsten#(1)  write_back_reg1(
.clk(clock),
.reset(rst),
.we(1'b1),
.DATA(PCSrcM),
.OUT(PCSrcW)
);

Register_rsten#(1)  write_back_reg2(
.clk(clock),
.reset(rst),
.we(1'b1),
.DATA(RegWriteM),
.OUT(RegWriteW_prime)
);

Register_rsten#(1)  write_back_reg3(
.clk(clock),
.reset(rst),
.we(1'b1),
.DATA(MemtoRegM),
.OUT(MemtoRegW)
);





endmodule


