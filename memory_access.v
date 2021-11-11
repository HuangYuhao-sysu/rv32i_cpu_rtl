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

    // addr is 32bits, this module will convert it to a suitable value for 
    // memory, also cpu generate 4 bytes aligned address, this module convert
    // it to memory real address for VIVADO IP BRAM is 32bit width for one
    // address.
    input   [`DATA_WIDTH-1:0]       mem_addr,

    input   [`MEM_MODE_WIDTH-1:0]   mem_mode,
    input                           mem_write,
    input                           mem_read,

    output  [`DADDR_WIDTH-1:0]      dcache_addr,
    output                          dcache_ceb,
    output  [`DBWEB_WIDTH-1:0]      dcache_bweb,
    output  [`DATA_WIDTH-1:0]       dcache_wdata
);

// =========================================================================== \
// ============================= Internal signals ============================
// =========================================================================== /
reg [`DADDR_WIDTH-1:0]  dcache_addr_reg;
reg                     dcache_ceb_reg;
reg [`DBWEB_WIDTH-1:0]  dcache_bweb_reg;
reg [`DATA_WIDTH-1:0]   dcache_wdata_reg;

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

//==============================================================================
// dcache addr decode
//==============================================================================
always @(*) begin
    //  pyhsical address, directly discard out of range bits.
    if (mem_write == `MEM_WR_EN || mem_read == `MEM_RD_EN) begin
        dcache_addr_reg =   (mem_addr[`DADDR_WIDTH-1:0] >> 2);
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
            `MEM_BYTE:  begin
                case (mem_addr[1:0])    // for memory is 32bits once depth
                    2'b00:      dcache_bweb_reg     =   `DC_BWEB_BYTE0;
                    2'b01:      dcache_bweb_reg     =   `DC_BWEB_BYTE1;
                    2'b10:      dcache_bweb_reg     =   `DC_BWEB_BYTE2;
                    2'b11:      dcache_bweb_reg     =   `DC_BWEB_BYTE3;
                endcase
            end
            `MEM_HWORD: begin
                case (mem_addr[1:0])    // don't support write middle 2bytes
                    2'b00:      dcache_bweb_reg     =   `DC_BWEB_HWORD0;
                    2'b10:      dcache_bweb_reg     =   `DC_BWEB_HWORD2;
                    default :   dcache_bweb_reg     =   `DC_BWEB_DIS;
                endcase
            end
            `MEM_WORD:  dcache_bweb_reg =   `DC_BWEB_WORD;
            default :   dcache_bweb_reg =   `DC_BWEB_DIS;
        endcase
    end

    else begin
        dcache_bweb_reg =   `DC_BWEB_DIS;
    end
end

//==============================================================================
// dcache write data decode
//==============================================================================
always @(*) begin
    if (mem_write == `MEM_WR_EN) begin
        case (mem_mode)
            `MEM_BYTE:  begin
                case (mem_addr[1:0])
                    2'b00:  dcache_wdata_reg    =   mem_wdata;
                    2'b01:  dcache_wdata_reg    =   mem_wdata << 8;
                    2'b10:  dcache_wdata_reg    =   mem_wdata << 16;
                    2'b11:  dcache_wdata_reg    =   mem_wdata << 24;
                endcase
            end
            `MEM_HWORD: begin
                case (mem_addr[1:0])
                    2'b00:  dcache_wdata_reg    =   mem_wdata;
                    2'b10:  dcache_wdata_reg    =   mem_wdata << 16;
                    default : dcache_wdata_reg  =   `ZERO;
                endcase
            end
            `MEM_WORD:  begin
                dcache_wdata_reg    =   mem_wdata;
            end
            default :   dcache_wdata_reg    =   `ZERO;
        endcase
    end

    else begin
        dcache_wdata_reg    =   `ZERO;
    end
end

endmodule