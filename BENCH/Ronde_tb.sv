`timescale 1ns/1ps

import package_matrice::*;

// Testbench du module Ronde (une double ronde : colonne + diagonale)
// On utilise le bloc initial du sujet et on verifie le resultat
// apres la premiere double ronde (Ronde #0 du tableau de validation).
module Ronde_tb ();

	mat S_s;
	mat S_o;

	Ronde DUT (
		.S_i (S_s),
		.S_o (S_o)
	);

	// flag pour savoir si une erreur a ete trouvee
	logic erreur;

	initial begin
		// bloc initial #1 du sujet
		S_s[0][0] = 32'h61707865; S_s[0][1] = 32'h3320646e;
		S_s[0][2] = 32'h79622d32; S_s[0][3] = 32'h6b206574;
		S_s[1][0] = 32'he921c73a; S_s[1][1] = 32'h76a2b5ea;
		S_s[1][2] = 32'h322fdc9a; S_s[1][3] = 32'h27a09386;
		S_s[2][0] = 32'hd52a3eec; S_s[2][1] = 32'hd3a53fef;
		S_s[2][2] = 32'h860e69ae; S_s[2][3] = 32'h4e7ced7e;
		S_s[3][0] = 32'h00000001; S_s[3][1] = 32'h06e46ce3;
		S_s[3][2] = 32'hcaccf259; S_s[3][3] = 32'hd4ac91b9;

		#10;

		// resultat attendu apres une double ronde (Ronde #0 du sujet)
		erreur = 1'b0;
		if (S_o[0][0] != 32'hf2727b43) erreur = 1'b1;
		if (S_o[0][1] != 32'h23674194) erreur = 1'b1;
		if (S_o[0][2] != 32'h9101a987) erreur = 1'b1;
		if (S_o[0][3] != 32'h4a122fca) erreur = 1'b1;
		if (S_o[1][0] != 32'hbde92772) erreur = 1'b1;
		if (S_o[1][1] != 32'h32310bf7) erreur = 1'b1;
		if (S_o[1][2] != 32'h0e69d273) erreur = 1'b1;
		if (S_o[1][3] != 32'hb1183542) erreur = 1'b1;
		if (S_o[2][0] != 32'h87a37782) erreur = 1'b1;
		if (S_o[2][1] != 32'h1d54ffd8) erreur = 1'b1;
		if (S_o[2][2] != 32'h3d87083c) erreur = 1'b1;
		if (S_o[2][3] != 32'h1551c5a5) erreur = 1'b1;
		if (S_o[3][0] != 32'h14994be7) erreur = 1'b1;
		if (S_o[3][1] != 32'h27eeb6f3) erreur = 1'b1;
		if (S_o[3][2] != 32'hb0e03d12) erreur = 1'b1;
		if (S_o[3][3] != 32'h9fe1488f) erreur = 1'b1;

		if (erreur == 1'b0) $display("Ronde ok");
		else                $display("Ronde faux");

		$finish;
	end

endmodule : Ronde_tb
