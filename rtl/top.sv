module top #(
    parameter DATA_WIDTH = 32,
    parameter ADDRESS_WIDTH = 5
) (
    input   logic clk,
    input   logic rst,
    output  logic [DATA_WIDTH-1:0] a0    
);

    typedef struct packed {
        logic [6:0]  funct7;
        logic [4:0]  rs2;
        logic [4:0]  rs1;
        logic [2:0]  funct3;
        logic [4:0]  rd;
        logic [6:0]  opcode;
    } instruction_t;

    logic [DATA_WIDTH-1:0] PC;
    instruction_t instr;
    logic [DATA_WIDTH-1:0] ImmOp;
    logic [DATA_WIDTH-1:0] ALUout;

    logic [DATA_WIDTH-1:0]   ALUop1;
    logic [DATA_WIDTH-1:0]   regOp2;
    logic [DATA_WIDTH-1:0]   ALUop2;
    
    logic             RegWrite;
    logic [3:0]       ALUctrl;
    logic             ALUsrc;
    logic [1:0]       ImmSrc;
    logic             PCsrc;
    logic             EQ;

    pctop #(.DATA_WIDTH(DATA_WIDTH)) u_pctop(
        .clk (clk),
        .rst (rst),
        .pcsrc (PCsrc),
        .immOp (ImmOp),
        .PC (PC)
    );

    instr_mem u_instr_mem(
        .addr (PC),
        .instr (instr)
    );

    control_unit u_control_unit(
        .opcode (instr.opcode),
        .funct3 (instr.funct3),
        .eq(EQ),
        .reg_write(RegWrite),
        .alu_src(ALUsrc),
        .alu_ctrl(ALUctrl),
        .imm_src(ImmSrc),
        .pc_src (PCsrc)
    );

    sign_extend u_sign_ext (
        .curr_instr(instr),
        .imm_src(ImmSrc),
        .sign_extended_imm(ImmOp)
    );

    regfile #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDRESS_WIDTH(ADDRESS_WIDTH)
    ) u_regfile
    (
        .clk(clk),
        .read_addr1(instr.rs1),
        .read_addr2(instr.rs2),
        .write_addr(instr.rd),
        .write_en(RegWrite),
        .write_data(ALUout),
        .read_data1(ALUop1),
        .read_data2(regOp2),
        .a0(a0)
    );

    assign ALUop2 = ALUsrc ? ImmOp : regOp2;
    assign EQ = (ALUop1 == regOp2);

    alu #(.DATA_WIDTH(DATA_WIDTH)) u_alu(
        .ALU_Ctrl (ALUctrl),
        .ALU_op1 (ALUop1),
        .ALU_op2(ALUop2),
        .ALU_out (ALUout)
    );

endmodule

