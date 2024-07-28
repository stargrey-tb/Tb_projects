

module register_file #(parameter W=8)(
input reset,
input clk,
input wrt_enable,
input [W-1:0] wrt_data,
input [3:0] src_sel1,
input [3:0] src_sel2,
input [3:0] dest_sel,
output wire [W-1:0] read_data1,
output wire [W-1:0] read_data2

);
wire [15:0] reg_inp;
wire [W-1:0] reg_out [15:0];

decoder_4to16 decoder1(.inp(dest_sel),. wrt_enable(wrt_enable),.out(reg_inp[15:0]));								// choose destination selection and distribute with decoder
reg_reset_write r0(.data(wrt_data),.clk(clk),.reset(reset),.wrt_enable(reg_inp[0]),.out(reg_out[0]));
reg_reset_write r1(.data(wrt_data),.clk(clk),.reset(reset),.wrt_enable(reg_inp[1]),.out(reg_out[1]));
reg_reset_write r2(.data(wrt_data),.clk(clk),.reset(reset),.wrt_enable(reg_inp[2]),.out(reg_out[2]));
reg_reset_write r3(.data(wrt_data),.clk(clk),.reset(reset),.wrt_enable(reg_inp[3]),.out(reg_out[3]));
reg_reset_write r4(.data(wrt_data),.clk(clk),.reset(reset),.wrt_enable(reg_inp[4]),.out(reg_out[4]));				// each register have input from decoder
reg_reset_write r5(.data(wrt_data),.clk(clk),.reset(reset),.wrt_enable(reg_inp[5]),.out(reg_out[5]));
reg_reset_write r6(.data(wrt_data),.clk(clk),.reset(reset),.wrt_enable(reg_inp[6]),.out(reg_out[6]));
reg_reset_write r7(.data(wrt_data),.clk(clk),.reset(reset),.wrt_enable(reg_inp[7]),.out(reg_out[7]));
reg_reset_write r8(.data(wrt_data),.clk(clk),.reset(reset),.wrt_enable(reg_inp[8]),.out(reg_out[8]));
reg_reset_write r9(.data(wrt_data),.clk(clk),.reset(reset),.wrt_enable(reg_inp[8]),.out(reg_out[9]));
reg_reset_write r10(.data(wrt_data),.clk(clk),.reset(reset),.wrt_enable(reg_inp[10]),.out(reg_out[10]));			
reg_reset_write r11(.data(wrt_data),.clk(clk),.reset(reset),.wrt_enable(reg_inp[11]),.out(reg_out[11]));
reg_reset_write r12(.data(wrt_data),.clk(clk),.reset(reset),.wrt_enable(reg_inp[12]),.out(reg_out[12]));
reg_reset_write r13(.data(wrt_data),.clk(clk),.reset(reset),.wrt_enable(reg_inp[13]),.out(reg_out[13]));
reg_reset_write r14(.data(wrt_data),.clk(clk),.reset(reset),.wrt_enable(reg_inp[14]),.out(reg_out[14]));
reg_reset_write r15(.data(wrt_data),.clk(clk),.reset(reset),.wrt_enable(reg_inp[15]),.out(reg_out[15]));
mux_16to1 m1 (
    .inp0(reg_out[0]),
    .inp1(reg_out[1]),
    .inp2(reg_out[2]),
    .inp3(reg_out[3]),
    .inp4(reg_out[4]),						// each register have output to mux
    .inp5(reg_out[5]),
    .inp6(reg_out[6]),
    .inp7(reg_out[7]),
    .inp8(reg_out[8]),
    .inp9(reg_out[9]),
    .inp10(reg_out[10]),
    .inp11(reg_out[11]),
    .inp12(reg_out[12]),					
    .inp13(reg_out[13]),
    .inp14(reg_out[14]),
    .inp15(reg_out[15]),
	 .sel(src_sel1),							// Register selection with source select input
	 .out(read_data1)
);

mux_16to1 m2 (
    .inp0(reg_out[0]),
    .inp1(reg_out[1]),
    .inp2(reg_out[2]),
    .inp3(reg_out[3]),
    .inp4(reg_out[4]),					// each register have output to mux
    .inp5(reg_out[5]),
    .inp6(reg_out[6]),
    .inp7(reg_out[7]),
    .inp8(reg_out[8]),
    .inp9(reg_out[9]),
    .inp10(reg_out[10]),
    .inp11(reg_out[11]),
    .inp12(reg_out[12]),
    .inp13(reg_out[13]),
    .inp14(reg_out[14]),
    .inp15(reg_out[15]),
	 .sel(src_sel2),						// Register selection with source select input
	 .out(read_data2)
);


endmodule

