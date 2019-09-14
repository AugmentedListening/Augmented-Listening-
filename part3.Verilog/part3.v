module part3 (CLOCK_50, CLOCK2_50, KEY, FPGA_I2C_SCLK, FPGA_I2C_SDAT, AUD_XCK, AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK, AUD_DACDAT, GPIO_DIN, GPIO_BCLK, GPIO_LRCK, GPIO_CLK50, HEX);

	input CLOCK_50, CLOCK2_50;
	input [0:0] KEY;
	// I2C Audio/Video config interface
	output FPGA_I2C_SCLK;
	inout FPGA_I2C_SDAT;
	// Audio CODEC
	output AUD_XCK;
	input AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK;
	//input AUD_ADCDAT;
	output AUD_DACDAT;
	input GPIO_DIN;
	output GPIO_BCLK;
	output GPIO_LRCK;
	output GPIO_CLK50;
	output [6:0] HEX;
	
	assign GPIO_BCLK = AUD_BCLK;
	assign GPIO_LRCK = AUD_ADCLRCK;
	assign GPIO_CLK50 = CLOCK_50;
	
	wire AXIS_TVALID;
	wire [23:0] AXIS_TDATA;
	wire AXIS_TLAST;
	wire AXIS_TREADY;
	
	// Local wires.
	wire read_ready, write_ready, read, write;
	wire [23:0] readdata_left, readdata_right;
	wire [23:0] writedata_left, writedata_right;
	wire [23:0] buffer_left, buffer_right;
	wire [23:0] divided_left, divided_right;
	wire [23:0] result_left, result_right;
	reg [23:0] sum_left, sum_right;
	//wire AUD_ADCDAT;
//	wire [23:0] noise;

//	module GPIO_Interface 
//(input	 logic GPIO,
//output logic [6:0]  G0_Hex);

	GPIO_Interface(
		.GPIO(GPIO_DIN),
		.G0_Hex(HEX)
	);
		
	wire reset = KEY[0];
	
	// Read and write only when both are possible.
	assign read = write_ready & read_ready;
	assign write = write_ready & read_ready;
	
	fifo_with_division left_buffer(CLOCK_50, reset, read, readdata_left, divided_left, buffer_left);
		defparam left_buffer.BITS_TO_SHIFT_BY = 5; /* it means divide by 2^(BITS_TO_SHIFT_BY) */
		defparam left_buffer.ELEMENT_COUNT = 32;
		
	fifo_with_division right_buffer(CLOCK_50, reset, read, readdata_right, divided_right, buffer_right);
		defparam right_buffer.BITS_TO_SHIFT_BY = 5; /* it means divide by 2^(BITS_TO_SHIFT_BY) */
		defparam right_buffer.ELEMENT_COUNT = 32;
	
	assign result_left = sum_left + divided_left - buffer_left;
	assign result_right = sum_right + divided_right - buffer_right;
	
	always@(posedge CLOCK_50 or negedge reset)
		if (~reset)
		begin
			sum_left <= 24'd0;
			sum_right <= 24'd0;
		end
		else
		if (read & write)
		begin
			sum_left <= result_left;
			sum_right <= result_right;
		end
				
	assign writedata_left = result_left;
	assign writedata_right = result_right;
				
//	noise_generator mynoise(CLOCK_50, read, noise);
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
	clock_generator my_clock_gen(
		// inputs
		CLOCK2_50,
		~reset,

		// outputs
		AUD_XCK
	);
	

	audio_and_video_config cfg(
		// Inputs
		CLOCK_50,
		~reset,

		// Bidirectionals
		FPGA_I2C_SDAT,
		FPGA_I2C_SCLK
	);
	
