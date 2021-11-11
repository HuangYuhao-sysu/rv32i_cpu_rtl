// =============================================================================
// Project Name        : rv32i cpu
// Email               : huangyh76@mail2.sysu.edu.cn
// Company             : Sun Yat-Sen University
// Create Time         : 2021/11/02
// File Name           : stage_memwb.v
// Module Name         : stage_memwb
// Designer            : Huangyh
// Editor              : vs code
//
// *****************************************************************************
// Abstract            : sequential logic, transmit data from mem to wb.
//
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

module stage_memwb (
    input                           clk,    // Clock
    input                           rst_n,  // Asynchronous reset active low

    input                           mem_read_i,
    input   [`MEM_MODE_WIDTH-1:0]   mem_mode_i,
    input                           mem_to_reg_i,
    input   [`RADDR_WIDTH-1:0]      rd_i,
    input   [`DATA_WIDTH-1:0]       alu_result_i,
    input                           reg_write_i,

    output                          mem_read_o,
    output  [`MEM_MODE_WIDTH-1:0]   mem_mode_o,
    output                          mem_to_reg_o,
    output  [`RADDR_WIDTH-1:0]      rd_o,
    output  [`DATA_WIDTH-1:0]       alu_result_o,
    output                          reg_write_o
);

// =========================================================================== \
// ============================= Internal signals ============================
// =========================================================================== /
reg                         mem_read_o_reg;
reg [`MEM_MODE_WIDTH-1:0]   mem_mode_o_reg;
reg                         mem_to_reg_o_reg;
reg [`RADDR_WIDTH-1:0]      rd_o_reg;
reg [`DATA_WIDTH-1:0]       alu_result_o_reg;
reg                         reg_write_o_reg;

// =========================================================================== \
// --------------------------------- Main Code ---------------------------------
// =========================================================================== /

//==============================================================================
// output reg assign
//==============================================================================
assign mem_read_o   =   mem_read_o_reg;
assign mem_mode_o   =   mem_mode_o_reg;
assign mem_to_reg_o =   mem_to_reg_o_reg;
assign rd_o         =   rd_o_reg;
assign alu_result_o =   alu_result_o_reg;
assign reg_write_o  =   reg_write_o_reg;

//==============================================================================
// transmit data from mem to wb
//==============================================================================
always @(posedge clk or negedge rst_n) begin
    if (rst_n == `RST_ACTIVE) begin
        // reset
        mem_read_o_reg      <=  `MEM_RD_DIS;
        mem_mode_o_reg      <=  `MEM_BYTE;
        mem_to_reg_o_reg    <=  `MEMREG_DIS;
        rd_o_reg            <=  `R_ZERO;
        alu_result_o_reg    <=  `ZERO;
        reg_write_o_reg     <=  `REG_WR_DIS;
    end

    else begin
        mem_read_o_reg      <=  mem_read_i;
        mem_mode_o_reg      <=  mem_mode_i;
        mem_to_reg_o_reg    <=  mem_to_reg_i;
        rd_o_reg            <=  rd_i;
        alu_result_o_reg    <=  alu_result_i;
        reg_write_o_reg     <=  reg_write_i;
    end
end

endmodule