module sign_extend(
    input  logic [31:0] curr_instr, //current instr has 12 bit Imms
    input  logic  imm_src, // 0 isI type, 1 is B type.
    output logic [31:0] sign_extended_imm //we want to sign extend 12 bit imm by 20 to make 32 bit imms
);

always_comb begin
    case (imm_src)
        1'b0: begin // I-type instruction
            sign_extended_imm = {{20{curr_instr[31]}}, curr_instr[31:20]}; // concatenate the sign bit upper as the sign bit extended for 20 with the original lower 12 bits to form 32 bit instr
        end
        1'b1: begin // B-type instruction
            sign_extended_imm = {{19{curr_instr[31]}}, curr_instr[31], curr_instr[7], curr_instr[30:25], curr_instr[11:8], 1'b0}; 
        // B type has scrambled immediate bits
        // Instruction location:  [31]   [7]   [30:25]   [11:8]
        //                          ↓     ↓       ↓         ↓
        // Immediate position:    [12]  [11]   [10:5]    [4:1]   [0 = 0]
        // Prepend 19 copies of instr[31] to sign-extend this 13-bit offset to 32 bits.
        end
        default: begin
            sign_extended_imm = 32'b0; // default case
        end
    endcase
end


endmodule
