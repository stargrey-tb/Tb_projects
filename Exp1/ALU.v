

module ALU #(parameter W = 8)(
input [W-1:0] A,
input [W-1:0] B,
input carry,
input [3:0] control,
output reg CO,
output reg OVF,
output reg Z,
output reg N,
output reg [W-1:0] out

);

		always @(*)begin
		if(control==4'b0000)				// check control input 
		out= A&B;
		
		else if(control==4'b0001)
		out= A^B;
		
		else if(control==4'b0010)		// find carry out while calculating
		{CO,out}= A-B;
		
		else if(control==4'b0011)
		{CO,out}= B-A;
		
		else if(control==4'b0100)
		{CO,out}= A+B;
		
		else if(control==4'b0101)
		{CO,out}= A+B+carry;
		
		else if(control==4'b0110)
		{CO,out}= A-B+carry-1;
		
		else if(control==4'b0111)
		{CO,out}= B-A+carry-1;
		
		else if(control==4'b1100)
		out= A|B;
		
		else if(control==4'b1101)
		out= B;
		
		else if(control==4'b1110)
		out= ~B & A;
		
		else if(control==4'b1111)
		out= ~B;
		
		else
		out=0;
		
		
		if(out!=0)					// check whether it is zero
		Z=0;
		
		else
		Z=1;
		
		N=out[W-1];					// check first bit for negative
		
		if(~control[3] & (control[2]|control[1]))begin
		
		OVF= (~out[W-1] & A[W-1] & B[W-1]) || (out[W-1] & ~A[W-1] & ~B[W-1]); 		// check sign bits of operands and result

		end
		
		else begin
		CO=0;
		OVF=0;
		end
		
		
		
		end

endmodule