//module i2s_receive #
//  (
//   parameter DATA_WIDTH = 24
//   )
//  (
//   input M_AXIS_ACLK,
//   input M_AXIS_ARESETN,
//   output reg  M_AXIS_TVALID,
//   output reg [DATA_WIDTH-1 : 0] M_AXIS_TDATA,
//   output reg  M_AXIS_TLAST,
//   input wire  M_AXIS_TREADY,
//   
//   input sck,
//   input ws,
//   input sd
//   );
//
//	i2s_receive rx(
//		.M_AXIS_ACLK(CLOCK_50),
//		.M_AXIS_ARESETN(~reset),
//		.M_AXIS_TVALID(AXIS_TVALID),
//		.M_AXIS_TDATA(AXIS_TDATA),
//		.M_AXIS_TLAST(AXIS_TLAST),
//		.M_AXIS_TREADY(AXIS_TREADY),
//		.sck(AUD_BCK),
//		.ws(AUD_ADCLRCK),
//		.sd(GPIO_DIN)
//	);
//	
//	module i2s_transmit #
//  (
//   parameter DATA_WIDTH = 24
//   )
//  (
//   input S_AXIS_ACLK,
//   input S_AXIS_ARESETN,
//   input S_AXIS_TVALID,
//   input [DATA_WIDTH-1 : 0] S_AXIS_TDATA,
//   input S_AXIS_TLAST,
//   output reg S_AXIS_TREADY,
//  
//   input sck,
//   input ws,
//   output reg sd
//   );
//
//	i2s_transmit tx(
//		.S_AXIS_ACLK(CLOCK_50),
//		.S_AXIS_ARESETN(~reset),
//		.S_AXIS_TVALID(AXIS_TVALID),
//		.S_AXIS_TDATA(AXIS_TDATA),
//		.S_AXIS_TLAST(AXIS_TLAST),
//		.S_AXIS_TREADY(AXIS_TREADY),
//		.sck(AUD_BCLK),
//		.ws(AUD_ADCLRCK),
//		.sd(AUD_ADCDAT)
//	);

//module i2s_receive #
//  (
//   parameter width = 24
//   )
//  (
//   input sck,
//   input ws,
//   input sd,
//   output reg [width-1:0] data_left,
//   output reg [width-1:0] data_right
//   );

	i2s_receive rx(
		.sck(AUD_BCLK),
		.ws(AUD_ADCLRCK),
		.sd(GPIO_DIN),
		.data_left(readdata_left),
		.data_right(readdata_right)
	);

	audio_codec codec(
		// Inputs
		CLOCK_50,
		~reset,

		read,	write,
		writedata_left, writedata_right,

		AUD_ADCDAT,

		// Bidirectionals
		AUD_BCLK,
		AUD_ADCLRCK,
		AUD_DACLRCK,

		// Outputs
		read_ready, write_ready,
		//readdata_left, readdata_right,
		AUD_DACDAT
	);

endmodule


module fifo_with_division(clock, reset, enable, data_in, current_data_out, last_data_out);
	parameter BITS_TO_SHIFT_BY = 3; /* it means divide by 2^(BITS_TO_SHIFT_BY) */
	parameter ELEMENT_COUNT = 7;
	
	input clock, reset, enable;
	input [23:0] data_in;
	output [23:0] current_data_out, last_data_out;
	
	reg [23:0] buffer [0:ELEMENT_COUNT-1];	
	wire [23:0] input_divided;
	
	assign input_divided = {{BITS_TO_SHIFT_BY{data_in[23]}}, data_in[23:BITS_TO_SHIFT_BY]};
	
	// First the shift registers
	genvar index;
	generate
		for(index = 0; index < ELEMENT_COUNT; index=index+1)
		begin:shift_regs
			always@(posedge clock or negedge reset)
				if (~reset)
				begin
					buffer[index] <= 24'd0;
				end
				else
				begin
					if (enable)
					begin
						if (index == 0)
						begin
							buffer[index] <= input_divided;
						end
						else
						begin
							buffer[index] <= buffer[index-1];
						end
					end
				end
		end
	endgenerate
	assign current_data_out = input_divided;
	assign last_data_out = buffer[ELEMENT_COUNT-1];
endmodule

//module noise_generator(clk, enable, Q);
//	input clk, enable;
//	output [23:0] Q;
//	
//	reg [2:0] counter;
//	
//	always@(posedge clk)
//		if (enable)
//			counter = counter + 1'b0;
//	
//	assign Q = 24'd0;
//endmodule

