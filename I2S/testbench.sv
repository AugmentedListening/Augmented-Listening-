module testbench();

	timeunit 1ns; 
	timeprecision 1ns; 

	parameter AUDIO_DW = 16;
	logic sclk;
	logic lrclk_tx, lrclk_rx;
	logic sdata_tx, sdata_rx;
	logic [AUDIO_DW-1:0] left_tx_chan;
	logic [AUDIO_DW-1:0] right_tx_chan;
	logic [AUDIO_DW-1:0] left_rx_chan;
	logic [AUDIO_DW-1:0] right_rx_chan;
	logic reset;

	temptop i2s (.*);

    always begin : CLOCK_GENERATION
    #1  sclk = ~sclk;
    end

    initial begin : CLOCK_INITIALIZATION
        sclk = 0;
    end


initial begin : TEST_VECTORS
	left_tx_chan = 16'h4567;
	right_tx_chan = 16'hcdef;
	reset = 1;
	#2 reset = 0;
	#2 sdata_tx = 16'hfafa;
	#22 sdata_tx = 16'hffff;
	if (left_rx_chan == left_tx_chan && right_rx_chan == right_tx_chan)
		$display("Test passed!");
	else
		$display("Test failed!");
end

endmodule
