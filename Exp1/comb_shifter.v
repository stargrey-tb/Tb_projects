
module comb_shifter #(parameter W = 8)(
input [W-1:0] data,
input [4:0] shampt,
input [1:0] control,
output reg [W-1:0] out
);

always @(*)begin

	if(control==2'b00)			// logicalshift left
	out=data<<shampt;

	else if(control==2'b01)			// logical shift right
	out=data>>shampt;

	else if(control==2'b10) begin			// arithmetic shift right
    out=data>>shampt;
	 
	 if(data[W-1]==1) 				// rotate right
	 out=(~out)+1'b1;
	
	end
	
	else if(control==2'b11)begin
	out=(data>>shampt)|(data<<(W-shampt));
	end
	
	else
	out=0;

end

endmodule
