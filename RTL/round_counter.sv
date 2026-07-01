// Compteur de rondes (modele du sujet)
// compte les 10 doubles rondes (20 rondes au total)
module round_counter (
	input  logic       clock_i,
	input  logic       resetb_i,
	input  logic       init_i,
	input  logic       enable_i,
	output logic [3:0] count_o
);

	always_ff @(posedge clock_i, negedge resetb_i) begin : counter_seq
		if (resetb_i == 1'b0) begin
			count_o <= 0;
		end
		else begin
			if (enable_i == 1'b1) begin
				if (init_i == 1'b1)
					count_o <= 0;
				else
					count_o <= count_o + 1;
			end
		end
	end : counter_seq // always_ff @ (posedge clock_i, negedge resetb_i)

endmodule : round_counter
