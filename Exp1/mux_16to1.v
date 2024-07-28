
module mux_16to1#(parameter W=8)(

  input [W-1:0] inp0,
  input [W-1:0] inp1,
  input [W-1:0] inp2,
  input [W-1:0] inp3,
  input [W-1:0] inp4,
  input [W-1:0] inp5,
  input [W-1:0] inp6,
  input [W-1:0] inp7,
  input [W-1:0] inp8,
  input [W-1:0] inp9,
  input [W-1:0] inp10,
  input [W-1:0] inp11,
  input [W-1:0] inp12,
  input [W-1:0] inp13,
  input [W-1:0] inp14,
  input [W-1:0] inp15,
  input  [3:0]sel,
  output reg [W-1:0] out
  );
  
  always @(*) begin
  case (sel)						// case selection for 16x1 MUX
        4'b0000: out=inp0;
        4'b0001: out=inp1;
        4'b0010: out=inp2;
        4'b0011: out=inp3;
        4'b0100: out=inp4;
        4'b0101: out=inp5;
        4'b0110: out=inp6;
        4'b0111: out=inp7;
        4'b1000: out=inp8;
        4'b1001: out=inp9;
        4'b1010: out=inp10;
        4'b1011: out=inp11;
        4'b1100: out=inp12;
        4'b1101: out=inp13;
        4'b1110: out=inp14;
        4'b1111: out=inp15;
		  
        default: out=8'b0; 
		  
    endcase
  
  
  end
  
 endmodule
 