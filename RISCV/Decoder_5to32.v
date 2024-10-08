module Decoder_5to32
    (
	  input [4:0] IN,
      output reg [31:0] OUT
    );

always @(*) begin
	case(IN)
		5'd0:OUT=32'h00000001;
		5'd1:OUT=32'h00000002;
		5'd2:OUT=32'h00000004;
		5'd3:OUT=32'h00000008;
	    5'd4:OUT=32'h00000010;
		5'd5:OUT=32'h00000020;
		5'd6:OUT=32'h00000040;
		5'd7:OUT=32'h00000080;
	    5'd8:OUT=32'h00000100;
		5'd9:OUT=32'h00000200;
		5'd10:OUT=32'h00000400;
		5'd11:OUT=32'h00000800;
	    5'd12:OUT=32'h00001000;
		5'd13:OUT=32'h00002000;
		5'd14:OUT=32'h00004000;
		5'd15:OUT=32'h00008000;


		5'd16:OUT=32'h00010000;
		5'd17:OUT=32'h00020000;
		5'd18:OUT=32'h00040000;
		5'd19:OUT=32'h00080000;
	    5'd20:OUT=32'h00100000;
		5'd21:OUT=32'h00200000;
		5'd22:OUT=32'h00400000;
		5'd23:OUT=32'h00800000;
	    5'd24:OUT=32'h01000000;
		5'd25:OUT=32'h02000000;
		5'd26:OUT=32'h04000000;
		5'd27:OUT=32'h08000000;
	    5'd28:OUT=32'h10000000;
		5'd29:OUT=32'h20000000;
		5'd30:OUT=32'h40000000;
		5'd31:OUT=32'h80000000;


	endcase
end

endmodule
