
module controller(
input clk,
input [31:0] inst,
input reset,
input Z,
output reg IRWrite,
output reg AdrSrc,
output reg ALUSrcA,
output reg [1:0] ALUSrcB,
output reg [1:0] ResultSrc,
output wire [1:0] ImmSrc,
output wire [1:0] RegSrc,
output reg [3:0] ALUControl,
output reg MemWrite,
output reg RegWrite,
output reg PCWrite,
output reg [1:0] shift,
output reg [4:0] shamt,
output reg [1:0] my_mux,
output reg dump1,
output reg dump2,
output reg dump3,
output reg dump4,
output reg [1:0] dump5,
output reg dump6,
output wire [5:0] funct,
output reg [1:0] r15,
output reg reg_control,
output reg bx_mux,
output reg [3:0]fsm
);


reg NextPC;
reg MemW;
reg RegW;
reg Branch;
reg ALUOp;
reg PCS;
reg Flag;
reg FlagW;
reg CondEx;
reg CondEx_new;
reg [2:0] state;
reg finish;
reg change_flag;

wire [1:0] op;
wire [3:0] Rd;
wire[3:0] cond;

assign cond=inst[31:28];								// assign instruction to sublevels
assign op=inst[27:26];
assign funct=inst[25:20];
assign Rd=inst[15:12];

