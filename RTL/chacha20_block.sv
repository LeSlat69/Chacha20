import package_matrice::*;

// Bloc principal de ChaCha20 :
//  - registre d'etat 4x4
//  - calcul d'une double ronde par cycle
//  - calcul du keystream final
// Le keystream est sorti sur 512 bits ; le mux de chunk et le XOR
// de chiffrement sont realises dans chacha20_top.
module chacha20_block (
	input  logic         clock_i,
	input  logic         resetb_i,
	input  logic [255:0] key_i,
	input  logic [95:0]  nonce_i,
	input  logic         init_i,        // chargement etat initial
	input  logic [1:0]   controle_i,    // 00=NOP, 01=KEEP, 10=ROUND
	output logic [511:0] keystream_o
);

	// constantes ChaCha20 (premiere ligne de la matrice)
	localparam logic [31:0] C0 = 32'h61707865;
	localparam logic [31:0] C1 = 32'h3320646e;
	localparam logic [31:0] C2 = 32'h79622d32;
	localparam logic [31:0] C3 = 32'h6b206574;

	// compteur de bloc impose par le sujet
	localparam logic [31:0] BLOCK_INIT = 32'h00000001;

	// matrices d'etat
	mat matrice_s;
	mat matrice_init_s;
	mat matrice_after_ronde_s;

	// une double ronde combinatoire
	Ronde DUT (
		.S_i (matrice_s),
		.S_o (matrice_after_ronde_s)
	);

	// registre d'etat : init / mise a jour / maintien
	always_ff @(posedge clock_i or negedge resetb_i) begin
		if (resetb_i == 1'b0) begin
			// reset de la matrice courante
			matrice_s[0][0] <= 32'd0; matrice_s[0][1] <= 32'd0;
			matrice_s[0][2] <= 32'd0; matrice_s[0][3] <= 32'd0;
			matrice_s[1][0] <= 32'd0; matrice_s[1][1] <= 32'd0;
			matrice_s[1][2] <= 32'd0; matrice_s[1][3] <= 32'd0;
			matrice_s[2][0] <= 32'd0; matrice_s[2][1] <= 32'd0;
			matrice_s[2][2] <= 32'd0; matrice_s[2][3] <= 32'd0;
			matrice_s[3][0] <= 32'd0; matrice_s[3][1] <= 32'd0;
			matrice_s[3][2] <= 32'd0; matrice_s[3][3] <= 32'd0;

			// reset de la matrice initiale memorisee
			matrice_init_s[0][0] <= 32'd0; matrice_init_s[0][1] <= 32'd0;
			matrice_init_s[0][2] <= 32'd0; matrice_init_s[0][3] <= 32'd0;
			matrice_init_s[1][0] <= 32'd0; matrice_init_s[1][1] <= 32'd0;
			matrice_init_s[1][2] <= 32'd0; matrice_init_s[1][3] <= 32'd0;
			matrice_init_s[2][0] <= 32'd0; matrice_init_s[2][1] <= 32'd0;
			matrice_init_s[2][2] <= 32'd0; matrice_init_s[2][3] <= 32'd0;
			matrice_init_s[3][0] <= 32'd0; matrice_init_s[3][1] <= 32'd0;
			matrice_init_s[3][2] <= 32'd0; matrice_init_s[3][3] <= 32'd0;
		end
		else if (init_i == 1'b1) begin
			// chargement de l'etat initial (constante, cle, compteur, nonce)
			matrice_s[0][0] <= C0;
			matrice_s[0][1] <= C1;
			matrice_s[0][2] <= C2;
			matrice_s[0][3] <= C3;
			matrice_s[1][0] <= key_i[31:0];
			matrice_s[1][1] <= key_i[63:32];
			matrice_s[1][2] <= key_i[95:64];
			matrice_s[1][3] <= key_i[127:96];
			matrice_s[2][0] <= key_i[159:128];
			matrice_s[2][1] <= key_i[191:160];
			matrice_s[2][2] <= key_i[223:192];
			matrice_s[2][3] <= key_i[255:224];
			matrice_s[3][0] <= BLOCK_INIT;
			matrice_s[3][1] <= nonce_i[31:0];
			matrice_s[3][2] <= nonce_i[63:32];
			matrice_s[3][3] <= nonce_i[95:64];

			// on memorise aussi l'etat initial pour l'addition finale
			matrice_init_s[0][0] <= C0;
			matrice_init_s[0][1] <= C1;
			matrice_init_s[0][2] <= C2;
			matrice_init_s[0][3] <= C3;
			matrice_init_s[1][0] <= key_i[31:0];
			matrice_init_s[1][1] <= key_i[63:32];
			matrice_init_s[1][2] <= key_i[95:64];
			matrice_init_s[1][3] <= key_i[127:96];
			matrice_init_s[2][0] <= key_i[159:128];
			matrice_init_s[2][1] <= key_i[191:160];
			matrice_init_s[2][2] <= key_i[223:192];
			matrice_init_s[2][3] <= key_i[255:224];
			matrice_init_s[3][0] <= BLOCK_INIT;
			matrice_init_s[3][1] <= nonce_i[31:0];
			matrice_init_s[3][2] <= nonce_i[63:32];
			matrice_init_s[3][3] <= nonce_i[95:64];
		end
		else if (controle_i == 2'b10) begin
			// mise a jour avec la sortie de la double ronde
			matrice_s <= matrice_after_ronde_s;
		end
	end

	// keystream = matrice + matrice_init mot a mot (modulo 2^32)
	always_comb begin
		keystream_o[ 31:  0] = matrice_s[0][0] + matrice_init_s[0][0];
		keystream_o[ 63: 32] = matrice_s[0][1] + matrice_init_s[0][1];
		keystream_o[ 95: 64] = matrice_s[0][2] + matrice_init_s[0][2];
		keystream_o[127: 96] = matrice_s[0][3] + matrice_init_s[0][3];
		keystream_o[159:128] = matrice_s[1][0] + matrice_init_s[1][0];
		keystream_o[191:160] = matrice_s[1][1] + matrice_init_s[1][1];
		keystream_o[223:192] = matrice_s[1][2] + matrice_init_s[1][2];
		keystream_o[255:224] = matrice_s[1][3] + matrice_init_s[1][3];
		keystream_o[287:256] = matrice_s[2][0] + matrice_init_s[2][0];
		keystream_o[319:288] = matrice_s[2][1] + matrice_init_s[2][1];
		keystream_o[351:320] = matrice_s[2][2] + matrice_init_s[2][2];
		keystream_o[383:352] = matrice_s[2][3] + matrice_init_s[2][3];
		keystream_o[415:384] = matrice_s[3][0] + matrice_init_s[3][0];
		keystream_o[447:416] = matrice_s[3][1] + matrice_init_s[3][1];
		keystream_o[479:448] = matrice_s[3][2] + matrice_init_s[3][2];
		keystream_o[511:480] = matrice_s[3][3] + matrice_init_s[3][3];
	end

endmodule : chacha20_block
