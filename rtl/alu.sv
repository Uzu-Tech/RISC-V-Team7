module alu
    import types::*;
#(
    parameter int DATA_WIDTH = 32
) (
    input  alu_ctrl_t              ALU_Ctrl, // {alt, funct3}, see types.sv
    input  logic [DATA_WIDTH-1:0]  ALU_op1,
    input  logic [DATA_WIDTH-1:0]  ALU_op2,
    output logic [DATA_WIDTH-1:0]  ALU_out
);

    logic [4:0] shamt; // bottom 5 bits are the actual shift amount in RV32I
    assign shamt = ALU_op2[4:0];

    always_comb begin
        case (ALU_Ctrl)
            ALU_ADD:    ALU_out = ALU_op1 + ALU_op2;
            ALU_SUB:    ALU_out = ALU_op1 - ALU_op2;
            ALU_SLL:    ALU_out = ALU_op1 << shamt;
            ALU_SLT:    ALU_out = {{(DATA_WIDTH-1){1'b0}}, $signed(ALU_op1) < $signed(ALU_op2)};
            ALU_SLTU:   ALU_out = {{(DATA_WIDTH-1){1'b0}}, ALU_op1 < ALU_op2};
            ALU_XOR:    ALU_out = ALU_op1 ^ ALU_op2;
            ALU_SRL:    ALU_out = ALU_op1 >> shamt;
            ALU_SRA:    ALU_out = $signed(ALU_op1) >>> shamt;
            ALU_OR:     ALU_out = ALU_op1 | ALU_op2;
            ALU_AND:    ALU_out = ALU_op1 & ALU_op2;
            default:    ALU_out = '0;
        endcase
    end

endmodule
