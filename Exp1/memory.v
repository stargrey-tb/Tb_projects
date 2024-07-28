module memory #(parameter W=8)(
input clk,
input wrt_enable,
input [W-1:0] wrt_data,
input [7:0] address,
output reg [W-1:0] read_data


);

reg [7:0] memory [0:255];			// 1 byte long data storage in 256 elements
reg [3:0] offset;
integer i;

always@ (address) begin
offset=W/8;								//if there is longer than 1 byte 
		for(i=0;i<offset;i=i+1)begin
		read_data[(i+1)*8 - 1 -: 8] = memory[address + i];			//moves to the next memory address
		end


end

always@ (posedge clk) begin

	if(wrt_enable==1)begin
	offset=W/8;
		for(i=0;i<offset;i=i+1)begin
		memory[address + i] = wrt_data[(i+1)*8 - 1 -: 8];		//moves to the next memory address in the same way like read data
		end	
	
	end


end


endmodule