	component audio is
		port (
			clk_clk            : in    std_logic                     := 'X';             -- clk
			reset_reset_n      : in    std_logic                     := 'X';             -- reset_n
			left_output_ready  : in    std_logic                     := 'X';             -- ready
			left_output_data   : out   std_logic_vector(15 downto 0);                    -- data
			left_output_valid  : out   std_logic;                                        -- valid
			right_output_ready : in    std_logic                     := 'X';             -- ready
			right_output_data  : out   std_logic_vector(15 downto 0);                    -- data
			right_output_valid : out   std_logic;                                        -- valid
			left_input_data    : in    std_logic_vector(15 downto 0) := (others => 'X'); -- data
			left_input_valid   : in    std_logic                     := 'X';             -- valid
			left_input_ready   : out   std_logic;                                        -- ready
			right_input_data   : in    std_logic_vector(15 downto 0) := (others => 'X'); -- data
			right_input_valid  : in    std_logic                     := 'X';             -- valid
			right_input_ready  : out   std_logic;                                        -- ready
			ext_ADCDAT         : in    std_logic                     := 'X';             -- ADCDAT
			ext_ADCLRCK        : in    std_logic                     := 'X';             -- ADCLRCK
			ext_BCLK           : in    std_logic                     := 'X';             -- BCLK
			ext_DACDAT         : out   std_logic;                                        -- DACDAT
			ext_DACLRCK        : in    std_logic                     := 'X';             -- DACLRCK
			ext_1_SDAT         : inout std_logic                     := 'X';             -- SDAT
			ext_1_SCLK         : out   std_logic                                         -- SCLK
		);
	end component audio;

	u0 : component audio
		port map (
			clk_clk            => CONNECTED_TO_clk_clk,            --          clk.clk
			reset_reset_n      => CONNECTED_TO_reset_reset_n,      --        reset.reset_n
			left_output_ready  => CONNECTED_TO_left_output_ready,  --  left_output.ready
			left_output_data   => CONNECTED_TO_left_output_data,   --             .data
			left_output_valid  => CONNECTED_TO_left_output_valid,  --             .valid
			right_output_ready => CONNECTED_TO_right_output_ready, -- right_output.ready
			right_output_data  => CONNECTED_TO_right_output_data,  --             .data
			right_output_valid => CONNECTED_TO_right_output_valid, --             .valid
			left_input_data    => CONNECTED_TO_left_input_data,    --   left_input.data
			left_input_valid   => CONNECTED_TO_left_input_valid,   --             .valid
			left_input_ready   => CONNECTED_TO_left_input_ready,   --             .ready
			right_input_data   => CONNECTED_TO_right_input_data,   --  right_input.data
			right_input_valid  => CONNECTED_TO_right_input_valid,  --             .valid
			right_input_ready  => CONNECTED_TO_right_input_ready,  --             .ready
			ext_ADCDAT         => CONNECTED_TO_ext_ADCDAT,         --          ext.ADCDAT
			ext_ADCLRCK        => CONNECTED_TO_ext_ADCLRCK,        --             .ADCLRCK
			ext_BCLK           => CONNECTED_TO_ext_BCLK,           --             .BCLK
			ext_DACDAT         => CONNECTED_TO_ext_DACDAT,         --             .DACDAT
			ext_DACLRCK        => CONNECTED_TO_ext_DACLRCK,        --             .DACLRCK
			ext_1_SDAT         => CONNECTED_TO_ext_1_SDAT,         --        ext_1.SDAT
			ext_1_SCLK         => CONNECTED_TO_ext_1_SCLK          --             .SCLK
		);
