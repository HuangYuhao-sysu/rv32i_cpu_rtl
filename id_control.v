// =============================================================================
// Project Name        : rv32i cpu
// Email               : huangyh76@mail2.sysu.edu.cn
// Company             : Sun Yat-Sen University
// Create Time         : 2021/11/01
// File Name           : id_control.v
// Module Name         : id_control
// Designer            : Huangyh
// Editor              : vs code
//
// *****************************************************************************
// Abstract            : control ex mem wb control signals and stall signal form
//                      hardzard detection. comb logic.
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

module id_control (
    // id_ prefix means signals from id.
    input                           id_alu_src,
    input   [`ALUOP_WIDTH-1:0]      id_alu_op,

    input                           id_mem_write,
    input                           id_mem_read,
    input   [`MEM_MODE_WIDTH-1:0]   id_mem_mode,

    input                           id_mem_to_reg,

    input                           id_reg_write,
    
    // from hardzard detection
    input                           stall,

    output                          alu_src,
    output  [`ALUOP_WIDTH-1:0]      alu_op,

    output                          mem_write,
    output                          mem_read,
    output  [`MEM_MODE_WIDTH-1:0]   mem_mode,

    output                          mem_to_reg,

    output                          reg_write
);

// =========================================================================== \
// ============================= Internal signals ============================
// =========================================================================== /
reg                         alu_src_reg;
reg [`ALUOP_WIDTH-1:0]      alu_op_reg;
reg                         mem_write_reg;
reg                         mem_read_reg;
reg [`MEM_MODE_WIDTH-1:0]   mem_mode_reg;
reg                         mem_to_reg_reg;
reg                         reg_write_reg;

// =========================================================================== \
// --------------------------------- Main Code ---------------------------------
// =========================================================================== /

//==============================================================================
// output reg assign
//==============================================================================
assign alu_src      = alu_src_reg;
assign alu_op       = alu_op_reg;
assign mem_write    = mem_write_reg;
assign mem_read     = mem_read_reg;
assign mem_mode     = mem_mode_reg;
assign mem_to_reg   = mem_to_reg_reg;
assign reg_write    = reg_write_reg;

//==============================================================================
// when stall active, we can't change cpu arch state, control signlas will 
// be set disable.
//==============================================================================
always @(*) begin
    if (stall == `STALL_EN) begin
        alu_src_reg     =   `ALU_SRC_REG;   // disable src select, == 1'b0
        alu_op_reg      =   `ALU_ADD;       // disable alu op == 4'd0
        mem_write_reg   =   `MEM_WR_DIS;    // disable memory write
        mem_read_reg    =   `MEM_RD_DIS;    // disable memory read
        mem_mode_reg    =   `MEM_BYTE;      // disable mem mode, == 3'd0
        mem_to_reg_reg  =   `MEMREG_DIS;    // disable mem to reg
        reg_write_reg   =   `REG_WR_DIS;    // disable regfile write
    end

    else begin
        alu_src_reg     =   id_alu_src;     // enable src select
        alu_op_reg      =   id_alu_op;      // enable alu op
        mem_write_reg   =   id_mem_write;   // enable memory write
        mem_read_reg    =   id_mem_read;    // enable memory read
        mem_mode_reg    =   id_mem_mode;    // enable mem mode
        mem_to_reg_reg  =   id_mem_to_reg;  // enable mem to reg
        reg_write_reg   =   id_reg_write;   // enable regfile write
    end
end

endmodule