// Module ARX avec rotation a gauche de 12 bits
module ARX12 (
	input  logic [31:0] augend_i,
	input  logic [31:0] addend_i,
	input  logic [31:0] b_i,
	output logic [31:0] sum_o,
	output logic [31:0] shift_o
);

	logic [31:0] sum_s;
	logic [31:0] xor_s;

	assign sum_s = augend_i + addend_i;
	assign xor_s = sum_s ^ b_i;

	// rotation a gauche de 12 bits
	assign shift_o = { xor_s[19:0], xor_s[31:20] };

	assign sum_o = sum_s;

endmodule : ARX12
