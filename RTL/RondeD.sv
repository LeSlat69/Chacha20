import package_matrice::*;

// Ronde en diagonale : 4 QuarterRound sur les diagonales de la matrice
module RondeD (
	input  mat S_i,
	output mat S_o
);

	// QR sur les indices 0, 5, 10, 15
	QuarterRound qr1 (
		.a_i (S_i[0][0]), .b_i (S_i[1][1]), .c_i (S_i[2][2]), .d_i (S_i[3][3]),
		.a_o (S_o[0][0]), .b_o (S_o[1][1]), .c_o (S_o[2][2]), .d_o (S_o[3][3])
	);

	// QR sur les indices 1, 6, 11, 12
	QuarterRound qr2 (
		.a_i (S_i[0][1]), .b_i (S_i[1][2]), .c_i (S_i[2][3]), .d_i (S_i[3][0]),
		.a_o (S_o[0][1]), .b_o (S_o[1][2]), .c_o (S_o[2][3]), .d_o (S_o[3][0])
	);

	// QR sur les indices 2, 7, 8, 13
	QuarterRound qr3 (
		.a_i (S_i[0][2]), .b_i (S_i[1][3]), .c_i (S_i[2][0]), .d_i (S_i[3][1]),
		.a_o (S_o[0][2]), .b_o (S_o[1][3]), .c_o (S_o[2][0]), .d_o (S_o[3][1])
	);

	// QR sur les indices 3, 4, 9, 14
	QuarterRound qr4 (
		.a_i (S_i[0][3]), .b_i (S_i[1][0]), .c_i (S_i[2][1]), .d_i (S_i[3][2]),
		.a_o (S_o[0][3]), .b_o (S_o[1][0]), .c_o (S_o[2][1]), .d_o (S_o[3][2])
	);

endmodule : RondeD
