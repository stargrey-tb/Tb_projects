module mux_4to1#(parameter W=3)(

  input   [W-1:0] inp0,
  input   [W-1:0] inp1,
  input   [W-1:0] inp2,
  input   [W-1:0] inp3,
  input    [1:0]sel,
  output reg [W-1:0] out
  );
  always @(inp0,inp1,inp2,inp3,sel) begin			// case selection for 4x1 MUX
		case (sel)
        2'b00: out = inp0;
        2'b01: out = inp1;
        2'b10: out = inp2;
        2'b11: out = inp3;
		  
        default: out = 4'b0;
		  
		endcase
		
	end
  
endmodule