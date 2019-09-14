module i2s_tx (
	input	 logic	sclk,
	input	 logic 	rst,

	// Prescaler for lrclk generation from sclk should hold the number of
	// sclk cycles per channel (left and right).
	input logic [15:0]	prescaler,

	output logic	lrclk,
	output logic		sdata,

	// Parallel datastreams
	input logic [15:0]	left_chan,
	input logic [15:0]	right_chan
);

logic [15:0]		bit_cnt;
logic [15:0]		left;
logic [15:0]		right;

always_ff @(negedge sclk)
begin
	if (rst)
		bit_cnt <= 1;
	else if (bit_cnt >= prescaler)
		bit_cnt <= 1;
	else
		bit_cnt <= bit_cnt + 1;
end

// Sample channels on the transfer of the last bit of the right channel
always_ff @(negedge sclk)
begin
	if (bit_cnt == prescaler && lrclk) 
	begin
		left <= left_chan;
		right <= right_chan;
	end
end

// left/right "clock" generation - 0 = left, 1 = right
always_ff @(negedge sclk)
begin
	if (rst)
		lrclk <= 1;
	else if (bit_cnt == prescaler)
		lrclk <= ~lrclk;
end

always_ff @(negedge sclk)
begin
	sdata <= lrclk ? right[16 - bit_cnt] : left[16 - bit_cnt];
end

endmodule
