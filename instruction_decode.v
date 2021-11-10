// =============================================================================
// Project Name        : rv32i cpu
// Email               : huangyh76@mail2.sysu.edu.cn
// Company             : Sun Yat-Sen University
// Create Time         : 2021/11/01
// File Name           : instruction_decode.v
// Module Name         : instruction_decode
// Designer            : Huangyh
// Editor              : vs code
//
// *****************************************************************************
// Abstract            : instruction decode, comb logic
//
// *****************************************************************************
//
// Modification History:
// Date                By              Version             Change Description
// -----------------------------------------------------------------------------
// 2021/11/01       Huangyh             1.0                         none
//
// =============================================================================

`timescale 1ns / 1ps
`include "define.vh"

module instruction_decode (
    input   [`DATA_WIDTH-1:0]       instruction,

    output                          branch_jump,

    output                          alu_src,
    output  [`ALUOP_WIDTH-1:0]      alu_op,

    output                          mem_write,
    output                          mem_read,
    output  [`MEM_MODE_WIDTH-1:0]   mem_mode,

    output                          mem_to_reg,

    output                          reg_write,

    output  [`RADDR_WIDTH-1:0]      reg_dest,
    output  [`RADDR_WIDTH-1:0]      reg_rs1,
    output                          reg_read1,
    output  [`RADDR_WIDTH-1:0]      reg_rs2,
    output                          reg_read2,
    
    output  [`DATA_WIDTH-1:0]       imm,

    // environment and breakpoint exception.
    output                          env_exception,
    output                          bp_exception
);

// =========================================================================== \
// ============================= Internal signals ============================
// =========================================================================== /

//==============================================================================
// output reg
//==============================================================================
reg                             branch_jump_reg;
reg                             alu_src_reg;
reg     [`ALUOP_WIDTH-1:0]      alu_op_reg;
reg                             mem_write_reg;
reg                             mem_read_reg;
reg     [`MEM_MODE_WIDTH-1:0]   mem_mode_reg;
reg                             mem_to_reg_reg;
reg                             reg_write_reg;
reg     [`RADDR_WIDTH-1:0]      reg_dest_reg;
reg     [`RADDR_WIDTH-1:0]      reg_rs1_reg;
reg                             reg_read1_reg;
reg     [`RADDR_WIDTH-1:0]      reg_rs2_reg;
reg                             reg_read2_reg;
reg     [`DATA_WIDTH-1:0]       imm_reg;
reg                             env_exception_reg;
reg                             bp_exception_reg;

//==============================================================================
// decode reg
//==============================================================================
wire    [`OP_WIDTH-1:0]         opcode;
wire    [`FNCT3_WIDTH-1:0]      funct3;
wire    [`FNCT7_WIDTH-1:0]      funct7;
wire    [`RADDR_WIDTH-1:0]      rs1;
wire    [`RADDR_WIDTH-1:0]      rs2;
wire    [`RADDR_WIDTH-1:0]      rd;

wire    [`DATA_WIDTH-1:0]       i_imm;      // I type imm, signed extend.
wire    [`DATA_WIDTH-1:0]       s_imm;      // S type imm, signed extend.
wire    [`DATA_WIDTH-1:0]       b_imm;      // B type imm, signed extend, << 1
wire    [`DATA_WIDTH-1:0]       u_imm;      // U type imm, signed extend, << 12
wire    [`DATA_WIDTH-1:0]       j_imm;      // J type imm, signed extend, << 1

// =========================================================================== \
// --------------------------------- Main Code ---------------------------------
// =========================================================================== /

//==============================================================================
// output reg assign
//==============================================================================
assign  branch_jump     = branch_jump_reg;
assign  alu_src         = alu_src_reg;
assign  alu_op          = alu_op_reg;
assign  mem_write       = mem_write_reg;
assign  mem_read        = mem_read_reg;
assign  mem_mode        = mem_mode_reg;
assign  mem_to_reg      = mem_to_reg_reg;
assign  reg_write       = reg_write_reg;
assign  reg_dest        = reg_dest_reg;
assign  reg_rs1         = reg_rs1_reg;
assign  reg_read1       = reg_read1_reg;
assign  reg_rs2         = reg_rs2_reg;
assign  reg_read2       = reg_read2_reg;
assign  imm             = imm_reg;
assign  env_exception   = env_exception_reg;
assign  bp_exception    = bp_exception_reg;

//==============================================================================
// instruction decode assign, reference document -> riscv spec.
//==============================================================================
assign  opcode          =   instruction[6:0];
assign  funct3          =   instruction[14:12];
assign  funct7          =   instruction[31:25];
assign  rs1             =   instruction[19:15];
assign  rs2             =   instruction[24:20];
assign  rd              =   instruction[11:7];

// all imm are signed extend.
assign  i_imm           =   {{20{instruction[31]}},instruction[31:20]};
assign  s_imm           =   {{20{instruction[31]}},instruction[31:25],
                            instruction[11:7]};
assign  b_imm           =   {{20{instruction[31]}},instruction[7],
                            instruction[30:25],instruction[11:8],1'b0};
assign  u_imm           =   {instruction[31:12],12'd0};
assign  j_imm           =   {{12{instruction[31]}},instruction[19:12],
                            instruction[20],instruction[30:21],1'b0};

//==============================================================================
// branch_jump decode
//==============================================================================
always @(*) begin
    if (opcode == `OP_JAL || opcode == `OP_JALR || opcode == `OP_B) begin
        branch_jump_reg =   `BJ_EN;
    end

    else begin
        branch_jump_reg =   `BJ_DIS;
    end
end

//==============================================================================
// alu_src decode
//==============================================================================
always @(*) begin
    if (opcode == `OP_B || opcode == `OP_R) begin
        alu_src_reg     =   `ALU_SRC_REG;
    end

    else begin
        alu_src_reg     =   `ALU_SRC_IMM;
    end
end

//==============================================================================
// alu op decode
//==============================================================================
always @(*) begin
    case (opcode)
        `OP_LUI:                        alu_op_reg  =   `ALU_ADD;

        `OP_AUIPC:                      alu_op_reg  =   `ALU_ADDPC;

        `OP_JAL:                        alu_op_reg  =   `ALU_ADDPC;

        `OP_JALR:                       alu_op_reg  =   `ALU_ADDPC;

        `OP_B:      begin
            case (funct3)
                `FNCT3_BEQ:             alu_op_reg  =   `ALU_EQ;
                `FNCT3_BNE:             alu_op_reg  =   `ALU_NEQ;
                `FNCT3_BLT:             alu_op_reg  =   `ALU_LT;
                `FNCT3_BGE:             alu_op_reg  =   `ALU_GE;
                `FNCT3_BLTU:            alu_op_reg  =   `ALU_LTU;
                `FNCT3_BGEU:            alu_op_reg  =   `ALU_GEU;
                default :               alu_op_reg  =   `ALU_ADD;
            endcase
        end

        `OP_L:                          alu_op_reg  =   `ALU_ADD;

        `OP_S:                          alu_op_reg  =   `ALU_ADD;

        `OP_I:      begin
            case (funct3)   // no need default branch
                `FNCT3_ADDI:            alu_op_reg  =   `ALU_ADD;
                `FNCT3_SLTI:            alu_op_reg  =   `ALU_LT;
                `FNCT3_SLTIU:           alu_op_reg  =   `ALU_LTU;
                `FNCT3_XORI:            alu_op_reg  =   `ALU_XOR;
                `FNCT3_ORI:             alu_op_reg  =   `ALU_OR;
                `FNCT3_ANDI:            alu_op_reg  =   `ALU_AND;
                `FNCT3_SLLI:            alu_op_reg  =   `ALU_SLL;
                `FNCT3_SRXI:    begin   // including SRLI and SRAI
                    case (funct7)
                        `FNCT7_SRLI:    alu_op_reg  =   `ALU_SRL;
                        `FNCT7_SRAI:    alu_op_reg  =   `ALU_SRA;
                        default :       alu_op_reg  =   `ALU_ADD;
                    endcase
                end
            endcase
        end

        `OP_R:      begin
            case (funct3)   // no need default branch
                `FNCT3_ADD_SUB: begin
                    case (funct7)
                        `FNCT7_ADD:     alu_op_reg  =   `ALU_ADD;
                        `FNCT7_SUB:     alu_op_reg  =   `ALU_SUB;
                        default :       alu_op_reg  =   `ALU_ADD;
                    endcase
                end
                `FNCT3_SLL:             alu_op_reg  =   `ALU_SLL;
                `FNCT3_SLT:             alu_op_reg  =   `ALU_LT;
                `FNCT3_SLTU:            alu_op_reg  =   `ALU_LTU;
                `FNCT3_XOR:             alu_op_reg  =   `ALU_XOR;
                `FNCT3_SRX:     begin
                    case (funct7)
                        `FNCT7_SRL:     alu_op_reg  =   `ALU_SRL;
                        `FNCT7_SRA:     alu_op_reg  =   `ALU_SRA;
                        default :       alu_op_reg  =   `ALU_ADD;
                    endcase
                end
                `FNCT3_OR:              alu_op_reg  =   `ALU_OR;
                `FNCT3_AND:             alu_op_reg  =   `ALU_AND;
            endcase
        end

        `OP_FENCE:                      alu_op_reg  =   `ALU_ADD;

        `OP_E:                          alu_op_reg  =   `ALU_ADD;
        default :                       alu_op_reg  =   `ALU_ADD;
    endcase
end

//==============================================================================
// mem write decode
//==============================================================================
always @(*) begin
    if (opcode == `OP_S) begin
        mem_write_reg   =   `MEM_WR_EN;
    end

    else begin
        mem_write_reg   =   `MEM_WR_DIS;
    end
end

//==============================================================================
// mem read decode
//==============================================================================
always @(*) begin
    if (opcode == `OP_L) begin
        mem_read_reg    =   `MEM_RD_EN;
    end

    else begin
        mem_read_reg    =   `MEM_RD_DIS;
    end
end

//==============================================================================
// mem mode decode
//==============================================================================
always @(*) begin
    if (opcode == `OP_L || opcode == `OP_S) begin
        case (funct3)
            `FNCT3_LSB: mem_mode_reg    =   `MEM_BYTE;
            `FNCT3_LSH: mem_mode_reg    =   `MEM_HWORD;
            `FNCT3_LSW: mem_mode_reg    =   `MEM_WORD;
            `FNCT3_LBU: mem_mode_reg    =   `MEM_BYTEU;
            `FNCT3_LHU: mem_mode_reg    =   `MEM_HWORDU;
            default :   mem_mode_reg    =   `MEM_BYTE;
        endcase
    end

    else begin
        mem_mode_reg    =   `MEM_BYTE;
    end
end

//==============================================================================
// mem to reg decode
//==============================================================================
always @(*) begin
    if (opcode == `OP_L) begin
        mem_to_reg_reg  =   `MEMREG_EN;
    end

    else begin
        mem_to_reg_reg  =   `MEMREG_DIS;
    end
end

//==============================================================================
// reg write decode
//==============================================================================
always @(*) begin
    case (opcode)
        `OP_LUI:    reg_write_reg   =   `REG_WR_EN;
        `OP_AUIPC:  reg_write_reg   =   `REG_WR_EN;
        `OP_JAL:    reg_write_reg   =   `REG_WR_EN;
        `OP_JALR:   reg_write_reg   =   `REG_WR_EN;
        `OP_L:      reg_write_reg   =   `REG_WR_EN;
        `OP_I:      reg_write_reg   =   `REG_WR_EN;
        `OP_R:      reg_write_reg   =   `REG_WR_EN;
        `OP_FENCE:  reg_write_reg   =   `REG_WR_EN;
        default :   reg_write_reg   =   `REG_WR_DIS;
    endcase
end

//==============================================================================
// reg dest decode
//==============================================================================
always @(*) begin
    case (opcode)
        `OP_LUI:    reg_dest_reg    =   rd;
        `OP_AUIPC:  reg_dest_reg    =   rd;
        `OP_JAL:    reg_dest_reg    =   rd;
        `OP_JALR:   reg_dest_reg    =   rd;
        `OP_L:      reg_dest_reg    =   rd;
        `OP_I:      reg_dest_reg    =   rd;
        `OP_R:      reg_dest_reg    =   rd;
        `OP_FENCE:  reg_dest_reg    =   rd;
        default :   reg_dest_reg    =   `R_ZERO;
    endcase
end

//==============================================================================
// reg rs1 decode
//==============================================================================
always @(*) begin
    case (opcode)
        `OP_JALR:   reg_rs1_reg =   rs1;
        `OP_B:      reg_rs1_reg =   rs1;
        `OP_L:      reg_rs1_reg =   rs1;
        `OP_S:      reg_rs1_reg =   rs1;
        `OP_I:      reg_rs1_reg =   rs1;
        `OP_R:      reg_rs1_reg =   rs1;
        `OP_FENCE:  reg_rs1_reg =   rs1;
        default :   reg_rs1_reg =   `R_ZERO;
    endcase
end

//==============================================================================
// reg read1 decode
//==============================================================================
always @(*) begin
    case (opcode)
        `OP_JALR:   reg_read1_reg   =   `REG_S1RD_EN;
        `OP_B:      reg_read1_reg   =   `REG_S1RD_EN;
        `OP_L:      reg_read1_reg   =   `REG_S1RD_EN;
        `OP_S:      reg_read1_reg   =   `REG_S1RD_EN;
        `OP_I:      reg_read1_reg   =   `REG_S1RD_EN;
        `OP_R:      reg_read1_reg   =   `REG_S1RD_EN;
        `OP_FENCE:  reg_read1_reg   =   `REG_S1RD_EN;
        default :   reg_read1_reg   =   `REG_S1RD_DIS;
    endcase
end

//==============================================================================
// reg rs2 decode
//==============================================================================
always @(*) begin
    case (opcode)
        `OP_B:      reg_rs2_reg =   rs2;
        `OP_S:      reg_rs2_reg =   rs2;
        `OP_R:      reg_rs2_reg =   rs2;
        default :   reg_rs2_reg =   `R_ZERO;
    endcase
end

//==============================================================================
// reg read2 decode
//==============================================================================
always @(*) begin
    case (opcode)
        `OP_B:      reg_read2_reg   =   `REG_S2RD_EN;
        `OP_S:      reg_read2_reg   =   `REG_S2RD_EN;
        `OP_R:      reg_read2_reg   =   `REG_S2RD_EN;
        default :   reg_read2_reg   =   `REG_S2RD_DIS;
    endcase
end

//==============================================================================
// imm decode
//==============================================================================
always @(*) begin
    case (opcode)
        `OP_LUI:    imm_reg =   u_imm;
        `OP_AUIPC:  imm_reg =   u_imm;
        `OP_JAL:    imm_reg =   j_imm;
        `OP_JALR:   imm_reg =   i_imm;
        `OP_B:      imm_reg =   b_imm;
        `OP_L:      imm_reg =   i_imm;
        `OP_S:      imm_reg =   s_imm;
        `OP_I:      imm_reg =   i_imm;
        default :   imm_reg =   `ZERO;
    endcase
end

//==============================================================================
// enviroment exception
//==============================================================================
always @(*) begin
    if (instruction == `ECALL) begin
        env_exception_reg   =   `ENV_EXC;
    end

    else begin
        env_exception_reg   =   `ENV_NEXC;
    end
end

//==============================================================================
// breakpoint exception
//==============================================================================
always @(*) begin
    if (instruction == `EBREAK) begin
        bp_exception_reg    =   `BP_EXC;
    end

    else begin
        bp_exception_reg    =   `BP_NEXC;
    end
end

endmodule