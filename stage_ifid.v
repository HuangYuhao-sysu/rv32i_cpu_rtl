// =============================================================================
// Project Name        : rv32i cpu
// Email               : huangyh76@mail2.sysu.edu.cn
// Company             : Sun Yat-Sen University
// Create Time         : 2021/11/01
// File Name           : stage_ifid.v
// Module Name         : stage_ifid
// Designer            : Huangyh
// Editor              : vs code
//
// *****************************************************************************
// Abstract            : sequential logic, if to id, input port with _i postfix,
//                      output port with _o postfix.
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

module stage_ifid (
    input                       clk,
    input                       rst_n,

    input   [`PC_WIDTH-1:0]     current_pc_i,
    input   [`DATA_WIDTH-1:0]   instruction_i,

    // stall for data hazard, like ADD after LOAD, BRANCH after ADD or LOAD.
    input                       stall,

    // flush and next inst is NOP, when B and J.
    input                       flush,

    output  [`PC_WIDTH-1:0]     current_pc_o,
    output  [`DATA_WIDTH-1:0]   instruction_o
);

// =========================================================================== \
// ============================= Internal signals ============================
// =========================================================================== /
reg [`PC_WIDTH-1:0]     current_pc_o_reg;
reg [`DATA_WIDTH-1:0]   instruction_o_reg;

// =========================================================================== \
// --------------------------------- Main Code ---------------------------------
// =========================================================================== /

//==============================================================================
// output reg assign
//==============================================================================
assign current_pc_o = current_pc_o_reg;
assign instruction_o = instruction_o_reg;

//==============================================================================
// data transmit
//==============================================================================
always @(posedge clk or negedge rst_n) begin
    if (rst_n == `RST_ACTIVE) begin
        // reset
        current_pc_o_reg    <=  `ZERO;
    end

    // Regardless of stall and flush， pc always get the input pc， when stall，
    // pc module will handle the real pc value. but for lower power gating
    // design. we should use stall and flush as clock gating enable signals.
    else if (stall == `STALL_EN || flush == `FLUSH_EN) begin
        current_pc_o_reg    <=  current_pc_o_reg;
    end
    
    else begin
        current_pc_o_reg    <=  current_pc_i;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (rst_n == `RST_ACTIVE) begin
        // reset
        instruction_o_reg   <=  `ZERO;
    end

    // stall caused by data hazard, flush caused by jump or branch. stall need
    // to hold the same instruction. 
    else if (stall == `STALL_EN) begin
        instruction_o_reg   <=  instruction_o_reg;
    end

    // flush is different, flush transmit NOP to avoid old instruction's affect.
    else if (flush == `FLUSH_EN) begin
        instruction_o_reg   <=  `NOP;
    end

    else begin
        instruction_o_reg   <=  instruction_i;
    end
end

endmodule