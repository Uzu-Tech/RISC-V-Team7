module pctop #(
    parameter WIDTH = 32
) (
    input logic rst,
    input logic clk,
    input logic pcsrc,
    input logic  [WIDTH-1:0] immOp,
    output logic [WIDTH-1:0] PC
);
    logic [WIDTH-1:0] branch_PC;
    logic [WIDTH-1:0] inc_PC;
    logic [WIDTH-1:0] next_PC;

    assign inc_PC = PC + 32'd4;
    assign branch_PC = PC + immOp;
    assign next_PC = pcsrc ? branch_PC : inc_PC;

    pcreg pcreg_1#
    (
        .WIDTH(WIDTH)
    )
    (
        .clk (clk),
        .rst (rst),
        .next_pc (next_PC),
        .pc (PC)
    );



    
endmodule
