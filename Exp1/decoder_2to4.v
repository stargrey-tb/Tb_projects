module decoder_2to4(inp,out);
input [1:0] inp;
output reg [3:0] out;

	always@(*) begin

		case(inp)						// case selection for 2x14 decoder
		2'b00: out=4'b1<<0;
		2'b01: out=4'b1<<1;
		2'b10: out=4'b1<<2;
		2'b11: out=4'b1<<3;
		default: out=4'b0000;
		
		endcase
	


	end

endmodule
