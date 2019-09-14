module i2s_rx(
	input		logic		sclk,
	input		logic		rst,

	input		logic		lrclk,
	input		logic		sdata,

	// Parallel datastreams
	output logic [15:0]	left_chan,
	output logic [15:0]	right_chan
);

logic [15:0]	left;
logic [15:0]	right;
logic			lrclk_r;
logic			lrclk_nedge;

assign lrclk_nedge = !lrclk & lrclk_r;

always @(posedge sclk)
	lrclk_r <= lrclk;

// sdata msb is valid one clock cycle after lrclk switches
always_ff @ (posedge sclk)
	begin
	if (lrclk_r)
		right <= {right[14:0], sdata};
	else
		left <= {left[14:0], sdata};
	end

always_ff @(posedge sclk)
begin
	if (rst) 
		begin
		left_chan <= 0;
		right_chan <= 0;
		end 
	else if (lrclk_nedge) 
	begin
		left_chan <= left;
		right_chan <= {right[14:0], sdata};
	end

end
endmodule
