

module sev_seg_display#(parameter W = 8)(
input [W-1:0] inp,
output reg[6:0] display1,		// 1st display
output reg[6:0] display2,		// 2nd display
output reg[6:0] display3		// 3rd display
);
reg [3:0] num1;
reg [3:0] num2;
reg [3:0] num3;



always @(*) begin			//take 3 digit number and divide to places
num3=inp/100;				//num3 hundreds place
num2=(inp/10)-(num3*10);	//num2 tens place
num1=inp-(num3*100)-(num2*10);	//num1 ones place
	case(num1)
	4'b0000:display1<=7'b1000000;			// 1st display
	4'b0001:display1<=7'b1111001;
	4'b0010:display1<=7'b0100100;
	4'b0011:display1<=7'b0110000;
	4'b0100:display1<=7'b0011001;
	4'b0101:display1<=7'b1001001;
	4'b0110:display1<=7'b0000001;
	4'b0111:display1<=7'b1111100;
	4'b1000:display1<=7'b0000000;
	4'b1001:display1<=7'b0010000;
	default:display1<=7'b1000000;
	endcase
	
	case(num2)
	4'b0000:display2<=7'b1000000;			// 2nd display
	4'b0001:display2<=7'b1111001;
	4'b0010:display2<=7'b0100100;
	4'b0011:display2<=7'b0110000;
	4'b0100:display2<=7'b0011001;
	4'b0101:display2<=7'b1001001;
	4'b0110:display2<=7'b0000001;
	4'b0111:display2<=7'b1111100;
	4'b1000:display2<=7'b0000000;
	4'b1001:display2<=7'b0010000;
	default:display2<=7'b1000000;
	endcase
	
	case(num3)
	4'b0000:display3<=7'b1000000;			// 3rd display
	4'b0001:display3<=7'b1111001;
	4'b0010:display3<=7'b0100100;
	4'b0011:display3<=7'b0110000;
	4'b0100:display3<=7'b0011001;
	4'b0101:display3<=7'b1001001;
	4'b0110:display3<=7'b0000001;
	4'b0111:display3<=7'b1111100;
	4'b1000:display3<=7'b0000000;
	4'b1001:display3<=7'b0010000;
	default:display3<=7'b1000000;
	endcase
	


end
endmodule
