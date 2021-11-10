// =============================================================================
// Project Name        : rv32i cpu
// Email               : huangyh76@mail2.sysu.edu.cn
// Company             : Sun Yat-Sen University
// Create Time         : 2021/11/02
// File Name           : cpu_state_mux.v
// Module Name         : cpu_state_mux
// Designer            : Huangyh
// Editor              : vs code
//
// *****************************************************************************
// Abstract            : this module mux the cpu state reg like pc, icache, reg,
//                      dcache. determine if their control and data signals from
//                      io_control module or from cpu itself. comb logic.
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

module cpu_state_mux (
    // 5 states debug mode
    input   [`DEBUG_WIDTH-1:0]  debug,

    // from internal if
    input                       int_icache_ceb,
    input                       int_icache_web,
    input   [`IADDR_WIDTH-1:0]  int_icache_addr,
    // from external io
    input                       ext_icache_ceb,
    input                       ext_icache_web,
    input   [`IADDR_WIDTH-1:0]  ext_icache_addr,

    // from internal control signals, id
    input                       int_reg_read2,
    input   [`RADDR_WIDTH-1:0]  int_reg_rs2,
    // from external, read reg. just use addr2 reg read port
    input                       ext_reg_read2,
    input   [`RADDR_WIDTH-1:0]  ext_reg_rs2,

    // from internal mem
    input                       int_dcache_ceb,
    input                       int_dcache_web,
    input   [`DATA_WIDTH-1:0]   int_dcache_bweb,
    input   [`DADDR_WIDTH-1:0]  int_dcache_addr,
    // from external io
    input                       ext_dcache_ceb,
    input                       ext_dcache_web,
    input   [`DATA_WIDTH-1:0]   ext_dcache_bweb,
    input   [`DADDR_WIDTH-1:0]  ext_dcache_addr,

    // to icache
    output                      icache_ceb,
    output                      icache_web,
    output  [`IADDR_WIDTH-1:0]  icache_addr,

    // to regfile read port2
    output                      reg_read2,
    output  [`RADDR_WIDTH-1:0]  reg_rs2,

    // to dcache
    output                      dcache_ceb,
    output                      dcache_web,
    output  [`DATA_WIDTH-1:0]   dcache_bweb,
    output  [`DADDR_WIDTH-1:0]  dcache_addr
);

// =========================================================================== \
// ============================= Internal signals ============================
// =========================================================================== /
reg                     icache_ceb_reg;
reg                     icache_web_reg;
reg [`IADDR_WIDTH-1:0]  icache_addr_reg;
reg                     reg_read2_reg;
reg [`RADDR_WIDTH-1:0]  reg_rs2_reg;
reg                     dcache_ceb_reg;
reg                     dcache_web_reg;
reg [`DATA_WIDTH-1:0]   dcache_bweb_reg;
reg [`DADDR_WIDTH-1:0]  dcache_addr_reg;

// =========================================================================== \
// --------------------------------- Main Code ---------------------------------
// =========================================================================== /

//==============================================================================
// output reg assign
//==============================================================================
assign icache_ceb   = icache_ceb_reg;
assign icache_web   = icache_web_reg;
assign icache_addr  = icache_addr_reg;
assign reg_read2    = reg_read2_reg;
assign reg_rs2      = reg_rs2_reg;
assign dcache_ceb   = dcache_ceb_reg;
assign dcache_web   = dcache_web_reg;
assign dcache_bweb  = dcache_bweb_reg;
assign dcache_addr  = dcache_addr_reg;

//==============================================================================
// i cache select
//==============================================================================
always @(*) begin
    if (debug == `DEBUG_ICRD || debug == `DEBUG_ICWR) begin
        icache_ceb_reg  =   ext_icache_ceb;
        icache_web_reg  =   ext_icache_web;
        icache_addr_reg =   ext_icache_addr;
    end

    else begin
        icache_ceb_reg  =   int_icache_ceb;
        icache_web_reg  =   int_icache_web;
        icache_addr_reg =   int_icache_addr;
    end
end

//==============================================================================
// reg2 select
//==============================================================================
always @(*) begin
    if (debug == `DEBUG_REGRD) begin
        reg_read2_reg   =   ext_reg_read2;
        reg_rs2_reg     =   ext_reg_rs2;
    end

    else begin
        reg_read2_reg   =   int_reg_read2;
        reg_rs2_reg     =   int_reg_rs2;
    end
end

//==============================================================================
// d cache select
//==============================================================================
always @(*) begin
    if (debug == `DEBUG_DCRD) begin
        dcache_ceb_reg  =   ext_dcache_ceb;
        dcache_web_reg  =   ext_dcache_web;
        dcache_bweb_reg =   ext_dcache_bweb;
        dcache_addr_reg =   ext_dcache_addr;
    end

    else begin
        dcache_ceb_reg  =   int_dcache_ceb;
        dcache_web_reg  =   int_dcache_web;
        dcache_bweb_reg =   int_dcache_bweb;
        dcache_addr_reg =   int_dcache_addr;
    end
end

endmodule