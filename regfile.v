// =============================================================================
// Project Name        : rv32i cpu
// Email               : huangyh76@mail2.sysu.edu.cn
// Company             : Sun Yat-Sen University
// Create Time         : 2021/10/28
// File Name           : regfile.v
// Module Name         : regfile
// Designer            : Huangyh
// Editor              : vs code
//
// *****************************************************************************
// Abstract            : regfile of cpu ,32 * 32bits
//
// *****************************************************************************
//
// Modification History:
// Date                By              Version             Change Description
// -----------------------------------------------------------------------------
// 2021/10/28       Huangyh             1.0                         none
//
// =============================================================================

`timescale 1ns / 1ps
`include "define.vh"

module regfile (
    input                       clk,    // Clock
    input                       rst_n,  // Asynchronous reset active low

    // rs1, rs2 addr for 32 depth
    input   [`RADDR_WIDTH-1:0]  rs1_addr,
    input   [`RADDR_WIDTH-1:0]  rs2_addr,
    input                       rs1_en, // enable signals
    input                       rs2_en,

    // write data and write enable signals
    input   [`RADDR_WIDTH-1:0]  waddr,
    input   [`DATA_WIDTH-1:0]   wdata,
    input                       wen, //active high

    // read data of rs1 and rs2
    output  [`DATA_WIDTH-1:0]   rs1_data,
    output  [`DATA_WIDTH-1:0]   rs2_data
);

// =========================================================================== \
// ============================= Internal signals ============================
// =========================================================================== /
reg [`DATA_WIDTH-1:0]   regfile [0:`REG_NUM-1];
reg [`DATA_WIDTH-1:0]   rs1_data_reg;
reg [`DATA_WIDTH-1:0]   rs2_data_reg;

integer                 i;  // for loop variable

// =========================================================================== \
// --------------------------------- Main Code ---------------------------------
// =========================================================================== /

//==============================================================================
// output reg assign
//==============================================================================
assign rs1_data = rs1_data_reg;
assign rs2_data = rs2_data_reg;

//==============================================================================
// write logic, sync, rst, regfile[0] hardware connect to zero
//==============================================================================
always @(posedge clk or negedge rst_n) begin
    if (rst_n == `RST_ACTIVE) begin
        // reset
        for ( i = 0; i < `REG_NUM; i = i + 1) begin
            regfile[i] <= `ZERO;
        end
    end

    else if ((wen == `REG_WR_EN) && (waddr != `R_ZERO)) begin
        regfile[waddr] <= wdata;
    end
end

//==============================================================================
// read logic, comb
//==============================================================================
always @(*) begin
    if (rs1_en == `REG_S1RD_EN) begin
        rs1_data_reg = regfile[rs1_addr];
    end

    else begin
        rs1_data_reg = `ZERO;
    end
end

always @(*) begin
    if (rs2_en == `REG_S2RD_EN) begin
        rs2_data_reg = regfile[rs2_addr];
    end

    else begin
        rs2_data_reg = `ZERO;
    end
end

endmodule