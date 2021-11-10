// =============================================================================
// Project Name        : async_cscd_cpu
// Email               : huangyh76@mail2.sysu.edu.cn
// Company             : Sun Yat-Sen University
// Create Time         : 2021/11/02
// File Name           : memory_access.v
// Module Name         : memory_access
// Designer            : Huangyh
// Editor              : vs code
//
// *****************************************************************************
// Abstract            : mem stage, handle the memory access including write
//                          and read. combinational logic.
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

module memory_access (
    input   [`DATA_WIDTH-1:0]       mem_wdata,

    // addr is 32bits, this module will convert it to a suitable value for memory
    input   [`DATA_WIDTH-1:0]       mem_addr,

    input   [`MEM_MODE_WIDTH-1:0]   mem_mode,
    input                           mem_write,
    input                           mem_read,

    input   [`DATA_WIDTH-1:0]       dcache_rdata,

    output  [`DADDR_WIDTH-1:0]      dcache_addr,
    output                          dcache_ceb,
    output  [`DBWEB_WIDTH-1:0]      dcache_bweb,
    output  [`DATA_WIDTH-1:0]       dcache_wdata,

    output  [`DATA_WIDTH-1:0]       mem_rdata   // read data to reg, LOAD
);

// =========================================================================== \
// ============================= Internal signals ============================
// =========================================================================== /
reg [`DADDR_WIDTH-1:0]  dcache_addr_reg;
reg                     dcache_ceb_reg;
reg [`DBWEB_WIDTH-1:0]  dcache_bweb_reg;
reg [`DATA_WIDTH-1:0]   dcache_wdata_reg;
reg [`DATA_WIDTH-1:0]   mem_rdata_reg;

// =========================================================================== \
// --------------------------------- Main Code ---------------------------------
// =========================================================================== /

//==============================================================================
// output reg assign
//==============================================================================
assign  dcache_addr     =   dcache_addr_reg;
assign  dcache_ceb      =   dcache_ceb_reg;
assign  dcache_bweb     =   dcache_bweb_reg;
assign  dcache_wdata    =   dcache_wdata_reg;
assign  mem_rdata       =   mem_rdata_reg;

//==============================================================================
// dcache addr decode
//==============================================================================
always @(*) begin
    //  pyhsical address, directly discard out of range bits.
    if (mem_write == `MEM_WR_EN || mem_read == `MEM_RD_EN) begin
        dcache_addr_reg =   mem_addr[`DADDR_WIDTH-1:0];
    end

    else begin
        dcache_addr_reg =   `DADDR_ZERO;
    end
end

//==============================================================================
// dcache chip enable decode
//==============================================================================
always @(*) begin
    if (mem_write == `MEM_WR_EN || mem_read == `MEM_RD_EN) begin
        dcache_ceb_reg  =   `CHIP_EN;
    end

    else begin
        dcache_ceb_reg  =   `CHIP_DIS;
    end
end

//==============================================================================
// dcache byte write enable decode
//==============================================================================
always @(*) begin
    if (mem_write == `MEM_WR_EN) begin
        case (mem_mode)
            `MEM_BYTE:  dcache_bweb_reg =   `CHIP_BWEB_BYTE;
            `MEM_HWORD: dcache_bweb_reg =   `CHIP_BWEB_HWORD;
            `MEM_WORD:  dcache_bweb_reg =   `CHIP_BWEB_WORD;
            default :   dcache_bweb_reg =   `CHIP_BWEB_DIS;
        endcase
    end

    else begin
        dcache_bweb_reg =   `CHIP_BWEB_DIS;
    end
end

//==============================================================================
// dcache write data decode
//==============================================================================
always @(*) begin
    if (mem_write == `MEM_WR_EN) begin
        dcache_wdata_reg    =   mem_wdata;
    end

    else begin
        dcache_wdata_reg    =   `ZERO;
    end
end

//==============================================================================
// dcache memory read data decode
//==============================================================================
always @(*) begin
    if (mem_read == `MEM_RD_EN) begin
        case (mem_mode)
            // signed extend one byte
            `MEM_BYTE:      mem_rdata_reg   =   {{24{dcache_rdata[7]}},
                                                dcache_rdata[0+:8]};
                                                
            // signed extend half word
            `MEM_HWORD:     mem_rdata_reg   =   {{16{dcache_rdata[15]}},
                                                dcache_rdata[0+:16]};
            
            // signed extend word
            `MEM_WORD:      mem_rdata_reg   =   dcache_rdata;
            
            // unsigned extend
            `MEM_BYTEU:     mem_rdata_reg   =   {24'd0,dcache_rdata[0+:8]};
            `MEM_HWORDU:    mem_rdata_reg   =   {16'd0,dcache_rdata[0+:16]};
            default :       mem_rdata_reg   =   `ZERO;
        endcase
    end

    else begin
        mem_rdata_reg   =   `ZERO;
    end
end

endmodule