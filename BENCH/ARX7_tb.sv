`timescale 1ns/1ps

// Testbench du module ARX7 avec les vecteurs du sujet
module ARX7_tb ();

	logic [31:0] augend_s, addend_s, b_s;
	logic [31:0] sum_s, shift_s;

	ARX7 DUT (
		.augend_i (augend_s),
		.addend_i (addend_s),
		.b_i      (b_s),
		.sum_o    (sum_s),
		.shift_o  (shift_s)
	);

	initial begin
		// vecteur 1 du sujet
		augend_s = 32'h01234567;
		addend_s = 32'h77777777;
		b_s      = 32'h01020304;
		#10;
		if (sum_s == 32'h789abcde)   $display("V1 sum ok");
		else                         $display("V1 sum faux");
		if (shift_s == 32'hcc5fed3c) $display("V1 rot ok");
		else                         $display("V1 rot faux");

		// vecteur 2 du sujet
		augend_s = 32'hF2E1A126;
		addend_s = 32'h2B3E4456;
		b_s      = 32'h12B7F568;
		#10;
		if (sum_s == 32'h1E1FE57C)   $display("V2 sum ok");
		else                         $display("V2 sum faux");
		if (shift_s == 32'h54080A06) $display("V2 rot ok");
		else                         $display("V2 rot faux");

		$finish;
	end

endmodule : ARX7_tb
