`timescale 1ns/1ps

// Testbench du top level avec le vecteur du sujet (section 5)
module chacha20_top_tb ();

	logic         clock_s;
	logic         resetb_s;
	logic         start_s;
	logic         data_valid_s;
	logic [127:0] data_s;
	logic [255:0] key_s;
	logic [95:0]  nonce_s;
	logic [127:0] cipher_s;
	logic         cipher_valid_s;
	logic         end_s;

	chacha20_top DUT (
		.clock_i        (clock_s),
		.resetb_i       (resetb_s),
		.start_i        (start_s),
		.data_valid_i   (data_valid_s),
		.data_i         (data_s),
		.key_i          (key_s),
		.nonce_i        (nonce_s),
		.cipher_o       (cipher_s),
		.cipher_valid_o (cipher_valid_s),
		.end_o          (end_s)
	);

	// blocs de texte clair et resultats attendus du sujet
	localparam logic [127:0] P1 = 128'h65704f20656966696e67697320657551;
	localparam logic [127:0] P2 = 128'h65766e49206561727574614e20617472;
	localparam logic [127:0] P3 = 128'h00003f206172656e754d20746e75696e;
	localparam logic [127:0] C1 = 128'h322523b73ceabe5e8e05fc68143022e0;
	localparam logic [127:0] C2 = 128'he46c5ee17a42f515954acdecd4eeef62;
	localparam logic [127:0] C3 = 128'h2cc9fab0b90f73406abbf0408580ba3e;

	// horloge 100 MHz
	initial begin
		clock_s = 1'b0;
		forever #5 clock_s = ~clock_s;
	end

	// scenario de test
	initial begin
		resetb_s     = 1'b0;
		start_s      = 1'b0;
		data_valid_s = 1'b0;
		data_s       = 128'd0;
		key_s        = 256'h4e7ced7e860e69aed3a53fefd52a3eec27a09386322fdc9a76a2b5eae921c73a;
		nonce_s      = 96'hd4ac91b9caccf25906e46ce3;

		#23 resetb_s = 1'b1;

		// impulsion start
		#10 start_s = 1'b1;
		#10 start_s = 1'b0;

		// on attend la fin du calcul du keystream
		wait (end_s == 1'b1);

		@(posedge clock_s);

		// bloc 1 : on envoie data_valid pendant Wait_Data.
		// data_i doit rester stable pendant l'etat Xor (calcul du XOR),
		// on ne le remet a zero qu'apres avoir memorise le resultat.
		data_s       = P1;
		data_valid_s = 1'b1;
		@(posedge clock_s);          // -> etat Xor
		data_valid_s = 1'b0;
		@(posedge clock_s); #1;      // resultat memorise dans le registre
		if (cipher_s == C1) $display("bloc 1 ok");
		else                $display("bloc 1 faux");
		data_s = 128'd0;

		// bloc 2
		@(posedge clock_s);
		data_s       = P2;
		data_valid_s = 1'b1;
		@(posedge clock_s);          // -> etat Xor
		data_valid_s = 1'b0;
		@(posedge clock_s); #1;
		if (cipher_s == C2) $display("bloc 2 ok");
		else                $display("bloc 2 faux");
		data_s = 128'd0;

		// bloc 3
		@(posedge clock_s);
		data_s       = P3;
		data_valid_s = 1'b1;
		@(posedge clock_s);          // -> etat Xor
		data_valid_s = 1'b0;
		@(posedge clock_s); #1;
		if (cipher_s == C3) $display("bloc 3 ok");
		else                $display("bloc 3 faux");
		data_s = 128'd0;

		#50;
		$finish;
	end

endmodule : chacha20_top_tb
