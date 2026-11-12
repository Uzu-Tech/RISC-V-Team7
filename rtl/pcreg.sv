module pcreg #(
    parameter DATA_WIDTH = 32
) (
    input logic clk,
    input logic rst,
    input logic [DATA_WIDTH-1:0] next_pc,
    output logic [DATA_WIDTH-1:0] pc
);
    always_ff @(posedge clk) begin 
        if (rst) pc <= {DATA_WIDTH{1'b0}};
        else pc <= next_pc;
    end

endmodule