assign ImmSrc=op;											// Instr Decoder
assign RegSrc[1]=(op==2'b01);
assign RegSrc[0]=(op==2'b10);

initial begin
	state=3'b000;
	finish=1'b0;
	dump1=1'b0;
	dump2=1'b0;
	dump3=1'b0;
	dump4=1'b0;
	dump5=2'b00;
	dump6=1'b0;
	PCWrite=0;
	NextPC=0;
end



always @(negedge clk) begin

	
if(reset==0) begin
			if(state==3'b000)begin					// Fetch
				NextPC=1;
				IRWrite=1;
				AdrSrc=0;
				ALUSrcA=1;
				ALUSrcB=2'b10;
				ResultSrc=2'b10;
				ALUOp=0;	
				
				MemW=0;
				RegW=0;
				Branch=0;
				shamt=5'd0;
				shift=2'b00;
				my_mux=2'b00;
				r15=2'b01;
				reg_control=0;
				finish=0;
				bx_mux=0;
				fsm=4'd0;
			end

			
			else if(state==3'b001) begin			// Decode			
				ALUSrcB=2'b10;
				ALUSrcA=1;
				ALUOp=0;
				ResultSrc=2'b10;
				
				NextPC=0;
				IRWrite=0;
				AdrSrc=0;					
				MemW=0;
				RegW=0;
				Branch=0;
				shamt=5'd0;
				shift=2'b00;
				my_mux=2'b00;
				r15=2'b01;
				reg_control=1;
				finish=0;
				bx_mux=0;
				fsm=4'd1;
				if(op==2'b10 && funct[4]==1) begin
						my_mux=2'b11;
						RegW=1;
				end
				if(funct==6'b010010) begin
						bx_mux=1;
						
				end
	
			end
			
			else if(state==3'b010) begin			// Execute
					
					if(op==2'b00) begin				
						reg_control=0;	
					   r15=2'b00;	
							if(funct[5]==0) begin		// Data Reg
								
								ALUSrcA=0;
								ALUSrcB=2'b00;
								ALUOp=1;
								
								shamt=inst[11:7];
								shift=inst[6:5];
								
								NextPC=0;
								IRWrite=0;					
								MemW=0;
								RegW=0;
								Branch=0;
								my_mux=2'b00;
								finish=0;
								fsm=4'd6;
							end
							
					     else begin						// Data Imm
								ALUSrcA=0;
								ALUSrcB=2'b01;
								ALUOp=1;
								
								NextPC=0;
								IRWrite=0;					
								MemW=0;
								RegW=0;
								Branch=0;
								
								shamt=inst[11:8]<<1;
								shift=2'b11;
								
								my_mux=2'b00;
								finish=0;
								fsm=4'd7;
							end
					
							
					
					end
					
					
					else if(op==2'b01) begin				// Memory						
							ALUSrcA=0;
							ALUSrcB=2'b01;
							ALUOp=0;
							
							
							NextPC=0;
							IRWrite=0;					
							MemW=0;
							RegW=0;
							Branch=0;
							shamt=5'd0;
							shift=2'b00;
							finish=0;
							my_mux=2'b00;
							reg_control=0;	
							r15=2'b00;
							dump1=1;							
							fsm=4'd2;
					end
					
					
					else if(op==2'b10) begin			// Branch

							if(funct[4]==0) begin			// Branch
								ALUSrcA=0;
								ALUSrcB=2'b01;
								ALUOp=0;
								ResultSrc=2'b10;
								Branch=1;
								finish=1;
								
								NextPC=0;
								IRWrite=0;				
								MemW=0;
								RegW=0;
								shamt=5'd0;
								shift=2'b00;
								my_mux=2'b00;
								fsm=4'd9;
							end
							
							else begin					// BL		
								ALUSrcA=0;
								ALUSrcB=2'b01;
								ALUOp=0;
								ResultSrc=2'b10;
								Branch=1;
								finish=1;
								
								RegW=0;
								my_mux=2'b00;
								NextPC=0;
								IRWrite=0;					
								MemW=0;
								shamt=5'd0;
								shift=2'b00;
								fsm=4'd10;
							end
							reg_control=0;	
							r15=2'b10;
					end
				if(funct==6'b010010) begin
						ALUSrcA=0;
						ALUSrcB=2'b00;
						ResultSrc=2'b10;
						NextPC=1;
						finish=1;
						bx_mux=0;
						shamt=5'd0;
						shift=2'b00;
				end
			end

			
			
			else if(state==3'b011) begin		
						
							if(op==2'b00) begin					// ALUWB
								ResultSrc=2'b00;	
								RegW=1;
								finish=1;
								if(funct[4:1]==4'b1010) begin
									RegW=0;
								end
							   NextPC=0;
							   IRWrite=0;					
							   MemW=0;
							   Branch=0;
								my_mux=2'b00;
								fsm=4'd8;
							end
							
							else if(op==2'b01) begin			
								
									if(funct[0]==0) begin		// STR 
										ResultSrc=2'b00;
										AdrSrc=1;
										MemW=1;
										finish=1;
										
										RegW=0;
										NextPC=0;
										IRWrite=0;					
										Branch=0;
										shamt=5'd0;
										shift=2'b00;
										my_mux=2'b00;
										fsm=4'd5;
									end
									
									else begin															
										ResultSrc=2'b00;		// LDR
										AdrSrc=1;
										
										MemW=0;
										finish=0;
										RegW=0;
										NextPC=0;
										IRWrite=0;					
										Branch=0;
										shamt=5'd0;
										shift=2'b00;
										my_mux=2'b00;
										dump2=1;									
										fsm=4'd3;
									end
							
							
							end
			
			end

			
			else if(state==3'b100) begin					// MemWB		
				
					ResultSrc=2'b01;
					RegW=1;
					finish=1;
					
					MemW=0;
					NextPC=0;
					IRWrite=0;					
					Branch=0;
					shamt=5'd0;
					shift=2'b00;
					my_mux=2'b00;
					dump3=1;														
					fsm=4'd4;
			end
			
			else begin
			
					RegW=0;
					finish=1;
					MemW=0;
					NextPC=0;
					IRWrite=0;					
					Branch=0;
					shamt=5'd0;
					shift=2'b00;
					my_mux=2'b00;
					
			end
		
	PCS = ((Rd == 4'd15) && RegW) || Branch;		// PC Logic	
	PCWrite= (PCS && CondEx_new) || NextPC;		
	MemWrite= MemW && CondEx_new;
	RegWrite= RegW && CondEx_new;
						
			
		if(ALUOp==1) begin					// ALU Decoder
				if(funct[0]==1) begin
					FlagW=1;
				end
				
				else begin
					FlagW=0;
				end
				
				ALUControl=funct[4:1];									// assign ALUControl
				if(funct[4:1]==4'b1010) begin
					ALUControl=4'b0010;
				end
				if(funct==6'b010010) begin
					ALUControl=4'b1101;
				end
				
		end
		
		else begin
				ALUControl=4'b0100;
				FlagW=0;
		end
		
		
		
	if((Flag==1 && cond==4'b0000) ||(Flag==0 && cond==4'b0001) || cond==4'b1110) begin		// Condition Check
		
			CondEx=1;				// Assign condex
	end
	
	else begin
			CondEx=0;
	end
	
	if(CondEx==1)									// Renew condex at next clock cycle
		CondEx_new=1;
		
	else
		CondEx_new=0;
		

	if(change_flag==1)					// Renew flag at next clock cycle
		Flag=Z;
	
	else
		Flag=Flag;
		
	if(CondEx==1 && FlagW ==1) begin				// Flag write
		change_flag=1;
	end
	
	else
		change_flag=0;
		

 
 state=state+1'b1;						// change the state
  
 if(finish==1) begin						// finish flag
		finish=0;		
		state=3'b000;						// reset state
	end

	
end	



end


endmodule
