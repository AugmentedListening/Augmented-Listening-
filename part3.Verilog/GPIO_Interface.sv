module GPIO_Interface 
(input	 logic GPIO,
output logic [6:0]  G0_Hex);
	
logic[3:0]  data;

always_comb
	begin
		unique case (GPIO)
	 	   1'b0   : data = 4'b0000;
	 	   1'b1   : data = 4'b0001;
			default: data = 4'b1111;
        endcase
	end

HexDriver G0 (.In0(data[3:0]), .Out0(G0_hex));


endmodule