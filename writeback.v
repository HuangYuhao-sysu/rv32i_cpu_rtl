// =============================================================================
// Project Name        : rv32i cpu
// Email               : huangyh76@mail2.sysu.edu.cn
// Company             : Sun Yat-Sen University
// Create Time         : 2021/11/02
// File Name           : writeback.v
// Module Name         : writeback
// Designer            : Huangyh
// Editor              : vs code
//
// *****************************************************************************
// Abstract            : write back to reg stage. comb logic, provide data
//                          enable, addr signals to regfile.
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

module writeback (
    input                       mem_to_reg,
    input   [`RADDR_WIDTH-1:0]  rd,
    input   [`DATA_WIDTH-1:0]   alu_result,
    input                       reg_web,
    input   [`DATA_WIDTH-1:0]   mem_rdata,

    output                      reg_write,  // reg write enable signal
    output  [`RADDR_WIDTH-1:0]  reg_waddr,  // 5bit regfile address

    // according mem_to_reg select alu_result or mem_rdata.
    output  [`DATA_WIDTH-1:0]   reg_wdata
);

// =========================================================================== \
// ============================= Internal signals ============================
// =========================================================================== /
reg                     reg_write_reg;
reg [`RADDR_WIDTH-1:0]  reg_waddr_reg;
reg [`DATA_WIDTH-1:0]   reg_wdata_reg;

// =========================================================================== \
// --------------------------------- Main Code ---------------------------------
// =========================================================================== /

//==============================================================================
// output reg assign
//==============================================================================
assign reg_write = reg_write_reg;
assign reg_waddr = reg_waddr_reg;
assign reg_wdata = reg_wdata_reg;

//==============================================================================
// reg write decode
//==============================================================================
always @(*) begin
    if (reg_web == `REG_WR_EN) begin
        reg_write_reg   =   `REG_WR_EN;
    end

    else begin
        reg_write_reg   =   `REG_WR_DIS;
    end
end

//==============================================================================
// reg write address decode
//==============================================================================
always @(*) begin
    if (reg_web == `REG_WR_EN) begin
        reg_waddr_reg   =   rd;
    end

    else begin
        reg_waddr_reg   =   `R_ZERO;
    end
end

//==============================================================================
// reg write data decode
//==============================================================================
always @(*) begin
    if (reg_web == `REG_WR_EN) begin
        if (mem_to_reg == `MEMREG_EN) begin
            reg_wdata_reg   =   mem_rdata;
        end

        else begin
            reg_wdata_reg   =   alu_result;
        end
    end

    else begin
        reg_wdata_reg   =   `ZERO;
    end
end

endmodule