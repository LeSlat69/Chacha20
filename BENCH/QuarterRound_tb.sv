`timescale 1ns/1ps

// Testbench du QuarterRound avec le vecteur du sujet
module QuarterRound_tb ();

	logic [31:0] a_s, b_s, c_s, d_s;
	logic [31:0] a_o, b_o, c_o, d_o;

	QuarterRound DUT (
		.a_i (a_s), .b_i (b_s), .c_i (c_s), .d_i (d_s),
		.a_o (a_o), .b_o (b_o), .c_o (c_o), .d_o (d_o)
	);

	initial begin
		// vecteur du sujet section 3.3.2
		a_s = 32'h11111111;
		b_s = 32'h01020304;
		c_s = 32'h9b8d6f43;
		d_s = 32'h01234567;
		#10;

		if (a_o == 32'hea2a92f4) $display("a ok");
		else                     $display("a faux");
		if (b_o == 32'hcb1cf8ce) $display("b ok");
		else                     $display("b faux");
		if (c_o == 32'h4581472e) $display("c ok");
		else                     $display("c faux");
		if (d_o == 32'h5881c4bb) $display("d ok");
		else                     $display("d faux");

		$finish;
	end

endmodule : QuarterRound_tb
