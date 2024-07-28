
module decoder_4to16(inp,out,wrt_enable);
input [3:0] inp;
input wrt_enable;
output reg [15:0] out;

always@(*) begin
	if(wrt_enable==1)begin
		case(inp)										// case selection for 4x16 decoder
		  4'b0000: out = 16'b1 << 0;
        4'b0001: out = 16'b1 << 1;
        4'b0010: out = 16'b1 << 2;
        4'b0011: out = 16'b1 << 3;
        4'b0100: out = 16'b1 << 4;
        4'b0101: out = 16'b1 << 5;
        4'b0110: out = 16'b1 << 6;
        4'b0111: out = 16'b1 << 7;
        4'b1000: out = 16'b1 << 8;
        4'b1001: out = 16'b1 << 9;
        4'b1010: out = 16'b1 << 10;
        4'b1011: out = 16'b1 << 11;
        4'b1100: out = 16'b1 << 12;
        4'b1101: out = 16'b1 << 13;
        4'b1110: out = 16'b1 << 14;
        4'b1111: out = 16'b1 << 15;
        default: out = 16'b0;
		
		endcase
	end
	
	else 
	out=0;
	
	
	
	
	
	
	

	end
	


endmodule
