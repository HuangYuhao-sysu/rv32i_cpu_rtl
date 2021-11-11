// =============================================================================
// Project Name        : rv32i cpu
// Email               : huangyh76@mail2.sysu.edu.cn
// Company             : Sun Yat-Sen University
// Create Time         : 2021/10/30
// File Name           : define.v
// Module Name         : define
// Designer            : Huangyh
// Editor              : vs code
//
// *****************************************************************************
// Abstract            : define of RISC-V ISA and internal microcode
//
// *****************************************************************************
//
// Modification History:
// Date                By              Version             Change Description
// -----------------------------------------------------------------------------
// 2021/10/30       Huangyh             1.0                         none
//
// =============================================================================

//==============================================================================
// RV32I instruction opcode
//==============================================================================
`define OP_LUI          7'b0110111
`define OP_AUIPC        7'b0010111
`define OP_JAL          7'b1101111
`define OP_JALR         7'b1100111

// Include BEQ, BNE, BLT, BGE, BLTU, BGEU
`define OP_B            7'b1100011

// Include LB, LH, LW, LBU, LHU
`define OP_L            7'b0000011

// Include SB, SH, SW
`define OP_S            7'b0100011

// Include ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI
`define OP_I            7'b0010011

// Include ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND
`define OP_R            7'b0110011

`define OP_FENCE        7'b0001111

// Include ECALL, EBREAK
`define OP_E            7'b1110011

//==============================================================================
// RV32I instruction funct3
//==============================================================================
`define FNCT3_JALR      3'b000

`define FNCT3_BEQ       3'b000
`define FNCT3_BNE       3'b001
`define FNCT3_BLT       3'b100
`define FNCT3_BGE       3'b101
`define FNCT3_BLTU      3'b110
`define FNCT3_BGEU      3'b111

`define FNCT3_LSB       3'b000  // load and store
`define FNCT3_LSH       3'b001  // load and store
`define FNCT3_LSW       3'b010  // load and store

`define FNCT3_LB        3'b000  // don't use this
`define FNCT3_LH        3'b001  // don't use this
`define FNCT3_LW        3'b010  // don't use this

`define FNCT3_LBU       3'b100
`define FNCT3_LHU       3'b101

`define FNCT3_SB        3'b000  // don't use this
`define FNCT3_SH        3'b001  // don't use this
`define FNCT3_SW        3'b010  // don't use this

`define FNCT3_ADDI      3'b000
`define FNCT3_SLTI      3'b010
`define FNCT3_SLTIU     3'b011
`define FNCT3_XORI      3'b100
`define FNCT3_ORI       3'b110
`define FNCT3_ANDI      3'b111
`define FNCT3_SLLI      3'b001

`define FNCT3_SRLI      3'b101  // just use SRXI.
`define FNCT3_SRAI      3'b101  // just use SRXI.
`define FNCT3_SRXI      3'b101  // just use this define.

`define FNCT3_ADD_SUB   3'b000  // just use this define
`define FNCT3_ADD       3'b000  // just use ADD_SUB
`define FNCT3_SUB       3'b000  // just use ADD_SUB

`define FNCT3_SLL       3'b001
`define FNCT3_SLT       3'b010
`define FNCT3_SLTU      3'b011
`define FNCT3_XOR       3'b100

`define FNCT3_SRX       3'b101  // just use this define
`define FNCT3_SRL       3'b101  // just use SRX
`define FNCT3_SRA       3'b101  // just use SRX

`define FNCT3_OR        3'b110
`define FNCT3_AND       3'b111

`define FNCT3_FENCE     3'b000

`define FNCT3_ECALL     3'b000
`define FNCT3_EBREAK    3'b000

