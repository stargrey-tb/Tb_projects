

module controller(
input [31:0] instruction,
input clock,
input Z,
output reg PCSrc,																																							
output reg [1:0] RegSrc,
output reg ALUSrc,	
output reg [3:0] ALUControl,
output reg [4:0] shamt,
output reg [1:0] shift_ctrl,
output reg[1:0] ImmSrc,
output reg MemtoReg,
output reg RegWrite,
output reg MemWrite,
output reg [1:0] my_mux,
output reg bx
);

reg cond_satisf;
wire [3:0] cond;
wire [1:0] op;
wire [5:0] Funct;
reg zero_flag;

assign cond=instruction[31:28];
assign op=instruction[27:26];
assign Funct=instruction[25:20];

initial begin
zero_flag=Z;
end

always @(clock) begin					
	
	if(cond==4'b0000) begin				//condition check
		if(zero_flag==1)
		cond_satisf=1;
		
		else 
		cond_satisf=0;
		
		
	
	end
	
	else if(cond==4'b0001) begin
		if(zero_flag==1)
		cond_satisf=0;
		
		else 
		cond_satisf=1;
	
	end
	
	else if(cond==4'b1110)
		cond_satisf=1;
		
	else
		cond_satisf=0;
	

	if(op==2'b00 &&(Funct[4:1]==4'b0100 || Funct[4:1]==4'b0010 || Funct[4:1]==4'b0000 || Funct[4:1]==4'b1100 || (Funct[4:1]==4'b1101 && Funct[5]==0) || (Funct[4:1]==4'b1101 && Funct[5]==1) || Funct[4:1]==4'b1010)) begin
	zero_flag=Z;	
	end						// assign zero flag for the next cycle
							
	
end



always @(*) begin
	
 if(cond_satisf==1)begin
	if(op==2'b00) begin
			
				
				
				if(Funct[4:1]==4'b0100) begin		//ADD
					ALUControl=4'b0100;
					PCSrc=0;
					RegSrc=2'b00;
					ALUSrc=0;
					MemWrite=0;
					MemtoReg=0;
					RegWrite=1;
					my_mux=2'b00;
					bx=0;
				end
				
				else if(Funct[4:1]==4'b0010) begin		//SUB
					ALUControl=4'b0010;
					PCSrc=0;
					RegSrc=2'b00;
					ALUSrc=0;
					MemWrite=0;
					MemtoReg=0;
					RegWrite=1;
					my_mux=2'b00;
					bx=0;
				end
				
				else if(Funct[4:1]==4'b0000) begin		//AND
					ALUControl=4'b0000;
					PCSrc=0;
					RegSrc=2'b00;
					ALUSrc=0;
					MemWrite=0;
					MemtoReg=0;
					RegWrite=1;
					my_mux=2'b00;
					bx=0;
				
				end
				
				
				else if(Funct[4:1]==4'b1100) begin		//ORR
					ALUControl=4'b1100;
					PCSrc=0;
					RegSrc=2'b00;
					ALUSrc=0;
					MemWrite=0;
					MemtoReg=0;
					RegWrite=1;
					my_mux=2'b00;
					bx=0;
				
				end
				
				else if(Funct[4:1]==4'b1101 && Funct[5]==0) begin		// MOV
					ALUControl=4'b1101;
					PCSrc=0;
					RegSrc=2'b00;
					ALUSrc=0;
					MemWrite=0;
					MemtoReg=0;
					RegWrite=1;
					my_mux=2'b00;
					bx=0;
				end
				
				
				else if(Funct[4:1]==4'b1101 && Funct[5]==1) begin		// MOV2
					ALUControl=4'b1101;
					PCSrc=0;
					RegSrc=2'b00;
					ALUSrc=1;
					MemWrite=0;
					MemtoReg=0;
					RegWrite=1;
					my_mux=2'b00;
					bx=0;
				
				end
				
				else if(Funct[4:1]==4'b1010) begin		// CMP
					ALUControl=4'b0010;
					PCSrc=0;
					RegSrc=2'b00;
					ALUSrc=0;
					MemWrite=0;
					MemtoReg=0;
					RegWrite=0;
					my_mux=2'b00;
					bx=0;
				end
				
				else if(Funct[4:1]==4'b1001) begin		//BX
					bx=1;
					PCSrc=1;
					RegSrc=2'b00;
					ALUSrc=0;
					ALUControl=4'b1101;
					MemtoReg=0;
					RegWrite=0;
					MemWrite=0;
					my_mux=2'b00;
					
				end

	end
	
	
	else if(op==2'b01) begin					
				bx=0;
					
			if(Funct[0]==0) begin		//STORE
				PCSrc=0;
				RegSrc=2'b10;			
				ALUSrc=1;
				ALUControl=4'b0100;
				MemWrite=1;
				RegWrite=0;
				my_mux=2'b00;
			end
			
			
			else begin					//LOAD
				PCSrc=0;
				RegSrc=2'b00;			
				ALUSrc=1;
				ALUControl=4'b0100;
				MemWrite=0;
				MemtoReg=1;
				RegWrite=1;
				my_mux=2'b00;
			end
			
	end
	
	else if(op==2'b10) begin		// Branches
	
					bx=0;
					
				if(Funct[5:4]==2'b10) begin		//B   
					ALUControl=4'b0100;
					RegSrc=2'b01;			 
					ALUSrc=1;				
					MemWrite=0;
					MemtoReg=0;
					RegWrite=0;
					my_mux=2'b00;
					PCSrc=1;
				end
			
				else if(Funct[5:4]==2'b11) begin		//BL
					ALUControl=4'b0100;
					RegSrc=2'b01;			 
					ALUSrc=1;				
					MemWrite=0;
					MemtoReg=0;
					RegWrite=1;
					PCSrc=1;
					my_mux=2'b11;
				end
	
	end
	
	
	else begin	
					bx=0;
					PCSrc=0;
					RegSrc=2'b00;
					ALUSrc=0;
					ALUControl=4'b0000;
					MemtoReg=0;
					RegWrite=0;
					MemWrite=0;
					my_mux=2'b00;
	end
	
	
																// shamt and shift control signals
	
	
	if(op==2'b00) begin									// data processing								
	
			if(instruction[25]==1) begin																				// I=1 condition
				ImmSrc=2'b00;
				shift_ctrl=2'b00;				
				shamt=instruction[11:8];
				
			end
			
			else if (instruction[25]==0 && Funct[4:1]!=4'b1010 && Funct[4:1]!=4'b1001 && instruction[4]==1 ) begin		// I=0 condition, register shifted register, exclude CMP and BX
			
			shamt=instruction[11:8];
			shift_ctrl=instruction[6:5];
			
			end
			
			else if(instruction[25]==0 && Funct[4:1]!=4'b1010 && Funct[4:1]!=4'b1001 && instruction[4]==0 ) begin			// I=0 condition,register,exclude CMP and BX
			shamt=instruction[11:7];
			shift_ctrl=instruction[6:5];
			end
			
			
			else begin
			shamt=5'b00000;
			end
			
	end
	
	
	
	else if (op==2'b01) begin					// memory

			ImmSrc=2'b01;
			shamt=5'b00000;
			shift_ctrl=2'b00;
	
	end
	
	else if (op==2'b10) begin					// branch

			ImmSrc=2'b10;
			shamt=5'b00000;
	
	end
	
	
 end	
	
	
	
	else begin
					RegWrite=0;
					MemWrite=0;
					PCSrc=0;
	
	end

	


	
end

endmodule
