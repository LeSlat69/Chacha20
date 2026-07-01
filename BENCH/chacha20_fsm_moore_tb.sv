`timescale 1ns/1ps

import package_state::*;

// Testbench de la FSM Moore de ChaCha20
module chacha20_fsm_moore_tb ();

	logic       clock_s;
	logic       resetb_s;
	logic       start_s;
	logic       data_valid_s;
	logic [3:0] ronde_count_s;

	logic       enable_s;
	logic       init_s;
	logic [1:0] controle_s;
	logic [1:0] chunk_s;
	logic       end_s;
	logic       cipher_valid_s;

	chacha20_fsm_moore DUT (
		.clock_i        (clock_s),
		.resetb_i       (resetb_s),
		.start_i        (start_s),
		.data_valid_i   (data_valid_s),
		.ronde_count_i  (ronde_count_s),
		.enable_o       (enable_s),
		.init_o         (init_s),
		.controle_o     (controle_s),
		.chunk_o        (chunk_s),
		.end_o          (end_s),
		.cipher_valid_o (cipher_valid_s)
	);

	// horloge 100 MHz
	initial begin
		clock_s = 1'b0;
		forever #5 clock_s = ~clock_s;
	end

	// scenario de test
	initial begin
		// reset
		resetb_s      = 1'b0;
		start_s       = 1'b0;
		data_valid_s  = 1'b0;
		ronde_count_s = 4'd0;
		#23 resetb_s  = 1'b1;

		// on doit etre en Idle, init et controle a 0
		@(posedge clock_s); #1;
		if (init_s == 1'b0 && controle_s == 2'b00) $display("etat Idle ok");
		else                                       $display("etat Idle faux");

		// on lance le calcul
		start_s = 1'b1;
		@(posedge clock_s); #1;
		start_s = 1'b0;

		// etat Init : init doit etre a 1
		if (init_s == 1'b1) $display("etat Init ok");
		else                $display("etat Init faux");

		// on simule les 10 rondes en faisant avancer le compteur
		for (int k = 0; k < 9; k = k + 1) begin
			@(posedge clock_s); #1;
			ronde_count_s = k[3:0];
		end
		// pendant les rondes controle doit valoir 10
		if (controle_s == 2'b10) $display("etat Ronde ok");
		else                     $display("etat Ronde faux");

		// derniere ronde : compteur a 9
		@(posedge clock_s); #1;
		ronde_count_s = 4'd9;

		// etat End_Calcul : end doit passer a 1
		@(posedge clock_s); #1;
		if (end_s == 1'b1) $display("etat End_Calcul ok");
		else               $display("etat End_Calcul faux");

		// etat Wait_Data
		@(posedge clock_s); #1;
		if (controle_s == 2'b01) $display("etat Wait_Data ok");
		else                     $display("etat Wait_Data faux");

		// bloc 1 : on envoie data_valid
		data_valid_s = 1'b1;
		@(posedge clock_s); #1;
		data_valid_s = 1'b0;
		if (cipher_valid_s == 1'b1) $display("etat Xor bloc 1 ok");
		else                        $display("etat Xor bloc 1 faux");

		// bloc 2
		@(posedge clock_s); #1;
		data_valid_s = 1'b1;
		@(posedge clock_s); #1;
		data_valid_s = 1'b0;
		if (cipher_valid_s == 1'b1) $display("etat Xor bloc 2 ok");
		else                        $display("etat Xor bloc 2 faux");

		// bloc 3
		@(posedge clock_s); #1;
		data_valid_s = 1'b1;
		@(posedge clock_s); #1;
		data_valid_s = 1'b0;
		if (cipher_valid_s == 1'b1) $display("etat Xor bloc 3 ok");
		else                        $display("etat Xor bloc 3 faux");

		// apres le bloc 3 on doit revenir a Idle
		@(posedge clock_s); #1;
		if (controle_s == 2'b00) $display("retour Idle ok");
		else                     $display("retour Idle faux");

		$finish;
	end

endmodule : chacha20_fsm_moore_tb
