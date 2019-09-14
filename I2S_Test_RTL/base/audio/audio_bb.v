
module audio (
	clk_clk,
	reset_reset_n,
	left_output_ready,
	left_output_data,
	left_output_valid,
	right_output_ready,
	right_output_data,
	right_output_valid,
	left_input_data,
	left_input_valid,
	left_input_ready,
	right_input_data,
	right_input_valid,
	right_input_ready,
	ext_ADCDAT,
	ext_ADCLRCK,
	ext_BCLK,
	ext_DACDAT,
	ext_DACLRCK,
	ext_1_SDAT,
	ext_1_SCLK);	

	input		clk_clk;
	input		reset_reset_n;
	input		left_output_ready;
	output	[15:0]	left_output_data;
	output		left_output_valid;
	input		right_output_ready;
	output	[15:0]	right_output_data;
	output		right_output_valid;
	input	[15:0]	left_input_data;
	input		left_input_valid;
	output		left_input_ready;
	input	[15:0]	right_input_data;
	input		right_input_valid;
	output		right_input_ready;
	input		ext_ADCDAT;
	input		ext_ADCLRCK;
	input		ext_BCLK;
	output		ext_DACDAT;
	input		ext_DACLRCK;
	inout		ext_1_SDAT;
	output		ext_1_SCLK;
endmodule
