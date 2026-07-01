`timescale 1ns/1ps

// Testbench du module chacha20_block.
// On pilote a la main les signaux de controle (normalement c'est la FSM
// qui le fait) pour derouler l'initialisation puis les 20 rondes.
// On verifie ensuite le keystream et le chiffrement du bloc 1.
module chacha20_block_tb ();

	logic         clock_s;
	logic         resetb_s;
	logic [255:0] key_s;
	logic [95:0]  nonce_s;
	logic         init_s;
	logic [1:0]   controle_s;
	logic [511:0] keystream_s;

	chacha20_block DUT (
		.clock_i     (clock_s),
		.resetb_i    (resetb_s),
		.key_i       (key_s),
		.nonce_i     (nonce_s),
		.init_i      (init_s),
		.controle_i  (controle_s),
		.keystream_o (keystream_s)
	);

	// bloc clair et resultat attendu (1er bloc du sujet)
	localparam logic [127:0] P1 = 128'h65704f20656966696e67697320657551;
	localparam logic [127:0] C1 = 128'h322523b73ceabe5e8e05fc68143022e0;

	// le chiffre se calcule ici : P1 XOR chunk 0 du keystream
	logic [127:0] cipher_s;
	assign cipher_s = P1 ^ keystream_s[127:0];

	// horloge 100 MHz
	initial begin
		clock_s = 1'b0;
		forever #5 clock_s = ~clock_s;
	end

	// scenario de test
	initial begin
		// reset
		resetb_s   = 1'b0;
		init_s     = 1'b0;
		controle_s = 2'b00;
		key_s      = 256'h4e7ced7e860e69aed3a53fefd52a3eec27a09386322fdc9a76a2b5eae921c73a;
		nonce_s    = 96'hd4ac91b9caccf25906e46ce3;
		#23 resetb_s = 1'b1;

		// chargement de l'etat initial (1 cycle avec init = 1)
		@(posedge clock_s);
		init_s = 1'b1;
		@(posedge clock_s);
		init_s = 1'b0;

		// 10 doubles rondes : controle = 10 pendant 10 cycles
		controle_s = 2'b10;
		for (int k = 0; k < 10; k = k + 1) begin
			@(posedge clock_s);
		end
		controle_s = 2'b01;   // fin des rondes, on fige l'etat
		#1;

		// on verifie le chiffrement du bloc 1
		if (cipher_s == C1) $display("block ok");
		else                $display("block faux");

		#20;
		$finish;
	end

endmodule : chacha20_block_tb
