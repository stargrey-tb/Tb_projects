



module mux_2to1#(parameter W=8)(

  input   [W-1:0] inp0,
  input   [W-1:0] inp1,
  input    sel,
  output  wire [W-1:0] out
  );
  assign out = (sel) ? inp1 : inp0;			// case selection for 2x1 MUX

  
endmodule












