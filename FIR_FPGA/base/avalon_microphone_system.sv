module avalon_microphone_system (
	// Avalon Clock Input
	input logic CLK,
	
	// Avalon Reset Input
	input logic RESET,

	// Avalon-MM Master signals
	output logic [31:0] AM_ADDR,
	output logic [2:0]	AM_BURSTCOUNT,
	output logic		AM_WRITE,
	output logic [31:0] AM_WRITEDATA,
	output logic [3:0]	AM_BYTEENABLE,
	input logic			AM_WAITREQUEST,
	
	// Avalon-MM Slave Signals
	input  logic AVL_READ,					// Avalon-MM Read
	input  logic AVL_WRITE,					// Avalon-MM Write
	input  logic AVL_CS,						// Avalon-MM Chip Select
	input  logic [1:0] AVL_ADDR,					// Avalon-MM Address
	input  logic [31:0] AVL_WRITEDATA,	// Avalon-MM Write Data
	output logic [31:0] AVL_READDATA,	// Avalon-MM Read Data
	
	// Clock signals
	input logic AUD_BCLK,
	input logic AUD_ADCLRCK,

	// Data lines from mics
	input logic GPIO_DIN1,
	input logic GPIO_DIN2,

	// Start button signal
	input logic KEY,

	// Output to codec
	output logic [31:0] codec_stream
);

logic saw_rise, saw_fall;
logic start;
logic ready_read_now;
logic junk1;
//assign ready_read_now = (saw_rise) | (saw_fall);

logic [2:0] counter;
//////////////////////////////////////////////////
initial begin
	counter = 0;
end

always_ff @ (posedge CLK)
begin
	if (saw_rise)
	begin
		counter <= counter + 3'b1;
	end
	else if (saw_fall)
	begin
		counter <= counter + 3'b1;
	end
	
	if (counter == 3)
	begin
		counter <= 3'b1;
		ready_read_now <= 1'b1;
	end
	else
	begin
		ready_read_now <= 1'b0;
	end
end
//////////////////////////////////////////////////
logic fin_signal;
logic [1:0] mic_sel;
logic stream_control;


logic [31:0] start_addr, num_samps;

assign stream_control = !start;

initial begin
	start = 0;
end

always_ff @ (posedge CLK)
begin
	if (KEY)
	begin
		start <= 1'b1;
	end
	else
	begin
		start <= 1'b0;
	end
end


initial begin
	AVL_READDATA = 0;
end

mic_dma dma_yo(
	.CLK(CLK),
	.RESET(RESET),
	.AM_ADDR(AM_ADDR),
	.AM_BURSTCOUNT(AM_BURSTCOUNT),
	.AM_WRITE(AM_WRITE),
	.AM_WRITEDATA(AM_WRITEDATA),
	.AM_BYTEENABLE(AM_BYTEENABLE),
	.AM_WAITREQUEST(AM_WAITREQUEST),
	.mic_data(ready_data_choice),
	.select(mic_sel),
	.start(start),
	.read_ready(ready_read_now),
	.start_address(32'hDEADBEEF),
	.number_samples(32'd10),
	.FINISHED(fin_signal)
);

altera_up_clock_edge detect(
	.clk(CLK),
	.reset(RESET),
	.test_clk(AUD_ADCLRCK),
	.rising_edge(saw_rise),
	.falling_edge(saw_fall),
);

logic [15:0] mic_l, mic_r, mic_l2, mic_r2;
logic [31:0] ready_data_1, ready_data_2, ready_data_choice;

always_comb 
begin
	if (mic_sel == 2'd2)
	begin
		ready_data_choice <= ready_data_1;
	end
	else
	begin
		ready_data_choice <= ready_data_2;
	end
end

always_ff @ (posedge CLK)
begin
	if (saw_fall)
	begin
		ready_data_1 <= {mic_l, ready_data_1[15:0]};
		ready_data_2 <= {mic_l2, ready_data_2[15:0]};
	end
	else if (saw_rise)
	begin
		ready_data_1 <= {ready_data_1[31:16], mic_r};
		ready_data_2 <= {ready_data_2[31:16], mic_r2};
	end
end


//hps to fpga

always_comb
	begin
	if(stream_control)
		begin
		codec_stream = ready_data_2;
		end
	else
		begin
		codec_stream = 32'd0;
		end
	end
	
always_ff @ (posedge CLK)
begin
    if(RESET) 
	begin
		junk1 <= 1'b0;
		start_addr <= 1'b0;
		num_samps <= 1'b0;
	end 
	else if (AVL_CS && AVL_WRITE)
	begin
		if (AVL_ADDR == 2'd0)
		begin
			junk1 <= AVL_WRITEDATA[0];
		end
		else if (AVL_ADDR == 2'd1)
		begin
			start_addr <= AVL_WRITEDATA;
		end
		else if (AVL_ADDR == 2'd2)
		begin
			num_samps = AVL_WRITEDATA;
		end
	end
end

i2s_master m1(
	.sck(AUD_BCLK),
	.ws(AUD_ADCLRCK),
	.sd(GPIO_DIN1),
	.data_left(mic_l),
	.data_right(mic_r)
);

i2s_master m2(
	.sck(AUD_BCLK),
	.ws(AUD_ADCLRCK),
	.sd(GPIO_DIN2),
	.data_left(mic_l2),
	.data_right(mic_r2)
);

always_comb
	begin
		  if (AVL_CS && AVL_READ)
		  begin
				if (AVL_ADDR == 2'd0)
					begin
					AVL_READDATA = {30'd0,saw_rise,saw_fall};
					end
				else if (AVL_ADDR == 2'd1)
					begin
					AVL_READDATA = {mic_l, mic_r};
					end
				else if (AVL_ADDR == 2'd2)
					begin
					AVL_READDATA = {31'd0, fin_signal};
					end
				else
					begin
					AVL_READDATA = 32'b0;
					end
		  end
		  else
		  begin
				AVL_READDATA = 32'b0;
		  end
	end	
endmodule
