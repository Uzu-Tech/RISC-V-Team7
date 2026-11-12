module control_unit (
    input   logic [6:0]  opcode,
    input   logic [2:0] funct3,
    input   logic eq,
    output logic reg_write,
    output logic alu_src,
    output logic [3:0] alu_ctrl,
    output logic imm_src,
    output logic pc_src
);

    always_comb begin : control_unit_logic
        // Default values
        reg_write = 1'b0; //disable register write by default
        alu_src = 1'b0; // use register value as second ALU operand by default
        alu_ctrl = 4'b0000; // default ALU operation (ADD)
        imm_src = 1'b0; // use register value as immediate by default
        pc_src = 1'b0; // select squaential next PC

        case (opcode)
            7'b0010011: begin // I-type - OP-IMM family: register–immediate ALU instructions
                if (funct3 == 3'b000) begin 
                    //ADDI: we override the two required outputs
                    reg_write = 1'b1; // enable register write
                    alu_src = 1'b1; // use immediate value as second ALU operand
                end
            end

            7'b1100011: begin // B-type - Branch instructions - branch if not equal (BNE)
                if (funct3 == 3'b001) begin //BNE
                    //BNE: override the two required outputs
                    imm_src = 1'b1; // use B-type immediate value as second ALU operand
                    pc_src = ~eq; // select branch target address if not equal
                    alu_ctrl = 4'b0001; // set ALU control to perform subtraction for comparison - CHECK IF SUB is 0 or 1 or 2 or 3!!!!
                end
            end

            default: begin
                reg_write = 1'b0;
                alu_src = 1'b0;
                alu_ctrl = 4'b0000;
                imm_src = 1'b0;
                pc_src = 1'b0;
            end
        endcase
    end

endmodule
