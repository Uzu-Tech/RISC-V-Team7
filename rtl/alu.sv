import types::*;

module alu #(
    parameter int DATA_WIDTH = 32
) (
    input  alu_ctrl_t              ALU_Ctrl,
    input  logic [DATA_WIDTH-1:0]  ALU_op1,
    input  logic [DATA_WIDTH-1:0]  ALU_op2,
    output logic [DATA_WIDTH-1:0]  ALU_out
);

    always_comb begin
        case (ALU_Ctrl)
            ALU_ADD:  ALU_out = ALU_op1 + ALU_op2;
            ALU_SUB:  ALU_out = ALU_op1 - ALU_op2;
            ALU_AND:  ALU_out = ALU_op1 & ALU_op2;
            ALU_OR:   ALU_out = ALU_op1 | ALU_op2;
            ALU_XOR:  ALU_out = ALU_op1 ^ ALU_op2;
            ALU_SLL:  ALU_out = ALU_op1 << ALU_op2;
            ALU_SRL:  ALU_out = ALU_op1 >> ALU_op2;
            ALU_SRA:  ALU_out = $signed(ALU_op1) >>> ALU_op2;
            ALU_SLT:  ALU_out = ($signed(ALU_op1) < $signed(ALU_op2)) ? 1 : 0;
            ALU_SLTU: ALU_out = (ALU_op1 < ALU_op2) ? 1 : 0;
            default:  ALU_out = '0;
        endcase
    end

endmodule