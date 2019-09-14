module avalon_audio_interface (
	// Avalon Clock Input
	input logic CLK,
	
	// Avalon Reset Input
	input logic RESET,
	
	// Avalon-MM Slave Signals
	input  logic AVL_READ,					// Avalon-MM Read
	input  logic AVL_WRITE,					// Avalon-MM Write
	input  logic AVL_CS,						// Avalon-MM Chip Select
	input  logic [3:0]AVL_ADDR,					// Avalon-MM Address
	input  logic [31:0] AVL_WRITEDATA,	// Avalon-MM Write Data
	output logic [31:0] AVL_READDATA,	// Avalon-MM Read Data
	
	input logic AUD_BCLK,
	input logic AUD_ADCLRCK,
	input logic GPIO_DIN,
	input logic GPIO_DIN2,
	
	output logic [31:0] codec_left,
	output logic [31:0] codec_right
);

logic [31:0] left_data;
logic [31:0] right_data;
logic [31:0] avl_left_data;
logic [31:0] avl_right_data;

logic hold;

always_ff @ (posedge CLK)
begin

    if(RESET) 
	 begin
       avl_left_data <= 32'd0;
		 avl_right_data <= 32'd0;
    end 

	 else if (AVL_CS && AVL_WRITE)
		begin
			if (AVL_ADDR == 4'd0)
				begin
				avl_left_data = AVL_WRITEDATA;
				end
			else if (AVL_ADDR == 4'd1)
				begin
				avl_right_data = AVL_WRITEDATA;
				end
			else if (AVL_ADDR == 4'd2)
				begin
				hold = {1{AVL_WRITEDATA}};
				end
		end
end

	i2s_receive rx_L(
		.sck(AUD_BCLK),
		.ws(AUD_ADCLRCK),
		.sd(GPIO_DIN),
		.data_left(left_data),
		.data_right()
	);
	
	i2s_receive rx_R(
		.sck(AUD_BCLK),
		.ws(AUD_ADCLRCK),
		.sd(GPIO_DIN2),
		.data_left(),
		.data_right(right_data)
	);

always_comb
	begin
		  if (AVL_CS && AVL_READ)
		  begin
				if (AVL_ADDR == 4'd0)
					begin
					AVL_READDATA = left_data;
					end
				else if (AVL_ADDR == 4'd1)
					begin
					AVL_READDATA = right_data;
					end
				else if (AVL_ADDR == 4'd2)
					begin
					AVL_READDATA = {32{hold}};
					end
				else if (AVL_ADDR == 4'd3)
					begin
					AVL_READDATA = {32{AUD_BCLK}};
					end
				else if (AVL_ADDR == 4'd4)
					begin
					AVL_READDATA = {32{AUD_ADCLRCK}};
					end
				else
					AVL_READDATA = 32'd0;
		  end
		  else
				AVL_READDATA = 32'd0;
		  if(hold == 1'b1)
			  begin
			  codec_left = avl_left_data;
			  codec_right = avl_right_data;
			  end
		  else
			  begin
			  codec_left = left_data;
			  codec_right = right_data;
			  end
	end

endmodule
