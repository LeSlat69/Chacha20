import package_matrice::*;

// Une double ronde : ronde colonne suivie d'une ronde diagonale
module Ronde (
	input  mat S_i,
	output mat S_o
);

	// etat intermediaire entre les deux rondes
	mat S_s;

	RondeV rv (
		.S_i (S_i),
		.S_o (S_s)
	);

	RondeD rd (
		.S_i (S_s),
		.S_o (S_o)
	);

endmodule : Ronde
