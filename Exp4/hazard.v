

module hazard (
input [3:0] RA1E,
input [3:0] WA3M,
input [3:0] WA3W,
input RegWriteM,
input RegWriteW,
input MemtoRegE,

input [3:0] RA2E,
input [3:0] RA1D,
input [3:0] WA3E,
input [3:0] RA2D,

input PCSrcD,
input PCSrcW,

input BranchTakenE,


output reg [1:0] ForwardAE,
output reg [1:0] ForwardBE,
output reg StallF,
output reg StallD,
output reg FlushD,
output reg FlushE

);



reg Match_1E_M;
reg Match_1E_W;
reg Match_2E_M;
reg Match_2E_W;
reg Match_12D_E;
reg LDRstall;
reg PCWrPendingF;


always @(*) begin

Match_1E_M = (RA1E == WA3M);
Match_1E_W = (RA1E == WA3W);

	if (Match_1E_M && RegWriteM) begin
		ForwardAE = 2'b10; 
	end
	else if (Match_1E_W && RegWriteW) begin
		ForwardAE = 2'b01; 
	end
	else begin
		ForwardAE = 2'b00; 
	end


Match_2E_M = (RA2E == WA3M);
Match_2E_W = (RA2E == WA3W);

	if (Match_2E_M && RegWriteM) begin
		ForwardBE = 2'b10; 
	end
	else if (Match_2E_W && RegWriteW) begin
		ForwardBE = 2'b01; 
	end
	else begin 
		ForwardBE = 2'b00; 
	end

	
Match_12D_E = (RA1D == WA3E) || (RA2D == WA3E);
LDRstall = Match_12D_E && MemtoRegE;



PCWrPendingF = (PCSrcD) && BranchTakenE; 
StallF = LDRstall || PCWrPendingF; 
StallD = LDRstall;
FlushD = PCWrPendingF || PCSrcW || BranchTakenE; 
FlushE = LDRstall || BranchTakenE;


end






endmodule


