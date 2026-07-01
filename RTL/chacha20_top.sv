// Top level du projet ChaCha20
module chacha20_top (
	input  logic         clock_i,
	input  logic         resetb_i,
	input  logic         start_i,
	input  logic         data_valid_i,
	input  logic [127:0] data_i,
	input  logic [255:0] key_i,
	input  logic [95:0]  nonce_i,
	output logic [127:0] cipher_o,
	output logic         cipher_valid_o,
	output logic         end_o
);

	// signaux internes vers la FSM et entre les blocs
	logic         enable_s;
	logic         init_s;
	logic [1:0]   controle_s;
	logic [1:0]   chunk_s;
	logic         cipher_valid_s;
	logic [3:0]   ronde_count_s;
	logic [511:0] keystream_s;
	logic [127:0] chunk_keystream_s;
	logic [127:0] cipher_calc_s;
	logic [127:0] cipher_reg_s;

	// FSM Moore
	chacha20_fsm_moore FSM (
		.clock_i        (clock_i),
		.resetb_i       (resetb_i),
		.start_i        (start_i),
		.data_valid_i   (data_valid_i),
		.ronde_count_i  (ronde_count_s),
		.enable_o       (enable_s),
		.init_o         (init_s),
		.controle_o     (controle_s),
		.chunk_o        (chunk_s),
		.end_o          (end_o),
		.cipher_valid_o (cipher_valid_s)
	);

	// compteur des 10 doubles rondes
	round_counter CNT (
		.clock_i  (clock_i),
		.resetb_i (resetb_i),
		.init_i   (init_s),
		.enable_i (enable_s),
		.count_o  (ronde_count_s)
	);

	// bloc principal (rondes + calcul du keystream)
	chacha20_block BLK (
		.clock_i     (clock_i),
		.resetb_i    (resetb_i),
		.key_i       (key_i),
		.nonce_i     (nonce_i),
		.init_i      (init_s),
		.controle_i  (controle_s),
		.keystream_o (keystream_s)
	);

	// selection du chunk de keystream (128 bits) selon le bloc en cours
	always_comb begin
		case (chunk_s)
			2'd0    : chunk_keystream_s = keystream_s[127:0];
			2'd1    : chunk_keystream_s = keystream_s[255:128];
			2'd2    : chunk_keystream_s = keystream_s[383:256];
			default : chunk_keystream_s = 128'd0;
		endcase
	end

	// XOR de chiffrement : actif uniquement quand controle = 11
	always_comb begin
		if (controle_s == 2'b11)
			cipher_calc_s = data_i ^ chunk_keystream_s;
		else
			cipher_calc_s = 128'd0;
	end

	// registre de memorisation de cipher_o
	always_ff @(posedge clock_i or negedge resetb_i) begin
		if (resetb_i == 1'b0)
			cipher_reg_s <= 128'd0;
		else if (cipher_valid_s == 1'b1)
			cipher_reg_s <= cipher_calc_s;
	end

	assign cipher_o       = cipher_reg_s;
	assign cipher_valid_o = cipher_valid_s;

endmodule : chacha20_top
