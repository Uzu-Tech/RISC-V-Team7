/*
  5. Agree how invalid/out-of-range fetches are handled during simulation.
*/

module instr_mem(
    input logic [31:0] addr,
    output logic [31:0] instr

);
    logic [7:0] mem [0:65535]; // 4096 bytes of instruction memory (4 bytes per instr)
    logic [31:0] byte_index;
    assign byte_index = addr - 32'hBFC00000; // Program starts at address 0xBFC00000, matching array index 0.
    always_comb begin
        instr = 
        {mem[byte_index + 3],
        mem[byte_index + 2],
        mem[byte_index + 1],
        mem[byte_index]}
    end

    initial begin
        $readmemh("../rtl/program.hex", mem);
    end

endmodule