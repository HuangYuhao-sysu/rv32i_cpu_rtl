// =============================================================================
// Project Name        : rv32i cpu
// Email               : huangyh76@mail2.sysu.edu.cn
// Company             : Sun Yat-Sen University
// Create Time         : 2021/11/01
// File Name           : stage_idex.v
// Module Name         : stage_idex
// Designer            : Huangyh
// Editor              : vs code
//
// *****************************************************************************
// Abstract            : sequential logic transmit data from id to ex
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

module stage_idex (
    input                           clk,    // Clock
    input                           rst_n,  // Asynchronous reset active low

    input   [`PC_WIDTH-1:0]         pc_i,

    input                           branch_jump_i,

    input                           alu_src_i,
    input   [`ALUOP_WIDTH-1:0]      alu_op_i,

    input                           mem_write_i,
    input                           mem_read_i,
    input   [`MEM_MODE_WIDTH-1:0]   mem_mode_i,

    input                           mem_to_reg_i,

    input                           reg_write_i,

    input   [`DATA_WIDTH-1:0]       reg_rdata1_i,   // rs1 data
    input   [`DATA_WIDTH-1:0]       reg_rdata2_i,   // rs2 data
    input   [`DATA_WIDTH-1:0]       imm_i,         //immediate data

    input   [`RADDR_WIDTH-1:0]      rs1_i,          // rs1 addr, for forwarding
    input   [`RADDR_WIDTH-1:0]      rs2_i,          // rs2 addr, for forwarding
    input   [`RADDR_WIDTH-1:0]      rd_i,           // rd addr, for write back

    output  [`PC_WIDTH-1:0]         pc_o,

    output                          branch_jump_o,

    output                          alu_src_o,
    output  [`ALUOP_WIDTH-1:0]      alu_op_o,

    output                          mem_write_o,
    output                          mem_read_o,
    output  [`MEM_MODE_WIDTH-1:0]   mem_mode_o,

    output                          mem_to_reg_o,

    output                          reg_write_o,

    output  [`DATA_WIDTH-1:0]       reg_rdata1_o,   // rs1 data
    output  [`DATA_WIDTH-1:0]       reg_rdata2_o,   // rs2 data
    output  [`DATA_WIDTH-1:0]       imm_o,         //immediate data

    output  [`RADDR_WIDTH-1:0]      rs1_o,          // rs1 addr, for forwarding
    output  [`RADDR_WIDTH-1:0]      rs2_o,          // rs2 addr, for forwarding
    output  [`RADDR_WIDTH-1:0]      rd_o           // rd addr, for write back
);

// =========================================================================== \
// ============================= Internal signals ============================
// =========================================================================== /
reg [`PC_WIDTH-1:0]         pc_o_reg;
reg                         branch_jump_o_reg;
reg                         alu_src_o_reg;
reg [`ALUOP_WIDTH-1:0]      alu_op_o_reg;
reg                         mem_write_o_reg;
reg                         mem_read_o_reg;
reg [`MEM_MODE_WIDTH-1:0]   mem_mode_o_reg;
reg                         mem_to_reg_o_reg;
reg                         reg_write_o_reg;
reg [`DATA_WIDTH-1:0]       reg_rdata1_o_reg;
reg [`DATA_WIDTH-1:0]       reg_rdata2_o_reg;
reg [`DATA_WIDTH-1:0]       imm_o_reg;
reg [`RADDR_WIDTH-1:0]      rs1_o_reg;
reg [`RADDR_WIDTH-1:0]      rs2_o_reg;
reg [`RADDR_WIDTH-1:0]      rd_o_reg;

// =========================================================================== \
// --------------------------------- Main Code ---------------------------------
// =========================================================================== /

//==============================================================================
// output reg assign
//==============================================================================
assign pc_o             =  pc_o_reg;
assign branch_jump_o    =  branch_jump_o_reg;
assign alu_src_o        =  alu_src_o_reg;
assign alu_op_o         =  alu_op_o_reg;
assign mem_write_o      =  mem_write_o_reg;
assign mem_read_o       =  mem_read_o_reg;
assign mem_mode_o       =  mem_mode_o_reg;
assign mem_to_reg_o     =  mem_to_reg_o_reg;
assign reg_write_o      =  reg_write_o_reg;
assign reg_rdata1_o     =  reg_rdata1_o_reg;
assign reg_rdata2_o     =  reg_rdata2_o_reg;
assign imm_o            =  imm_o_reg;
assign rs1_o            =  rs1_o_reg;
assign rs2_o            =  rs2_o_reg;
assign rd_o             =  rd_o_reg;

//==============================================================================
// transmit data from id to ex
//==============================================================================
always @(posedge clk or negedge rst_n) begin
    if (rst_n == `RST_ACTIVE) begin
        // reset
        pc_o_reg            <=  `ZERO;
        branch_jump_o_reg   <=  `BJ_DIS;
        alu_src_o_reg       <=  `ALU_SRC_REG;
        alu_op_o_reg        <=  `ALU_ADD;
        mem_write_o_reg     <=  `MEM_WR_DIS;
        mem_read_o_reg      <=  `MEM_RD_DIS;
        mem_mode_o_reg      <=  `MEM_BYTE;
        mem_to_reg_o_reg    <=  `MEMREG_DIS;
        reg_write_o_reg     <=  `REG_WR_DIS;
        reg_rdata1_o_reg    <=  `REG_S1RD_DIS;
        reg_rdata2_o_reg    <=  `REG_S2RD_DIS;
        imm_o_reg           <=  `ZERO;
        rs1_o_reg           <=  `R_ZERO;
        rs2_o_reg           <=  `R_ZERO;
        rd_o_reg            <=  `R_ZERO;
    end

    else begin
        pc_o_reg            <=  pc_i;
        branch_jump_o_reg   <=  branch_jump_i;
        alu_src_o_reg       <=  alu_src_i;
        alu_op_o_reg        <=  alu_op_i;
        mem_write_o_reg     <=  mem_write_i;
        mem_read_o_reg      <=  mem_read_i;
        mem_mode_o_reg      <=  mem_mode_i;
        mem_to_reg_o_reg    <=  mem_to_reg_i;
        reg_write_o_reg     <=  reg_write_i;
        reg_rdata1_o_reg    <=  reg_rdata1_i;
        reg_rdata2_o_reg    <=  reg_rdata2_i;
        imm_o_reg           <=  imm_i;
        rs1_o_reg           <=  rs1_i;
        rs2_o_reg           <=  rs2_i;
        rd_o_reg            <=  rd_i;
    end
end

endmodule