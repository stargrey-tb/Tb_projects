


module compare_both(

input [31:0] rs1,
input [31:0] rs2,
output reg [1:0] compare_out

);

always @ (*) begin

	if( rs1 == rs2 ) begin
		compare_out[1]=1;
	end
	
	else begin
		compare_out[1]=0;
	end
	
	if( rs1 < rs2 ) begin
		compare_out[0]=0;
	end
	
	else begin
		compare_out[0]=1;
	end

end 

endmodule

