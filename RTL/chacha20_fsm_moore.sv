import package_state::*;

// FSM_Moore qui pilote l'algorithme ChaCha20
module chacha20_fsm_moore (
	input  logic       clock_i,
	input  logic       resetb_i,
	input  logic       start_i,
	input  logic       data_valid_i,
	input  logic [3:0] ronde_count_i,

	output logic       enable_o,
	output logic       init_o,
	output logic [1:0] controle_o,
	output logic [1:0] chunk_o,
	output logic       end_o,
	output logic       cipher_valid_o
);

	state_t current_state_s, next_state_s;

	// compteur de chunks (0..2) integre a la FSM
	logic [1:0] chunk_cnt_s;

	// processus sequentiel : registre d'etat + compteur de chunks
	always_ff @(posedge clock_i or negedge resetb_i) begin : seq_1
		if (resetb_i == 1'b0) begin
			current_state_s <= Idle;
			chunk_cnt_s     <= 2'd0;
		end
		else begin
			current_state_s <= next_state_s;

			// RAZ du compteur quand on revient sur Idle ou en Init
			if (current_state_s == Init)
				chunk_cnt_s <= 2'd0;
			// increment apres chaque XOR
			else if (current_state_s == Xor)
				chunk_cnt_s <= chunk_cnt_s + 2'd1;
		end
	end : seq_1

	// processus combinatoire : transitions
	always_comb begin : comb_1
		case (current_state_s)
			Idle :
				if (start_i == 1'b1) next_state_s = Init;
				else                 next_state_s = Idle;

			Init : next_state_s = Ronde;

			Ronde :
				if (ronde_count_i == 4'd9) next_state_s = End_Calcul;
				else                       next_state_s = Ronde;

			End_Calcul : next_state_s = Wait_Data;

			Wait_Data :
				if (data_valid_i == 1'b1) next_state_s = Xor;
				else                      next_state_s = Wait_Data;

			Xor :
				if (chunk_cnt_s == 2'd2) next_state_s = Idle;
				else                     next_state_s = Wait_Data;

			default : next_state_s = Idle;
		endcase
	end : comb_1

	// processus combinatoire : sorties 
	always_comb begin : comb_2
		// valeurs par defaut pour eviter les latches
		enable_o       = 1'b0;
		init_o         = 1'b0;
		controle_o     = 2'b00;
		end_o          = 1'b0;
		cipher_valid_o = 1'b0;

		case (current_state_s)
			Idle       : begin
				// rien a faire, attente
			end
			Init       : begin
				enable_o = 1'b1;
				init_o   = 1'b1;
			end
			Ronde      : begin
				enable_o   = 1'b1;
				controle_o = 2'b10;   // mise a jour de la matrice
			end
			End_Calcul : begin
				end_o      = 1'b1;
				controle_o = 2'b01;
			end
			Wait_Data  : begin
				controle_o = 2'b01;
			end
			Xor        : begin
				controle_o     = 2'b11;
				cipher_valid_o = 1'b1;
			end
			default    : begin
				// valeurs par defaut deja affectees
			end
		endcase
	end : comb_2

	// le numero de chunk en cours est expose au top
	assign chunk_o = chunk_cnt_s;

endmodule : chacha20_fsm_moore
