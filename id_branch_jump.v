// =============================================================================
// Project Name        : rv32i cpu
// Email               : huangyh76@mail2.sysu.edu.cn
// Company             : Sun Yat-Sen University
// Create Time         : 2021/11/01
// File Name           : id_branch_jump.v
// Module Name         : id_branch_jump
// Designer            : Huangyh
// Editor              : vs code
//
// *****************************************************************************
// Abstract            : jump and branch execute in this module for less flush
//                      bubbles, jump and link need to write pc + 4 to rd, this
//                      operation done in ex stage. comb logic.
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

module id_branch_jump (
    input                       alu_src,
    input   [`ALUOP_WIDTH-1:0]  alu_op,
    input                       branch_jump,

    input   [`PC_WIDTH-1:0]     current_pc,

    // rs1 and rs2 from id module
    input   [`RADDR_WIDTH-1:0]  id_reg_rs1,
    input   [`RADDR_WIDTH-1:0]  id_reg_rs2,
    // for exmem dataforwarding
    input   [`RADDR_WIDTH-1:0]  exmem_reg_dest,
    // for memwb dataforwarding
    input   [`RADDR_WIDTH-1:0]  memwb_reg_dest,
    input                       exmem_reg_write,
    input                       memwb_reg_write,
    // data for forwarding
    input   [`DATA_WIDTH-1:0]   exmem_reg_wdata,
    input   [`DATA_WIDTH-1:0]   wb_reg_wdata,

    // branch and jump need data
    input   [`DATA_WIDTH-1:0]   reg_rdata1,
    input   [`DATA_WIDTH-1:0]   reg_rdata2,
    input   [`DATA_WIDTH-1:0]   imm,

    output  [`PC_WIDTH-1:0]     target_pc,
    output                      flush_pipeline,
    output                      pc_src
);

// =========================================================================== \
// ============================= Internal signals ============================
// =========================================================================== /
reg     [`PC_WIDTH-1:0]     target_pc_reg;
reg                         flush_pipeline_reg;
reg                         pc_src_reg;

wire    [`DATA_WIDTH-1:0]   operand1;
reg     [`DATA_WIDTH-1:0]   operand2;
reg     [`DATA_WIDTH-1:0]   forwarding_rs1;
reg     [`DATA_WIDTH-1:0]   forwarding_rs2;
reg     [`DATA_WIDTH-1:0]   alu_result;
reg                         branch_flag;

// =========================================================================== \
// --------------------------------- Main Code ---------------------------------
// =========================================================================== /

//==============================================================================
// output reg assign
//==============================================================================
assign target_pc        = target_pc_reg;
assign flush_pipeline   = flush_pipeline_reg;
assign pc_src           = pc_src_reg;

//==============================================================================
// data forwarding for rs1
//==============================================================================
always @(*) begin
    if (exmem_reg_write == `REG_WR_EN && 
        (exmem_reg_dest != `R_ZERO) &&
        (exmem_reg_dest == id_reg_rs1)) begin
        forwarding_rs1  =   exmem_reg_wdata;
    end

    else if (memwb_reg_write == `REG_WR_EN && 
            (memwb_reg_dest != `R_ZERO) &&
            (memwb_reg_dest == id_reg_rs1)) begin
        forwarding_rs1  =   wb_reg_wdata;
    end

    else begin
        forwarding_rs1  =   reg_rdata1;
    end
end

//==============================================================================
// data forwarding for rs2
//==============================================================================
always @(*) begin
    if (exmem_reg_write == `REG_WR_EN && 
        (exmem_reg_dest != `R_ZERO) &&
        (exmem_reg_dest == id_reg_rs2)) begin
        forwarding_rs2  =   exmem_reg_wdata;
    end

    else if (memwb_reg_write == `REG_WR_EN && 
            (memwb_reg_dest != `R_ZERO) &&
            (memwb_reg_dest == id_reg_rs2)) begin
        forwarding_rs2  =   wb_reg_wdata;
    end

    else begin
        forwarding_rs2  =   reg_rdata2;
    end
end

//==============================================================================
// operand selected
//==============================================================================
assign operand1 = forwarding_rs1;

always @(*) begin
    if (alu_src == `ALU_SRC_IMM) begin
        operand2    =   imm;
    end

    else begin
        operand2    =   forwarding_rs2;
    end
end

//==============================================================================
// branch flag
//==============================================================================
always @(*) begin
    case (alu_op)
        `ALU_EQ:    branch_flag =   (operand1 == operand2);
        `ALU_NEQ:   branch_flag =   (operand1 != operand2);
        `ALU_LT:    begin   // signed less than
                    branch_flag =   ({~operand1[31],operand1[30:0]} <
                                    {~operand2[31],operand2[30:0]});
        end
        `ALU_GE:    begin   // signed greater and equal than
                    branch_flag =   ({~operand1[31],operand1[30:0]} >=
                                    {~operand2[31],operand2[30:0]});
        end
        `ALU_LTU:   branch_flag =   (operand1 < operand2);
        `ALU_GEU:   branch_flag =   (operand1 >= operand2);
        default :   branch_flag =   `BJ_DIS;
    endcase
end

//==============================================================================
// target pc calculate
//==============================================================================
always @(*) begin
    if (branch_jump == `BJ_EN) begin
        target_pc_reg   =   (current_pc + imm) & 32'hfffffffe;
    end

    else begin
        target_pc_reg   =   `ZERO;
    end
end

//==============================================================================
// flush pipeline selected, when need to jump or branch, flush active
//==============================================================================
always @(*) begin
    if (branch_jump == `BJ_EN) begin
        if (alu_op == `ALU_ADDPC) begin
            flush_pipeline_reg  =   `FLUSH_EN;      // jump type
        end

        else begin
            flush_pipeline_reg  =   branch_flag;    // branch type
        end
    end

    else begin
        flush_pipeline_reg  =   `FLUSH_DIS;
    end
end

//==============================================================================
// pc_src selected, select pc + 4 or target pc. Is same to flush signal.
//==============================================================================
always @(*) begin
    if (branch_jump == `BJ_EN) begin
        if (alu_op == `ALU_ADDPC) begin
            pc_src_reg  =   `PC_SRC_BJ;  // jump type
        end

        else begin
            pc_src_reg  =   branch_flag;    // branch type
        end
    end

    else begin
        pc_src_reg  =   `PC_SRC_ADD4;
    end
end

endmodule