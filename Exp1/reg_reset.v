

module reg_reset #(parameter W=4)(
input [W-1:0] data,
input clk,
input reset,
output reg [W-1:0] out

);

	always@(posedge clk) begin			// wait for the clock
		if(reset==0)
		out<=data;					// if reset is zero write to the register

		else
		out<=0;

	end

endmodule
