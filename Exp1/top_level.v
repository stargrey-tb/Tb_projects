


module top_level #(parameter W = 8)( // to show datapath in FPGA
input [W-1:0] inp,
input clock,
input [1:0] chs,
output [6:0] dp1,
output [6:0] dp2,
output [6:0] dp3
);

wire [W-1:0] transition;
datapath dpath1(.data(inp),.clk(clock),.reset(0),.choose(chs),.out(transition)); 
sev_seg_display ssd1(.inp(transition),.display1(dp1),.display2(dp2),.display3(dp3));  		// connect output of the datapath to input of the 7 segment display


endmodule

