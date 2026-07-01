// Quart de ronde de ChaCha20 : 4 etages ARX en cascade
module QuarterRound (
	input  logic [31:0] a_i,
	input  logic [31:0] b_i,
	input  logic [31:0] c_i,
	input  logic [31:0] d_i,
	output logic [31:0] a_o,
	output logic [31:0] b_o,
	output logic [31:0] c_o,
	output logic [31:0] d_o
);

	// signaux intermediaires entre les etages
	logic [31:0] a_s;
	logic [31:0] b_s;
	logic [31:0] c_s;
	logic [31:0] d_s;

	// etage 1 : a = a+b ; d = (d^a) <<< 16
	ARX16 arx_16 (
		.augend_i (a_i),
		.addend_i (b_i),
		.b_i      (d_i),
		.sum_o    (a_s),
		.shift_o  (d_s)
	);

	// etage 2 : c = c+d ; b = (b^c) <<< 12
	ARX12 arx_12 (
		.augend_i (c_i),
		.addend_i (d_s),
		.b_i      (b_i),
		.sum_o    (c_s),
		.shift_o  (b_s)
	);

	// etage 3 : a = a+b ; d = (d^a) <<< 8
	ARX8 arx_8 (
		.augend_i (a_s),
		.addend_i (b_s),
		.b_i      (d_s),
		.sum_o    (a_o),
		.shift_o  (d_o)
	);

	// etage 4 : c = c+d ; b = (b^c) <<< 7
	ARX7 arx_7 (
		.augend_i (c_s),
		.addend_i (d_o),
		.b_i      (b_s),
		.sum_o    (c_o),
		.shift_o  (b_o)
	);

endmodule : QuarterRound