//==============================================================================
// RV32I instruction funct7
//==============================================================================
`define FNCT7_SLLI      7'b0000000

`define FNCT7_SRLI      7'b0000000
`define FNCT7_SRAI      7'b0100000

`define FNCT7_ADD       7'b0000000
`define FNCT7_SRL       7'b0000000
`define FNCT7_SUB       7'b0100000
`define FNCT7_SRA       7'b0100000

//==============================================================================
// RV32I instruction ecall, ebreak imm
//==============================================================================
`define IMM_ECALL       12'b000000000000
`define IMM_EBREAK      12'b000000000001

//==============================================================================
// RV32I reg define, ABI name, 32 regs
//==============================================================================
`define R_ZERO          5'd0    // Hard-wired zero
`define R_RA            5'd1    // Return address
`define R_SP            5'd2    // Stack pointer
`define R_GP            5'd3    // Global pointer
`define R_TP            5'd4    // Thread pointer
`define R_T0            5'd5    // Temporary/alternate link register 
`define R_T1            5'd6    // Temporaries
`define R_T2            5'd7    // Temporaries
`define R_S0FP          5'd8    // Saved register/frame pointer
`define R_S1            5'd9    // Saved register
`define R_A0            5'd1    // Function arguments/return values
`define R_A1            5'd1    // Function arguments/return values
`define R_A2            5'd1    // Function arguments
`define R_A3            5'd1    // Function arguments
`define R_A4            5'd1    // Function arguments
`define R_A5            5'd1    // Function arguments
`define R_A6            5'd1    // Function arguments
`define R_A7            5'd1    // Function arguments
`define R_S2            5'd1    // Saved registers
`define R_S3            5'd1    // Saved registers
`define R_S4            5'd2    // Saved registers
`define R_S5            5'd2    // Saved registers
`define R_S6            5'd2    // Saved registers
`define R_S7            5'd2    // Saved registers
`define R_S8            5'd2    // Saved registers
`define R_S9            5'd2    // Saved registers
`define R_S10           5'd2    // Saved registers
`define R_S11           5'd2    // Saved registers
`define R_T3            5'd2    // Temporaries
`define R_T4            5'd2    // Temporaries
`define R_T5            5'd3    // Temporaries
`define R_T6            5'd3    // Temporaries

//==============================================================================
// Exception code, reference RISC-V Volume II
//==============================================================================
// Interrupt
`define EX_SSI          5'd1    // Supervisor software interrupt
`define EX_MSI          5'd3    // Machine software interrupt
`define EX_STI          5'd5    // Supervisor timer interrupt
`define EX_MTI          5'd7    // Machine timer interrupt
`define EX_SEI          5'd9    // Supervisor external interrupt
`define EX_MEI          5'd11   // Machine external interrupt

// Non-interrupt
`define EX_IAM          5'd0    // Instruction address misaligned
`define EX_IAF          5'd1    // Instruction access fault
`define EX_II           5'd2    // Illegal instruction
`define EX_BP           5'd3    // Breakpoint
`define EX_LAM          5'd4    // Load address misaligned
`define EX_LAF          5'd5    // Load access fault
`define EX_SAM          5'd6    // Store/AMO address misaligned
`define EX_SAF          5'd7    // Store/AMO access fault
`define EX_ECU          5'd8    // Environment call from U-mode
`define EX_ECS          5'd9    // Environment call from S-mode
`define EX_ECM          5'd11   // Environment call from M-mode
`define EX_IPF          5'd12   // Instruction page fault
`define EX_LPF          5'd13   // Load page fault
`define EX_SPF          5'd15   // Store/AMO page fault

//==============================================================================
// Machine feature and internal signals define
//==============================================================================
`define DATA_WIDTH      32      // any data width
`define PC_WIDTH        32      // program counter width
`define IADDR_WIDTH     11      // i cache address width 11
`define DADDR_WIDTH     9       // d cache address width9
`define RADDR_WIDTH     5       // reg address width
`define REG_NUM         32      // register number
`define IMEM_SIZE       2048    // i cache size 2048
`define DMEM_SIZE       512     // d cache size 512
`define MEM_WIDTH       8       // one byte
`define ALUOP_WIDTH     4       // alu op code, 4bits
`define MEM_MODE_WIDTH  3       // mem access mode
`define DEBUG_WIDTH     3       // 5 state for debug.
`define DBWEB_WIDTH     4       // d cache byte write enable signals

`define OP_WIDTH        7     // opcode width
`define FNCT3_WIDTH     3     //funct 3 width
`define FNCT7_WIDTH     7     //funct 7 width

`define RST_ACTIVE      1'd0    // rst_n, active low
`define RST_RELEASE     1'b1    // rst_n release

`define PC_SRC_BJ       1'b1    // Select target address
`define PC_SRC_ADD4     1'b0    // Select PC + 4
`define PC_INCREMT      32'd4

`define REG_WR_EN       1'b1    // Write reg enable
`define REG_WR_DIS      1'b0    // Write reg disable
`define REG_S1RD_EN     1'b1    // Read rs1 enable
`define REG_S1RD_DIS    1'b0    // Read rs1 disable
`define REG_S2RD_EN     1'b1    // Read rs2 enable
`define REG_S2RD_DIS    1'b0    // Read rs2 disable

`define ALU_SRC_IMM     1'b1    // ALU op2 select imme
`define ALU_SRC_REG     1'b0    // ALU op2 select reg

