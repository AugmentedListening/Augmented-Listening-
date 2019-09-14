module temptop(

	input logic lrclk_tx, lrclk_rx, 
	input logic sdata_tx, sdata_rx,
	output logic [15:0] left_tx_chan,
	output logic [15:0] right_tx_chan,
	output logic [15:0] left_rx_chan,
	output logic [15:0] right_rx_chan,
	input logic sclk,
	input logic reset
	
);


i2s_tx i2s_tx0 (
	.sclk		(sclk),
	.rst		(rst),

	.prescaler	(16'd32),

	.lrclk		(lrclk_tx),
	.sdata		(sdata_tx),

	.left_chan	(left_tx_chan),
	.right_chan	(right_tx_chan)
);

i2s_rx i2s_rx0 (
	.sclk		(sclk),
	.rst		(rst),

	.lrclk		(lrclk_rx),
	.sdata		(sdata_rx),

	.left_chan	(left_rx_chan),
	.right_chan	(right_rx_chan)
);


endmodule
