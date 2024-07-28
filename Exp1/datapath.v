

module datapath #(parameter W = 8)(
input [W-1:0] data,
input clk,
input reset,
input [1:0] choose,
output wire CO,
output wire OVF,
output wire Z,
output wire N,
output wire [W-1:0] out
);
reg finish;
reg [1:0] choose_dump;
reg [3:0] ALU_dump;
reg [4:0] shampt_dump;
reg [1:0] shift_dump;
reg [1:0] state;
wire [W-1:0] m1_wire;
wire [W-1:0] m2_wire;
wire [W-1:0] m3_wire;
wire [W-1:0] m4_wire;
wire [W-1:0] shift_out;
wire [W-1:0] ALU_out;
wire m1_sel;
reg m1_sel_r;
wire m2_sel;
reg m2_sel_r;
wire m3_sel;
reg m3_sel_r;
wire m4_sel;
reg m4_sel_r;
wire wrt_enable;
reg wrt_enable_r;
wire carry_control;
wire [4:0] shampt_control;
reg  [4:0] shampt_control_r;
wire [1:0]shift_control;
reg [1:0] shift_control_r;
wire [3:0] ALU_control;
reg [3:0] ALU_control_r;
wire [W-1:0] reg_inp_wire;
wire [W-1:0] reg_out_wire;
mux_2to1 m1(.inp0(reg_out_wire),.inp1(shift_out),.sel(m1_sel),.out(m1_wire));				// wire connections are more clear in the report
mux_2to1 m2(.inp0(m4_wire),.inp1(data),.sel(m2_sel),.out(m2_wire));
ALU AL1(.A(m1_wire),.B(m2_wire),.carry(carry_control),.control(ALU_control),.CO(CO),.OVF(OVF),.Z(Z),.N(N),.out(ALU_out));
reg_reset_write rrwd1(.data(ALU_out),.clk(clk),.reset(reset),.wrt_enable(wrt_enable),.out(reg_out_wire));

comb_shifter cmd1(.data(m3_wire),.shampt(shampt_control),.control(shift_control),.out(shift_out));
mux_2to1 m3 (.inp0(data),.inp1(reg_out_wire),.sel(m3_sel),.out(m3_wire));
mux_2to1 m4 (.inp0(8'b1),.inp1(shift_out),.sel(m4_sel),.out(m4_wire));

always @(posedge clk) begin
		if(choose_dump!=choose) begin				
		state=0;
		finish=0;
		end
		
		if(finish==1) begin
		wrt_enable_r=0;
		state=3;
		end
		
		if({state,choose}==4'b0001) begin		// 2's complement start
		m2_sel_r=1;
		ALU_control_r=4'b1111;						//1's complement
		wrt_enable_r=1;
		end
		
		else if({state,choose}==4'b0101) begin		//Add 1
		m1_sel_r=0;
		m2_sel_r=0;
		m4_sel_r=0;
		ALU_control_r=4'b0100;
		wrt_enable_r=1;
		finish=1;            						// Reset the state ///////////////
		end
		
		else if({state,choose}==4'b0010) begin				// Multiply 10 start
		m3_sel_r=0;
		shampt_control_r=5'b00011;							// Shift left 3 times
		shift_control_r=2'b00;								
		m4_sel_r=1;													
		m2_sel_r=0;
		ALU_control_r=4'b1101;
		wrt_enable_r=1;									// Means muliple 8
		end
		
		else if({state,choose}==4'b0110) begin			
		m3_sel_r=0;
		shampt_control_r=5'b00001;						//Add with LSL by 2 
		shift_control_r=2'b00;
		m4_sel_r=1;
		m2_sel_r=0;
		m1_sel_r=0;
		ALU_control_r=4'b0100;
	   finish=1;          							// Reset state//////////////////
		end 
		
		else if({state,choose}==4'b0011) begin		// Duplicate start
		m3_sel_r=0;
		shampt_control_r=5'b00100;
		shift_control_r=2'b01;							// Shift 4 step right
		m4_sel_r=1;
		m2_sel_r=0;
		ALU_control_r=4'b1101;
		wrt_enable_r=1;

		end
		
		else if({state,choose}==4'b0111) begin
		m3_sel_r=1;
		shampt_control_r=5'b00100;
		shift_control_r=2'b00;							// Shift the result 4 step left
		m4_sel_r=1;
		m2_sel_r=0;
		ALU_control_r=4'b1101;
		wrt_enable_r=1;
		
		end
		
		else if({state,choose}==4'b1011) begin
		m3_sel_r=0;
		shampt_control_r=5'b00100;
		shift_control_r=2'b01;						// ORR with shift right
		m4_sel_r=1;
		m2_sel_r=0;
		m1_sel_r=0;
		ALU_control_r=4'b1100;
		wrt_enable_r=1;
		finish=1;          				// Reset state//////////////////
		end 
choose_dump=choose;

if(finish==0)
state=state+1;

end

assign m1_sel=m1_sel_r;							// assign wire connections to reg values 
assign m2_sel=m2_sel_r;
assign m3_sel=m3_sel_r;
assign m4_sel=m4_sel_r;
assign wrt_enable=wrt_enable_r;
assign shampt_control=shampt_control_r;
assign shift_control=shift_control_r;
assign ALU_control=ALU_control_r;
assign out=reg_out_wire;


endmodule
