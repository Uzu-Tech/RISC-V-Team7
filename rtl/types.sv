package types;
    typedef enum logic [3:0] {
        ALU_ADD  = 4'b0_000,
        ALU_SLL  = 4'b0_001,
        ALU_SLT  = 4'b0_010,
        ALU_SLTU = 4'b0_011,
        ALU_XOR  = 4'b0_100,
        ALU_SRL  = 4'b0_101,
        ALU_OR   = 4'b0_110,
        ALU_AND  = 4'b0_111,
        ALU_SUB  = 4'b1_000,
        ALU_SRA  = 4'b1_101
    } alu_ctrl_t;

    typedef enum logic [6:0] {
        OPCODE_LOAD   = 7'b0000011,
        OPCODE_OP_IMM = 7'b0010011,
        OPCODE_STORE  = 7'b0100011,
        OPCODE_OP     = 7'b0110011,
        OPCODE_BRANCH = 7'b1100011
    } opcode_t;

    // funct3 for OP / OP-IMM
    typedef enum logic [2:0] {
        FUNCT3_ADD_SUB, FUNCT3_SLL, FUNCT3_SLT, FUNCT3_SLTU,
        FUNCT3_XOR, FUNCT3_SRL_SRA, FUNCT3_OR, FUNCT3_AND
    } funct3_alu_t;

    // funct3 for BRANCH
    typedef enum logic [2:0] {
        BEQ, BNE, BLT, BGE, BLTU, BGEU
    } branch_t;

    // funct3 for LOAD / STORE (access width)
    typedef enum logic [1:0] { 
        BYTE, HALF_WORD, WORD
    } mem_size_t;

    // Immediate format selector for sign_extend
    typedef enum logic [2:0] {
        IMM_I, IMM_B, IMM_S, IMM_U, IMM_J
    } imm_type_t;

    typedef enum logic [1:0] {
        PC_PLUS4,   // Next instruction
        PC_OFFSET,  // PC + imm
        PC_REG      // rs1 + imm 
    } pc_src_t;

endpackage