`define ALU_ADD         4'd0    // ALU ADD
`define ALU_SUB         4'd1    // ALU SUB
`define ALU_AND         4'd2    // ALU AND
`define ALU_OR          4'd3    // ALU OR
`define ALU_XOR         4'd4    // ALU XOR
`define ALU_SLL         4'd5    // ALU shift left logical
`define ALU_SRL         4'd6    // ALU shift right logical
`define ALU_SRA         4'd7    // ALU shift right algorithms
`define ALU_LT          4'd8    // ALU less than
`define ALU_LTU         4'd9    // ALU less than unsigned
`define ALU_EQ          4'd10   // ALU equal
`define ALU_NEQ         4'd11   // ALU not equal
`define ALU_GE          4'd12   // ALU greater and equal
`define ALU_GEU         4'd13   // ALU greater and equal unsigned
`define ALU_ADDPC       4'd14   // pc + 4 to rd

`define MEM_RD_EN       1'b1    // Memory read enable
`define MEM_RD_DIS      1'b0    // Memory read disable
`define MEM_WR_EN       1'b1    // Memory write enable
`define MEM_WR_DIS      1'b0    // Memory write disable

`define MEM_BYTE        3'd0    // Memory byte operation
`define MEM_HWORD       3'd1    // Memory halfword operation
`define MEM_WORD        3'd2    // Memory word operation
`define MEM_BYTEU       3'd3    // Memory byte unsigned operation
`define MEM_HWORDU      3'd4    // Memory half word unsigned operation

`define MEMREG_EN       1'b1    // Memory to reg enable -> LOAD
`define MEMREG_DIS      1'b0    // Memory to reg disable

`define STALL_DIS       1'b0
`define STALL_EN        1'b1
`define FLUSH_DIS       1'b0
`define FLUSH_EN        1'b1

`define DEBUG_DIS       3'd0    // debug mode disable
`define DEBUG_PCRD      3'd1    // debug mode read pc to external io
`define DEBUG_ICRD      3'd2    // debug mode, read icache
`define DEBUG_ICWR      3'd3    // debug mode, write icache
`define DEBUG_REGRD     3'd4    // debug mode, read register
`define DEBUG_DCRD      3'd5    // debug mode, read dcache

`define BJ_EN           1'b1    // branch jump enable
`define BJ_DIS          1'b0

`define CHIP_EN         1'b1    // cache chip active high
`define CHIP_DIS        1'b0
`define CHIP_WEN        1'b1    // cache chip write active high
`define CHIP_WDIS       1'b0

`define IADDR_ZERO      11'd0
`define DADDR_ZERO      9'd0

`define ENV_EXC         1'b1    // env exception
`define ENV_NEXC        1'b0    // env non-exception

`define BP_EXC          1'b1    // breakpoint exception
`define BP_NEXC         1'b0    // breakpoint non-exception

`define DC_BWEB_BYTE0   4'b0001
`define DC_BWEB_BYTE1   4'b0010
`define DC_BWEB_BYTE2   4'b0100
`define DC_BWEB_BYTE3   4'b1000
`define DC_BWEB_HWORD0  4'b0011
`define DC_BWEB_HWORD2  4'b1100
`define DC_BWEB_WORD    4'b1111
`define DC_BWEB_DIS     4'b0000

`define SEL_CPUCLK      1'b0
`define SEL_DEBUGCLK    1'b1

`define IFIDSM_WIDTH    2

//==============================================================================
// Instruction code
//==============================================================================
`define NOP             32'h00000013
`define ZERO            32'h00000000
`define ECALL           32'h00000073
`define EBREAK          32'h00100073

//==============================================================================
// Mask particular bytes
//==============================================================================
`define BYTE_0_MASK     32'h000000ff
`define BYTE_1_MASK     32'h0000ff00
`define BYTE_2_MASK     32'h00ff0000
`define BYTE_3_MASK     32'hff000000
`define BYTE_0_1_MASK   32'h0000ffff
`define BYTE_0_2_MASK   32'h00ff00ff
`define BYTE_0_3_MASK   32'hff0000ff
`define BYTE_1_2_MASK   32'h00ffff00
`define BYTE_1_3_MASK   32'hff00ff00
`define BYTE_2_3_MASK   32'hffff0000
`define BYTE_0_1_2_MASK 32'h00ffffff
`define BYTE_0_1_3_MASK 32'hff00ffff
`define BYTE_0_2_3_MASK 32'hffff00ff
`define BYTE_1_2_3_MASK 32'hffffff00
`define PC_ALIGNED_MASK 32'hfffffffc