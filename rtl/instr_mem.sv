module instr_mem(
    input logic [31:0] addr,
    output logic [31:0] instr

);
    logic [7:0] mem [0:255]; // 256 bytes of instruction memory
    logic [31:0] byte_index;
    assign byte_index = addr; // Program starts at address 0, matching array index 0.

    assign instr = {
        mem[byte_index + 3],
        mem[byte_index + 2],
        mem[byte_index + 1],
        mem[byte_index]
    };

    initial begin
        $readmemh("../build/program.hex", mem);
    end

endmodule
