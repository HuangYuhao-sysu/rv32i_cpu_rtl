// =============================================================================
// Project Name        : rv32i cpu
// Email               : huangyh76@mail2.sysu.edu.cn
// Company             : Sun Yat-Sen University
// Create Time         : 2021/11/02
// File Name           : async_rst.v
// Module Name         : async_rst
// Designer            : Huangyh
// Editor              : vs code
//
// *****************************************************************************
// Abstract            : async rst, sync release,different clock domin need
//                      different async rst module.
// *****************************************************************************
//
// Modification History:
// Date                By              Version             Change Description
// -----------------------------------------------------------------------------
// 2021/11/02       Huangyh             1.0                         none
//
// =============================================================================

`timescale 1ns / 1ps
`include "define.vh"

module async_rst (
    input   clk,        // Clock
    input   rst_n_i,    // Asynchronous reset active low
    output  rst_n_o     // async reset with two DFF sync
);

// =========================================================================== \
// ============================= Internal signals ============================
// =========================================================================== /
reg sync_reg0;
reg sync_reg1;

// =========================================================================== \
// --------------------------------- Main Code ---------------------------------
// =========================================================================== /
assign rst_n_o = sync_reg1;

always @(posedge clk or negedge rst_n_i) begin
    if (rst_n_i == `RST_ACTIVE) begin
        // reset
        sync_reg0 <= `RST_ACTIVE;
    end

    else begin
        sync_reg0 <= `RST_RELEASE;
    end
end

always @(posedge clk or negedge rst_n_i) begin
    if (rst_n_i == `RST_ACTIVE) begin
        // reset
        sync_reg1 <= `RST_ACTIVE;
    end

    else begin
        sync_reg1 <= sync_reg0;
    end
end

endmodule