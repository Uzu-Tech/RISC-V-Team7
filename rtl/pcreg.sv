module pcreg #(
    parameter WIDTH = 32
) (
    input logic clk,
    input logic rst,
    input logic [WIDTH-1:0] next_pc,
    output logic [WIDTH-1:0] pc
);
    always_ff @(posedge clk) begin 
        if (rst) pc <= {WIDTH{1'b0}};
        else pc <= next_pc;
    end

endmodule
