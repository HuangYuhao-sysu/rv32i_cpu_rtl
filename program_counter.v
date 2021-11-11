// =============================================================================
// Project Name        : rv32i cpu
// Email               : huangyh76@mail2.sysu.edu.cn
// Company             : Sun Yat-Sen University
// Create Time         : 2021/11/01
// File Name           : program_counter.v
// Module Name         : program_counter
// Designer            : Huangyh
// Editor              : vs code
//
// *****************************************************************************
// Abstract            : program_counter, sequential logic, architecture
//                          state program_counter store.
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

module program_counter (
    input                       clk,
    // Asynchronous reset active low
    input                       rst_n,

    input   [`PC_WIDTH-1:0]     target_pc,
    input                       pc_src,

    input                       stall,

    output  [`PC_WIDTH-1:0]     pc
);

// =========================================================================== \
// ============================= Internal signals ============================
// =========================================================================== /
reg [`PC_WIDTH-1:0] pc_reg;

// =========================================================================== \
// --------------------------------- Main Code ---------------------------------
// =========================================================================== /

//==============================================================================
// output reg assogm
//==============================================================================
assign pc = pc_reg;

always @(posedge clk or negedge rst_n) begin
    if (rst_n == `RST_ACTIVE) begin
        // reset
        pc_reg  <=  `ZERO;
    end

    // if ADD/LOAD and B data hardzard happended, we need to stall pipeline for 
    // one or two cycles, at this time, stall signal and pc_src signal will
    // active simultaneously. so stall priority is higher than pc src.
    else if (stall == `STALL_EN) begin
        pc_reg  <=  pc_reg;
    end

    // branch and jump target pc
    else if (pc_src == `PC_SRC_BJ) begin
        pc_reg  <=  target_pc;
    end

    // 4 byte access, pc + 4
    else begin
        pc_reg  <=  pc_reg + `PC_INCREMT;
    end
end

endmodule