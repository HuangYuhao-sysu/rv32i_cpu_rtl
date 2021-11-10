// =============================================================================
// Project Name        : rv32i cpu
// Email               : huangyh76@mail2.sysu.edu.cn
// Company             : Sun Yat-Sen University
// Create Time         : 2021/11/02
// File Name           : io_control.v
// Module Name         : io_control
// Designer            : Huangyh
// Editor              : vs code
//
// *****************************************************************************
// Abstract            : control external operation to cpu, including read pc,
//                      write icache, read icache, read reg, read dcache. 
//                      sequential logic
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

module io_control (
    input                       clk,    // Clock
    input                       rst_n,  // Asynchronous reset active low

    input   [`DEBUG_WIDTH-1:0]  debug,

    input   [`PC_WIDTH-1:0]     pc_i,           // read from pc
    input   [`DATA_WIDTH-1:0]   icache_rdata_i, // read from icache
    input   [`DATA_WIDTH-1:0]   reg_rdata_i,    // read from reg2
    input   [`DATA_WIDTH-1:0]   dcache_rdata_i, // read from dcache

    input   [`IADDR_WIDTH-1:0]  icache_addr_i,  // from external io
    input   [`DATA_WIDTH-1:0]   icache_wdata_i,

    input   [`RADDR_WIDTH-1:0]  reg_raddr_i,    // from external io

    input   [`DADDR_WIDTH-1:0]  dcache_raddr_i, // external io to read dcache

    output  [`PC_WIDTH-1:0]     pc_o,           // to external io
    output  [`DATA_WIDTH-1:0]   icache_rdata_o,
    output  [`DATA_WIDTH-1:0]   reg_rdata_o,
    output  [`DATA_WIDTH-1:0]   dcache_rdata_o,

    output  [`IADDR_WIDTH-1:0]  icache_addr_o,  // to read or write icache
    output                      icache_ceb_o,
    output                      icache_web_o,
    output  [`DATA_WIDTH-1:0]   icache_wdata_o,

    output  [`RADDR_WIDTH-1:0]  reg_raddr_o,    // to read reg
    output                      reg_read_o,

    output  [`DADDR_WIDTH-1:0]  dcache_raddr_o, // to read dcache
    output                      dcache_ceb_o,
    output  [`DBWEB_WIDTH-1:0]  dcache_bweb_o
);

// =========================================================================== \
// ============================= Internal signals ============================
// =========================================================================== /
reg [`PC_WIDTH-1:0]     pc_o_reg;
reg [`DATA_WIDTH-1:0]   icache_rdata_o_reg;
reg [`DATA_WIDTH-1:0]   reg_rdata_o_reg;
reg [`DATA_WIDTH-1:0]   dcache_rdata_o_reg;
reg [`IADDR_WIDTH-1:0]  icache_addr_o_reg;
reg                     icache_ceb_o_reg;
reg                     icache_web_o_reg;
reg [`DATA_WIDTH-1:0]   icache_wdata_o_reg;
reg [`RADDR_WIDTH-1:0]  reg_raddr_o_reg;
reg                     reg_read_o_reg;
reg [`DADDR_WIDTH-1:0]  dcache_raddr_o_reg;
reg                     dcache_ceb_o_reg;
reg [`DBWEB_WIDTH-1:0]  dcache_bweb_o_reg;

// =========================================================================== \
// --------------------------------- Main Code ---------------------------------
// =========================================================================== /

//==============================================================================
// output reg assign
//==============================================================================
assign pc_o             = pc_o_reg;
assign icache_rdata_o   = icache_rdata_o_reg;
assign reg_rdata_o      = reg_rdata_o_reg;
assign dcache_rdata_o   = dcache_rdata_o_reg;
assign icache_addr_o    = icache_addr_o_reg;
assign icache_ceb_o     = icache_ceb_o_reg;
assign icache_web_o     = icache_web_o_reg;
assign icache_wdata_o   = icache_wdata_o_reg;
assign reg_raddr_o      = reg_raddr_o_reg;
assign reg_read_o       = reg_read_o_reg;
assign dcache_raddr_o   = dcache_raddr_o_reg;
assign dcache_ceb_o     = dcache_ceb_o_reg;
assign dcache_bweb_o    = dcache_bweb_o_reg;

//==============================================================================
// debug mode, pc select
//==============================================================================
always @(posedge clk or negedge rst_n) begin
    if (rst_n == `RST_ACTIVE) begin
        // reset
        pc_o_reg    <= `ZERO;
    end

    else if (debug == `DEBUG_PCRD) begin
        pc_o_reg    <= pc_i;
    end
end

//==============================================================================
// debug mode, i cache select
//==============================================================================
always @(posedge clk or negedge rst_n) begin
    if (rst_n == `RST_ACTIVE) begin
        // reset
        icache_rdata_o_reg  <=  `ZERO;
        icache_addr_o_reg   <=  `IADDR_ZERO;
        icache_ceb_o_reg    <=  `CHIP_DIS;
        icache_web_o_reg    <=  `CHIP_WDIS;
        icache_wdata_o_reg  <=  `ZERO;
    end

    else if (debug == `DEBUG_ICRD) begin
        icache_rdata_o_reg  <=  icache_rdata_i;
        icache_addr_o_reg   <=  icache_addr_i;
        icache_ceb_o_reg    <=  `CHIP_EN;
        icache_web_o_reg    <=  `CHIP_WDIS;
        icache_wdata_o_reg  <=  icache_wdata_o_reg;
    end

    else if (debug == `DEBUG_ICWR) begin
        icache_rdata_o_reg  <=  icache_rdata_o_reg;
        icache_addr_o_reg   <=  icache_addr_i;
        icache_ceb_o_reg    <=  `CHIP_EN;
        icache_web_o_reg    <=  `CHIP_WEN;
        icache_wdata_o_reg  <=  icache_wdata_i;
    end
end

//==============================================================================
// debug mode, reg read select
//==============================================================================
always @(posedge clk or negedge rst_n) begin
    if (rst_n == `RST_ACTIVE) begin
        // reset
        reg_rdata_o_reg     <=  `ZERO;
        reg_raddr_o_reg     <=  `R_ZERO;
        reg_read_o_reg      <=  `REG_S2RD_DIS;
    end

    else if (debug == `DEBUG_REGRD) begin
        reg_rdata_o_reg     <=  reg_rdata_i;
        reg_raddr_o_reg     <=  reg_raddr_i;
        reg_read_o_reg      <=  `REG_S2RD_EN;
    end
end

//==============================================================================
// debug mode, d cache read select
//==============================================================================
always @(posedge clk or negedge rst_n) begin
    if (rst_n == `RST_ACTIVE) begin
        // reset
        dcache_rdata_o_reg  <=  `ZERO;
        dcache_raddr_o_reg  <=  `DADDR_ZERO;
        dcache_ceb_o_reg    <=  `CHIP_DIS;
        dcache_bweb_o_reg   <=  `CHIP_BWEB_DIS;
    end

    else if (debug == `DEBUG_DCRD) begin
        dcache_rdata_o_reg  <=  dcache_rdata_i;
        dcache_raddr_o_reg  <=  dcache_raddr_i;
        dcache_ceb_o_reg    <=  `CHIP_EN;
        dcache_bweb_o_reg   <=  `CHIP_BWEB_DIS;
    end
end

endmodule