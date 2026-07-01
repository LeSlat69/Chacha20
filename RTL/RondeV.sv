import package_matrice::*;

// Ronde en colonne : 4 QuarterRound sur les colonnes de la matrice
module RondeV (
	input  mat S_i,
	output mat S_o
);

	genvar k;

	// un QuarterRound par colonne k = 0..3
	generate
		for (k = 0; k < 4; k = k + 1) begin : g_col
			QuarterRound qr (
				.a_i (S_i[0][k]),
				.b_i (S_i[1][k]),
				.c_i (S_i[2][k]),
				.d_i (S_i[3][k]),
				.a_o (S_o[0][k]),
				.b_o (S_o[1][k]),
				.c_o (S_o[2][k]),
				.d_o (S_o[3][k])
			);
		end : g_col
	endgenerate

endmodule : RondeV
