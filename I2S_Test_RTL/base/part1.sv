module part1 (CLOCK_50, CLOCK2_50, KEY, FPGA_I2C_SCLK, FPGA_I2C_SDAT, AUD_XCK, 
		        AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK, AUD_DACDAT, GPIO_DIN, GPIO_DIN2, GPIO_BCLK, GPIO_LRCLK, AUD_ADCDAT, GPIO_XCK, SW);
																				// ^ Mic input 1 ^ Mic input 2
	input CLOCK_50, CLOCK2_50;
	input [3:0] KEY;
	// I2C Audio/Video config interface
	output FPGA_I2C_SCLK;
	inout FPGA_I2C_SDAT;
	// Audio CODEC
	output AUD_XCK;
	input AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK;
	output AUD_DACDAT;
	input GPIO_DIN;	// Digital mic data from mic pair 1
	input GPIO_DIN2;	// Digital mic data from mic pair 2
	
	/* Once you add more mics you need to add more inputs to the top level module */
	/* Follow the same pattern for GPIO_DIN and GPIO_DIN2, you will also need to  */
	/* Assign these signals to its corresponding pin on the pin planner use the   */
	/* Manual for the DE1-SoC to see the mappings for the FPGA pins					*/
	
	output GPIO_BCLK;
	output GPIO_LRCLK;
	input AUD_ADCDAT;
	output GPIO_XCK;
	input [9:0] SW;
	
	// Local wires.
	wire reset = ~KEY[0];

	/////////////////////////////////
	// Your code goes here 
	/////////////////////////////////
	
	assign GPIO_BCLK = AUD_BCLK;
	assign GPIO_LRCLK = AUD_ADCLRCK;
	assign GPIO_XCK = AUD_XCK;

	
/////////////////////////////////////////////////////////////////////////////////
// Audio CODEC interface. 
//
// The interface consists of the following wires:
// read_ready, write_ready - CODEC ready for read/write operation 
// readdata_left, readdata_right - left and right channel data from the CODEC
// read - send data from the CODEC (both channels)
// writedata_left, writedata_right - left and right channel data to the CODEC
// write - send data to the CODEC (both channels)
// AUD_* - should connect to top-level entity I/O of the same name.
//         These signals go directly to the Audio CODEC
// I2C_* - should connect to top-level entity I/O of the same name.
//         These signals go directly to the Audio/Video Config module
/////////////////////////////////////////////////////////////////////////////////
logic left_ready, right_ready, left_valid, right_valid;

/* Audio IP interface created from qsys */
/* Do Not modify this 						 */
audio aud(
	.clk_clk(CLOCK_50),            //          clk.clk
	.ext_ADCDAT(AUD_ADCDAT),         //          ext.ADCDAT
	.ext_ADCLRCK(AUD_ADCLRCK),        //             .ADCLRCK
	.ext_BCLK(AUD_BCLK),           //             .BCLK
	.ext_DACDAT(AUD_DACDAT),         //             .DACDAT
	.ext_DACLRCK(AUD_DACLRCK),        //             .DACLRCK
	.ext_1_SDAT(FPGA_I2C_SDAT),         //        ext_1.SDAT
	.ext_1_SCLK(FPGA_I2C_SCLK),         //             .SCLK
	.left_input_data(left_channel_mic),    //   left_input.data
	.left_input_valid(left_valid),   //             .valid
	.left_input_ready(left_ready),   //             .ready
	.left_output_ready(left_ready),  //  left_output.ready
	.left_output_data(),   //             .data
	.left_output_valid(left_valid),  //             .valid
	.reset_reset_n(1'b1),      //        reset.reset_n
	.right_input_data(right_channel_mic),   //  right_input.data
	.right_input_valid(right_valid),  //             .valid
	.right_input_ready(right_ready),  //             .ready
	.right_output_ready(right_ready), // right_output.ready
	.right_output_data(),  //             .data
	.right_output_valid(right_valid)  //             .valid
);

/* Audio clock configuration from qsys */
/* Do not modify this either */
audio_pll clock_gen(
	.audio_pll_0_audio_clk_clk(AUD_XCK),
	.audio_pll_0_ref_clk_clk(CLOCK2_50),
	.audio_pll_0_ref_reset_reset(reset),
	.audio_pll_0_ref_reset_source_reset()
);

/* Variables for the microphone data */
logic [15:0] mic_l, mic_r, mic_l2, mic_r2;
logic [15:0] left_channel_mic, right_channel_mic;

/* These signals go into the input of the audio module        */
/* if you were to add support for 2 more microphones then     */
/* You will need to add the left and right channel to these   */
/* registers  e.g. left_channel_mic = mic_l + mic_l2 + mic_l3 */

assign left_channel_mic = mic_l + mic_l2;
assign right_channel_mic = mic_r + mic_r2;

/* I2S recieve block to interpret mic data from mic pair 1 and 2 */
/* The output channels data_left and data_right will be samples  */
/* from its repsective microphone. Once you have your prototype  */
/* Once you decide to test more microphones you will need to add */
/* more of these modules.*/
i2s_receive rx1(
	.sck(AUD_BCLK),
   .ws(AUD_ADCLRCK),
   .sd(GPIO_DIN),
   .data_left(mic_l),
   .data_right(mic_r)
);

i2s_receive rx2(
	.sck(AUD_BCLK),
   .ws(AUD_ADCLRCK),
   .sd(GPIO_DIN2),
   .data_left(mic_l2),
   .data_right(mic_r2)
);


endmodule
