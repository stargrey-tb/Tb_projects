

module reg_reset_write #(parameter W=8)(
input [W-1:0] data,
input clk,
input reset,
input wrt_enable,
output reg [W-1:0] out

);

	always@(posedge clk) begin
		if(reset==0) begin			// if reset data can be written
			
			if(wrt_enable==1)			// wait for write enable
			out<=data;
			
		
		end
		
		else
		
		out<=0;

	end

endmodule
