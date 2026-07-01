// Module ARX avec rotation a gauche de 7 bits
module ARX7 (
	input  logic [31:0] augend_i,
	input  logic [31:0] addend_i,
	input  logic [31:0] b_i,
	output logic [31:0] sum_o,
	output logic [31:0] shift_o
);

	logic [31:0] sum_s;
	logic [31:0] xor_s;

	// addition mod 2^32
	assign sum_s = augend_i + addend_i;

	// XOR avec l'entree b
	assign xor_s = sum_s ^ b_i;

	// rotation a gauche de 7 bits
	assign shift_o = { xor_s[24:0], xor_s[31:25] };

	assign sum_o = sum_s;

endmodule : ARX7
