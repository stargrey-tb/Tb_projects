

module controller (
input [1:0] comparison,
input [6:0] opcode,
input [2:0] funct3,
input [6:0] funct7,
output reg [1:0] PCSrc,
output reg ResultSrc,
output reg MemWrite,
output reg [3:0] ALUControl,
output reg ALUSrc,
output reg [3:0] ImmSrc,		
output reg RegWrite,
output reg shift_mux_sel,
output reg [1:0] shft_ctrl,
output reg [1:0] reg_mux_sel,
output reg [31:0] set_out,
output reg [1:0] byte_ldr
);




always @(*) begin											

	case (opcode)
		
		7'b0110011: begin				// R Type
		
			if(funct3==3'b000 && funct7==7'b0000000) begin 	// ADD
				PCSrc=2'b00;
				ResultSrc=0;
				MemWrite=0;
				ALUControl=4'b0100;
				ALUSrc=0;
				ImmSrc=4'b0000;
				RegWrite=1;
				shift_mux_sel=0;
				shft_ctrl=2'b00;
				reg_mux_sel=2'b00;
				set_out=32'd0;
				byte_ldr = 2'b11;
			end
			
			else if ( funct3==3'b000 && funct7==7'b0100000) begin		// SUB
				PCSrc=2'b00;
				ResultSrc=0;
				MemWrite=0;
				ALUControl=4'b0010;
				ALUSrc=0;
				ImmSrc=4'b0000;
				RegWrite=1;
				shift_mux_sel=0;
				shft_ctrl=2'b00;
				reg_mux_sel=2'b00;
				set_out=32'd0;
				byte_ldr = 2'b11;
			
			end
			
			else if ( funct3==3'b111 && funct7==7'b0000000) begin		// Bitwise AND
				PCSrc=2'b00;
				ResultSrc=0;
				MemWrite=0;
				ALUControl=4'b0000;
				ALUSrc=0;
				ImmSrc=4'b0000;
				RegWrite=1;
				shift_mux_sel=0;
				shft_ctrl=2'b00;
				reg_mux_sel=2'b00;
				set_out=32'd0;
				byte_ldr = 2'b11;
			
			end
			
			else if ( funct3==3'b110 && funct7==7'b0000000) begin		// Bitwise OR
				PCSrc=2'b00;
				ResultSrc=0;
				MemWrite=0;
				ALUControl=4'b1100;
				ALUSrc=0;
				ImmSrc=4'b0000;
				RegWrite=1;
				shift_mux_sel=0;
				shft_ctrl=2'b00;
				reg_mux_sel=2'b00;
				set_out=32'd0;
				byte_ldr = 2'b11;
			
			end
			
			else if ( funct3==3'b100 && funct7==7'b0000000) begin		// Bitwise XOR
				PCSrc=2'b00;
				ResultSrc=0;
				MemWrite=0;
				ALUControl=4'b0001;
				ALUSrc=0;
				ImmSrc=4'b0000;
				RegWrite=1;
				shift_mux_sel=0;
				shft_ctrl=2'b00;
				reg_mux_sel=2'b00;
				set_out=32'd0;
				byte_ldr = 2'b11;
			end
			
			else if ( funct3==3'b001 && funct7==7'b0000000) begin		// Shift Left Logical
				PCSrc=2'b00;
				ResultSrc=0;
				MemWrite=0;
				ALUControl=4'b1101;
				ALUSrc=0;
				ImmSrc=4'b0000;				
				RegWrite=1;
				shift_mux_sel=1;
				shft_ctrl=2'b00;
				reg_mux_sel=2'b00;
				set_out=32'd0;
				byte_ldr = 2'b11;
			end
			
			else if ( funct3==3'b101 && funct7==7'b0000000) begin		// Shift Right Logical
				PCSrc=2'b00;
				ResultSrc=0;
				MemWrite=0;
				ALUControl=4'b1101;
				ALUSrc=0;
				ImmSrc=4'b0000;				
				RegWrite=1;
				shift_mux_sel=1;
				shft_ctrl=2'b01;
				reg_mux_sel=2'b00;
				set_out=32'd0;
				byte_ldr = 2'b11;
			end
			
			else if ( funct3==3'b101 && funct7==7'b0100000) begin		// Shift Right Arithmetic
				PCSrc=2'b00;
				ResultSrc=0;
				MemWrite=0;
				ALUControl=4'b1101;
				ALUSrc=0;
				ImmSrc=4'b0000;				
				RegWrite=1;
				shift_mux_sel=1;
				shft_ctrl=2'b10;
				reg_mux_sel=2'b00;
				set_out=32'd0;
				byte_ldr = 2'b11;
			end
	
			
			else if ( funct3==3'b011 && funct7==7'b0100000) begin		// Set Less Than (unsigned)
				PCSrc=2'b00;
				ResultSrc=0;
				MemWrite=0;
				ALUControl=4'b1101;
				ALUSrc=0;	
				RegWrite=1;
				shift_mux_sel=0;
				shft_ctrl=2'b00;
				reg_mux_sel=2'b11;
				ImmSrc=4'b0000;
				byte_ldr = 2'b11;
				
				if(comparison[0]==0) begin
					set_out=32'd1;
				end
				else begin
					set_out=32'd0;										
			   end
			
			
			end
			
			else begin
			
				PCSrc=2'b00;
				ResultSrc=0;
				MemWrite=0;
				ALUControl=4'b0100;
				ALUSrc=0;
				ImmSrc=4'b0000;				
				RegWrite=0;
				shift_mux_sel=0;
				shft_ctrl=2'b00;
				reg_mux_sel=2'b00;
				set_out=32'd0;
				byte_ldr = 2'b11;
				
			end
		
		
		
		end
		
		
		7'b0010011: begin				// I Type
		
			if(funct3==3'b000) begin 	// ADD Immediate
				PCSrc=2'b00;
				ResultSrc=0;
				MemWrite=0;
				ALUControl=4'b0100;
				ALUSrc=1;
				ImmSrc=4'b0000;
				RegWrite=1;
				shift_mux_sel=0;
				shft_ctrl=2'b00;
				reg_mux_sel=2'b00;
				set_out=32'd0;
				byte_ldr = 2'b11;
				
			end
			
			else if ( funct3==3'b111 ) begin		// Bitwise AND Immediate
				PCSrc=2'b00;
				ResultSrc=0;
				MemWrite=0;
				ALUControl=4'b0000;
				ALUSrc=1;
				ImmSrc=4'b0000;
				RegWrite=1;
				shift_mux_sel=0;
				shft_ctrl=2'b00;
				reg_mux_sel=2'b00;
				set_out=32'd0;
				byte_ldr = 2'b11;
			end
			
			else if ( funct3==3'b110) begin		// Bitwise OR Immediate
				PCSrc=2'b00;
				ResultSrc=0;
				MemWrite=0;
				ALUControl=4'b1100;
				ALUSrc=1;
				ImmSrc=4'b0000;
				RegWrite=1;
				shift_mux_sel=0;
				shft_ctrl=2'b00;
				reg_mux_sel=2'b00;
				set_out=32'd0;
				byte_ldr = 2'b11;
			
			end
			
			else if ( funct3==3'b100) begin		// Bitwise XOR Immediate
				PCSrc=2'b00;
				ResultSrc=0;
				MemWrite=0;
				ALUControl=4'b0001;
				ALUSrc=1;
				ImmSrc=4'b0000;
				RegWrite=1;
				shift_mux_sel=0;
				shft_ctrl=2'b00;
				reg_mux_sel=2'b00;
				set_out=32'd0;
				byte_ldr = 2'b11;
				
			end
			
			else if ( funct3==3'b001 && funct7==7'b0000000) begin		// Shift Left Logical Immediate
				PCSrc=2'b00;
				ResultSrc=0;
				MemWrite=0;
				ALUControl=4'b1101;
				ALUSrc=1;
				ImmSrc=4'b0001;				
				RegWrite=1;
				shift_mux_sel=1;
				shft_ctrl=2'b00;
				reg_mux_sel=2'b00;
				set_out=32'd0;
				byte_ldr = 2'b11;
				
			end
			
			else if ( funct3==3'b101 && funct7==7'b0000000) begin		// Shift Right Logical Immediate
				PCSrc=2'b00;
				ResultSrc=0;
				MemWrite=0;
				ALUControl=4'b1101;
				ALUSrc=1;
				ImmSrc=4'b0001;				
				RegWrite=1;
				shift_mux_sel=1;
				shft_ctrl=2'b01;
				reg_mux_sel=2'b00;
				set_out=32'd0;
				byte_ldr = 2'b11;
				
			end
			
			else if ( funct3==3'b101 && funct7==7'b0100000) begin		// Shift Right Arithmetic Immediate
				PCSrc=2'b00;
				ResultSrc=0;
				MemWrite=0;
				ALUControl=4'b1101;
				ALUSrc=1;
				ImmSrc=4'b0010;					
				RegWrite=1;
				shift_mux_sel=1;
				shft_ctrl=2'b10;
				reg_mux_sel=2'b00;
				set_out=32'd0;
				byte_ldr = 2'b11;
				
			end
			
			
			else if ( funct3==3'b011) begin		// Set Less Than Immediate(unsigned)
				PCSrc=2'b00;
				ResultSrc=0;
				MemWrite=0;
				ALUControl=4'b1101;
				ALUSrc=1;				
				RegWrite=1;
				shift_mux_sel=0;
				shft_ctrl=2'b00;
				reg_mux_sel=2'b11;
				ImmSrc=4'b0011;
				byte_ldr = 2'b11;
				
				if(comparison[0]==0) begin
					set_out=32'd1;
				end
				else begin
					set_out=32'd0;
				end
			end
			
			else begin
			
				PCSrc=2'b00;
				ResultSrc=0;
				MemWrite=0;
				ALUControl=4'b0100;
				ALUSrc=1;
				ImmSrc=4'b0000;				
				RegWrite=0;
				shift_mux_sel=0;
				shft_ctrl=2'b00;
				reg_mux_sel=2'b00;
				set_out=32'd0;
				byte_ldr = 2'b11;

			end

			
		end
		
		
		7'b0000011: begin				// Load and Jump
																				//  Byte, Half Word , Word Unutma **********************************
			if ( funct3==3'b100) begin			// LBU (Load Byte Unsigned)
				PCSrc=2'b00;
				ResultSrc=1;
				MemWrite=0;
				ALUControl=4'b0100;
				ALUSrc=1;
				ImmSrc=4'b0011;	
				RegWrite=1;
				shift_mux_sel=0;
				shft_ctrl=2'b00;
				reg_mux_sel=2'b00;
				set_out=32'd0;
				byte_ldr = 2'b00;
				// byte remainder
			end
			
			else if ( funct3==3'b101) begin			// LHU (Load Half Word Unsigned)
				PCSrc=2'b00;
				ResultSrc=1;
				MemWrite=0;
				ALUControl=4'b0100;
				ALUSrc=1;
				ImmSrc=4'b0011;	
				RegWrite=1;
				shift_mux_sel=0;
				shft_ctrl=2'b00;
				reg_mux_sel=2'b00;
				set_out=32'd0;
				byte_ldr = 2'b01;
				// half word remainder 
			end
			
			else if ( funct3==3'b010) begin			// LW (Load Word)
				PCSrc=2'b00;
				ResultSrc=1;
				MemWrite=0;
				ALUControl=4'b0100;
				ALUSrc=1;
				ImmSrc=4'b0011;	
				RegWrite=1;
				shift_mux_sel=0;
				shft_ctrl=2'b00;
				reg_mux_sel=2'b00;
				set_out=32'd0;
				byte_ldr = 2'b11;
				// word remainder 
			end
			
			else begin
				PCSrc=2'b00;
				ResultSrc=0;
				MemWrite=0;
				ALUControl=4'b0100;
				ALUSrc=1;
				ImmSrc=4'b0000;				
				RegWrite=0;
				shift_mux_sel=0;
				shft_ctrl=2'b00;
				reg_mux_sel=2'b00;
				set_out=32'd0;
				byte_ldr = 2'b11;
				
			end
	
		end
		
		
		7'b0100011: begin				// S Type
			if ( funct3==3'b000) begin			// SB (Store Byte)
				PCSrc=2'b00;
				ResultSrc=0;
				MemWrite=1;
				ALUControl=4'b0100;
				ALUSrc=1;
				ImmSrc=4'b0100;	
				RegWrite=0;
				shift_mux_sel=0;
				shft_ctrl=2'b00;
				reg_mux_sel=2'b00;
				set_out=32'd0;
				byte_ldr = 2'b00;
				// byte remainder
			end
			
			else if ( funct3==3'b001) begin			// SH (Store Half Word)
				PCSrc=2'b00;
				ResultSrc=0;
				MemWrite=1;
				ALUControl=4'b0100;
				ALUSrc=1;
				ImmSrc=4'b0100;	
				RegWrite=0;
				shift_mux_sel=0;
				shft_ctrl=2'b00;
				reg_mux_sel=2'b00;
				set_out=32'd0;
				byte_ldr = 2'b01;
				// half word remainder 
			end
			
			else if ( funct3==3'b010) begin			// SW (Store Word)
				PCSrc=2'b00;
				ResultSrc=0;
				MemWrite=1;
				ALUControl=4'b0100;
				ALUSrc=1;
				ImmSrc=4'b0100;	
				RegWrite=0;
				shift_mux_sel=0;
				shft_ctrl=2'b00;
				reg_mux_sel=2'b00;
				set_out=32'd0;
				byte_ldr = 2'b11;
				// word remainder 
			end
			
			else begin
				PCSrc=2'b00;
				ResultSrc=0;
				MemWrite=0;
				ALUControl=4'b0100;
				ALUSrc=1;
				ImmSrc=4'b0000;				
				RegWrite=0;
				shift_mux_sel=0;
				shft_ctrl=2'b00;
				reg_mux_sel=2'b00;
				set_out=32'd0;
				byte_ldr = 2'b11;
			
			end

		
		end

		
		7'b1100011: begin				// B Type
			if ( funct3==3'b000 && comparison[1]==1) begin		// BEQ (Branch if equal)
				PCSrc=2'b01;
				ResultSrc=0;
				MemWrite=0;
				ALUControl=4'b0100;
				ALUSrc=1;
				ImmSrc=4'b0101;				
				RegWrite=0;
				shift_mux_sel=0;
				shft_ctrl=2'b00;
				reg_mux_sel=2'b00;
				set_out=32'd0;
				byte_ldr = 2'b11;
			end
			
			else if ( funct3==3'b001 && comparison[1]==0) begin	// BNE (Branch if not equal)
				PCSrc=2'b01;
				ResultSrc=0;
				MemWrite=0;
				ALUControl=4'b0100;
				ALUSrc=1;
				ImmSrc=4'b0101;				
				RegWrite=0;
				shift_mux_sel=0;
				shft_ctrl=2'b00;
				reg_mux_sel=2'b00;
				set_out=32'd0;
				byte_ldr = 2'b11;
				
			end
			
			else if ( funct3==3'b111 && comparison[0]==1) begin	// BGE (Branch if greater or equal)
				PCSrc=2'b01;
				ResultSrc=0;
				MemWrite=0;
				ALUControl=4'b0100;
				ALUSrc=1;
				ImmSrc=4'b1101;				
				RegWrite=0;
				shift_mux_sel=0;
				shft_ctrl=2'b00;
				reg_mux_sel=2'b00;
				set_out=32'd0;
				byte_ldr = 2'b11;
			
			end
			
			else if ( funct3==3'b110 && comparison[0]==0) begin	// BLT (Branch if less than)
				PCSrc=2'b01;
				ResultSrc=0;
				MemWrite=0;
				ALUControl=4'b0100;
				ALUSrc=1;
				ImmSrc=4'b1101;				
				RegWrite=0;
				shift_mux_sel=0;
				shft_ctrl=2'b00;
				reg_mux_sel=2'b00;
				set_out=32'd0;
				byte_ldr = 2'b11;
			
			end
			
			else begin
				PCSrc=2'b00;
				ResultSrc=0;
				MemWrite=0;
				ALUControl=4'b0100;
				ALUSrc=1;
				ImmSrc=4'b0000;				
				RegWrite=0;
				shift_mux_sel=0;
				shft_ctrl=2'b00;
				reg_mux_sel=2'b00;
				set_out=32'd0;
				byte_ldr = 2'b11;
				
			end
			
		end

		
		7'b0010111: begin				// U Type ---- auipc
			PCSrc=2'b00;
			ResultSrc=0;
			MemWrite=0;
			ALUControl=4'b0100;
			ALUSrc=1;
			ImmSrc=4'b0110;		
			RegWrite=1;
			shift_mux_sel=0;
			shft_ctrl=2'b00;
			reg_mux_sel=2'b10;	
			set_out=32'd0;
			byte_ldr = 2'b11;
		
		end
		
		7'b0110111: begin				// U Type ---- lui
			PCSrc=2'b00;
			ResultSrc=0;
			MemWrite=0;
			ALUControl=4'b1101;
			ALUSrc=1;
			ImmSrc=4'b0110;				
			RegWrite=1;
			shift_mux_sel=0;
			shft_ctrl=2'b00;
			reg_mux_sel=2'b00;
			set_out=32'd0;
			byte_ldr = 2'b11;

		end
		
		
		
		7'b1101111: begin				// J Type ---- JAL
				PCSrc=2'b01;		
				ResultSrc=0;
				MemWrite=0;
				ALUControl=4'b0100;
				ALUSrc=1;
				ImmSrc=4'b0111;		
				RegWrite=1;
				shift_mux_sel=0;
				shft_ctrl=2'b00;
				reg_mux_sel=2'b01;
				set_out=32'd0;
				byte_ldr = 2'b11;
				
		
		end
		
		7'b1100111: begin				// J Type ---- JALR
			if(funct3==3'b000) begin
				PCSrc=2'b10;
				ResultSrc=0;
				MemWrite=0;
				ALUControl=4'b0100;
				ALUSrc=1;
				ImmSrc=4'b0000;		
				RegWrite=1;
				shift_mux_sel=0;
				shft_ctrl=2'b00;
				reg_mux_sel=2'b01;
				set_out=32'd0;
				byte_ldr = 2'b11;
				
				
			end
			
			else begin
				PCSrc=2'b00;
				ResultSrc=0;
				MemWrite=0;
				ALUControl=4'b0100;
				ALUSrc=1;
				ImmSrc=4'b0111;				
				RegWrite=0;
				shift_mux_sel=0;
				shft_ctrl=2'b00;
				reg_mux_sel=2'b00;
				set_out=32'd0;
				byte_ldr = 2'b11;
				
			end

		
		end
		
		
		7'b0001011: begin				// XORID
			PCSrc=2'b00;
			ResultSrc=0;
			MemWrite=0;
			ALUControl=4'b0001;
			ALUSrc=1;
			ImmSrc=4'b1010;
			RegWrite=1;
			shift_mux_sel=0;
			shft_ctrl=2'b00;
			reg_mux_sel=2'b00;
			set_out=32'd0;
			byte_ldr = 2'b11;
				
		end
		
		default : begin
			PCSrc=2'b00;
			ResultSrc=0;
			MemWrite=0;
			ALUControl=4'b0100;
			ALUSrc=1;
			ImmSrc=4'b1000;				
			RegWrite=0;
			shift_mux_sel=0;
			shft_ctrl=2'b00;
			reg_mux_sel=2'b00;
			set_out=32'd0;
			byte_ldr = 2'b11;
			
			
		end
		
	endcase
		
		


end






endmodule 