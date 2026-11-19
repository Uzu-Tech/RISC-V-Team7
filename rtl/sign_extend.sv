module sign_extend(
    /* verilator lint_off UNUSEDSIGNAL */ // bits [19:12] and [6:0] are only needed once U/J/S types are added
    input  logic [31:0] curr_instr, //current instr has 12 bit Imms
    /* verilator lint_on UNUSEDSIGNAL */
    input  logic [1:0] imm_src, // 00 = I-type, 01 = B-type
    output logic [31:0] sign_extended_imm //we want to sign extend 12 bit imm by 20 to make 32 bit imms
);

always_comb begin
    case (imm_src)
        2'b00: begin // I-type instruction
            sign_extended_imm = {{20{curr_instr[31]}}, curr_instr[31:20]}; // concatenate the sign bit upper as the sign bit extended for 20 with the original lower 12 bits to form 32 bit instr
        end
        2'b01: begin // B-type instruction
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
