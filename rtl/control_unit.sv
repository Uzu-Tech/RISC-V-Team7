module control_unit (
    input   logic [6:0]  opcode,
    input   logic [2:0] funct3,
    input   logic eq,
    input   logic funct7b5, //only bit 5 of funct7 needed
    output logic reg_write,
    output logic [1:0] imm_src,
    output logic alu_src,
    output logic [3:0] alu_ctrl,
    output logic mem_write, 
    output logic resultsrc,
    output logic pc_src
);

    always_comb begin : control_unit_logic
     
     //default values
        reg_write = 1'b0;                            
        alu_src = 1'b0;
        alu_ctrl = 4'b0000;
        imm_src = 2'b00; 
        pc_src = 1'b0;
        mem_write = 1'b0;
        resultsrc = 1'b0;

        case (opcode)
            7'b0010011: begin // I-type - OP-IMM family: register–immediate ALU instructions
                if (funct3 == 3'b000) begin 
                    //ADDI: we override the two required outputs, enable reg write and use immediate value as second ALU operand
                    reg_write = 1'b1; 
                    alu_src = 1'b1; 
                end
                else if (funct3 == 3'b111) begin // ANDI - enable reg write, use imm value, set alu to and 
                    reg_write = 1'b1;
                    alu_src = 1'b1;
                    alu_ctrl = 4'b0010;
                end
                else if (funct3 == 3'b110) begin // ORI
                    reg_write = 1'b1;
                    alu_src = 1'b1;
                    alu_ctrl = 4'b0011; // OR
                end
                else if (funct3 == 3'b100) begin // XORI
                    reg_write = 1'b1;
                    alu_src = 1'b1;
                    alu_ctrl = 4'b0100; // XOR
                end
                else if (funct3 == 3'b010) begin // SLTI
                    reg_write = 1'b1;
                    alu_src = 1'b1;
                    alu_ctrl = 4'b1000; // SLT
                end
                else if (funct3 == 3'b011) begin // SLTIU
                    reg_write = 1'b1;
                    alu_src = 1'b1;
                    alu_ctrl = 4'b1001; // SLTIU
                end
                else if (funct3 == 3'b001) begin // SLLI
                    reg_write = 1'b1;
                    alu_src = 1'b1;
                    alu_ctrl = 4'b0101; // SLL
                end
                else if (funct3 == 3'b101) begin // SRLI or SRAI based on funct7b5
                    reg_write = 1'b1;
                    alu_src = 1'b1;
                    alu_ctrl = funct7b5 ? 4'b0111 : 4'b0110; // SRA if funct7b5 is 1, else SRL
                end
            end

            7'b1100011: begin // B-type - Branch instructions - branch if not equal (BNE)
                if (funct3 == 3'b001) begin 
                    //BNE: override the two required outputs, select B-type immediate for calculating branch target address (PC + offset), and branch if registers are not equal.
                    imm_src = 2'b01;
                    pc_src = ~eq; 
                    alu_ctrl = 4'b0001; // set ALU control to perform subtraction for comparison
                end
                    else if (funct3 == 3'b000) begin // BEQ
                        imm_src = 2'b01;
                        pc_src = eq;
                        alu_ctrl = 4'b0001; // set ALU control to perform subtraction for comparison
                    end
                end

            7'b0000011: begin // load instructions
                if (funct3 == 3'b010) begin 
                    //LW: override the required outputs, write into register, with immediate (I-type).
                    reg_write = 1'b1;
                    alu_src = 1'b1;
                    resultsrc = 1'b1; // select data from memory to write back to register
                end
            end

            7'b0100011: begin // store instructions
                if (funct3 == 3'b010) begin 
                    //SW: override the required outputs, write into memory, with immediate (S-type).
                    alu_src = 1'b1;
                    imm_src = 2'b10; 
                    mem_write = 1'b1; // enable memory write for store
                end
            end

            7'b0110011: begin// R-type instruction
                if (funct3 == 3'b000) begin // ADD or SUB based on funct7b5
                    reg_write = 1'b1; // enable register write
                    alu_ctrl = funct7b5 ? 4'b0001 : 4'b0000; // SUB if funct7b5 is 1, else ADD

                end

                else if (funct3 == 3'b110) begin // OR
                    reg_write = 1'b1;
                    alu_ctrl = 4'b0011;
                end

                else if (funct3 == 3'b111) begin // AND
                    reg_write = 1'b1;
                    alu_ctrl = 4'b0010;
                end

                else if (funct3 == 3'b010) begin // SLT
                    reg_write = 1'b1;
                    alu_ctrl = 4'b1000;
                end

                else if (funct3 == 3'b011) begin // SLTU
                    reg_write = 1'b1;
                    alu_ctrl = 4'b1001;
                end

                else if (funct3 == 3'b100) begin // XOR
                    reg_write = 1'b1;
                    alu_ctrl = 4'b0100;
                end

                else if (funct3 == 3'b001) begin // SLL
                    reg_write = 1'b1;
                    alu_ctrl = 4'b0101;
                end

                else if (funct3 == 3'b101) begin // SRL or SRA based on funct7b5
                    reg_write = 1'b1;
                    alu_ctrl = funct7b5 ? 4'b0111 : 4'b0110; // SRA if funct7b5 is 1, else SRL
                end

            end



        endcase
    end

endmodule
