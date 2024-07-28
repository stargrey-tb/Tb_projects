

module reg_top #(parameter W=8)(  //to show register file with FPGA
input rst,
input clock,
input wrt_enable,
input [W-1:0] data,
input [3:0] sel1,
input [3:0] sel2,
input [3:0] dest,
output [6:0] dp0,
output [6:0] dp1,
output [6:0] dp4,
output [6:0] dp5

);
wire [W-1:0] read1;
wire [W-1:0] read2;
sev_seg_display ssd2 (.inp(read1),.display1(dp0),.display2(dp1)); 							// connect register file out to input of the 7 segment display
sev_seg_display ssd3 (.inp(read2),.display1(dp4),.display2(dp5)); 							// connect register file out to input of the another 7 segment display

register_file rf2 (.reset(rst),.clk(clock),.wrt_enable(wrt_enable),.wrt_data(data),.src_sel1(sel1),.src_sel2(sel2),.dest_sel(dest),.read_data1(read1),.read_data2(read2));

endmodule

