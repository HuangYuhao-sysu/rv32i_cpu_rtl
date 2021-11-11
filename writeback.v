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
    input                           mem_read,
    input   [`MEM_MODE_WIDTH-1:0]   mem_mode,   // for read data mode
    input                           mem_to_reg,
    input   [`RADDR_WIDTH-1:0]      rd,
    input   [`DATA_WIDTH-1:0]       alu_result,
    input                           reg_web,
    input   [`DATA_WIDTH-1:0]       mem_rdata,

    output                          reg_write,  // reg write enable signal
    output  [`RADDR_WIDTH-1:0]      reg_waddr,  // 5bit regfile address

    // according mem_to_reg select alu_result or mem_rdata.
    output  [`DATA_WIDTH-1:0]       reg_wdata
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
// reg write data decode, for mem is 32bits non 4 bytes aligned, we need to 
// according mem addr, mem mode to decode the real reg write data. if B inst
// addr least two significant bit can be 00, 01, 10, 11, respectively means
// access least byte, mid least byte, mid most byte, most byte. it is same as
// HW access mode, but not suppot acces mid 2 bytes.
//==============================================================================
always @(*) begin
    if (reg_web == `REG_WR_EN) begin
        if (mem_to_reg == `MEMREG_EN && mem_read == `MEM_RD_EN) begin
            case (mem_mode)
                `MEM_BYTE:      begin
                    case (alu_result[1:0]) // when LOAD, alu result is mem addr
                        2'b00:  reg_wdata_reg   =
                                    {{24{mem_rdata[7]}},mem_rdata[7:0]};
                        2'b01:  reg_wdata_reg   =
                                    {{24{mem_rdata[15]}},mem_rdata[15:8]};
                        2'b10:  reg_wdata_reg   =
                                    {{24{mem_rdata[23]}},mem_rdata[23:16]};
                        2'b11:  reg_wdata_reg   =
                                    {{24{mem_rdata[31]}},mem_rdata[31:24]};
                    endcase
                end
                `MEM_HWORD:     begin
                    case (alu_result[1:0]) // don't support read middle 2bytes
                        2'b00:  reg_wdata_reg   =
                                    {{16{mem_rdata[15]}},mem_rdata[15:0]};
                        2'b10:  reg_wdata_reg   =
                                    {{16{mem_rdata[31]}},mem_rdata[31:16]};
                        default : reg_wdata_reg =   `ZERO;
                    endcase
                end
                `MEM_WORD:      begin
                                reg_wdata_reg   =   mem_rdata;
                end
                `MEM_BYTEU:     begin
                    case (alu_result[1:0]) // when LOAD, alu result is mem addr
                        2'b00:  reg_wdata_reg   =   {24'd0,mem_rdata[7:0]};
                        2'b01:  reg_wdata_reg   =   {24'd0,mem_rdata[15:8]};
                        2'b10:  reg_wdata_reg   =   {24'd0,mem_rdata[23:16]};
                        2'b11:  reg_wdata_reg   =   {24'd0,mem_rdata[31:24]};
                    endcase
                end
                `MEM_HWORDU:    begin
                    case (alu_result[1:0]) // don't support read middle 2bytes
                        2'b00:  reg_wdata_reg   =   {16'd0,mem_rdata[15:0]};
                        2'b10:  reg_wdata_reg   =   {16'd0,mem_rdata[31:16]};
                        default : reg_wdata_reg =   `ZERO;
                    endcase
                end
                default :       reg_wdata_reg   =   `ZERO;
            endcase
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