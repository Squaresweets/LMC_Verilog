module memory (
    input logic clk,
    input logic reset,
    input logic [6:0] addr,
    input logic [10:0] data,
    input logic write_enable,
    output logic [10:0] out
);
    logic [10:0] underlying_memory [0:99];

    assign out = underlying_memory[addr];

    always_ff @(posedge clk or posedge reset) begin
		if (reset) begin
			underlying_memory[0] = 521;
			underlying_memory[1] = 120;
			underlying_memory[2] = 321;
			underlying_memory[3] = 520;
			underlying_memory[4] = 322;
			underlying_memory[5] = 522;
			underlying_memory[6] = 120;
			underlying_memory[7] = 322;
			underlying_memory[8] = 221;
			underlying_memory[9] = 120;
			underlying_memory[10] = 122;
			underlying_memory[11] = 817;
			underlying_memory[12] = 521;
			underlying_memory[13] = 222;
			underlying_memory[14] = 700;
			underlying_memory[15] = 813;
			underlying_memory[16] = 605;
			underlying_memory[17] = 521;
			underlying_memory[18] = 902;
			underlying_memory[19] = 800;
			underlying_memory[20] = 001;
			underlying_memory[21] = 004;
			underlying_memory[22] = 002;

		end else if (write_enable)
            underlying_memory[addr] <= data;
    end
endmodule
